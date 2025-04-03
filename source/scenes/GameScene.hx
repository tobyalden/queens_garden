package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.graphics.hardware.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import openfl.Assets;

class GameScene extends Scene
{
    public static inline var SAVE_FILE_NAME = "saveme";
    public static inline var GAME_WIDTH = 480;
    public static inline var GAME_HEIGHT = 360;
    public static inline var DEBUG_MOVE_SPEED = 750;

    public static var totalTime:Float = 0;
    public static var deathCount:Float = 0;
    public static var sfx:Map<String, Sfx> = null;
    public static var bossCheckpoint:Vector2 = null;

    public var activeBosses(default, null):Array<Boss>;
    public var defeatedBossNames(default, null):Array<String>;

    public var curtain(default, null):Curtain;
    public var isRetrying(default, null):Bool;
    public var bossTweener(default, null):Entity;
    private var level:Level;
    private var player:Player;
    private var ui:UI;
    private var canRetry:Bool;

    public function saveGame(checkpoint:Checkpoint) {
        GameScene.bossCheckpoint = null;
        Data.write("hasSaveData", true);
        Data.write("currentCheckpoint", new Vector2(checkpoint.x + 2, checkpoint.bottom - 48));
        Data.write("flipX", player.sprite.flipX);
        Data.write("totalTime", totalTime);
        Data.write("deathCount", deathCount);
        Data.write("defeatedBossNames", defeatedBossNames.join(','));
        Data.save(SAVE_FILE_NAME);
    }

    override public function begin() {
        Data.load(SAVE_FILE_NAME);

        activeBosses = [];
        defeatedBossNames = Data.read("defeatedBossNames", "").split(",");
        defeatedBossNames.remove("");

        addGraphic(new Backdrop(Texture.create(10, 10, false, 0x023020)), 10);

        curtain = add(new Curtain());
        curtain.fadeOut(1);

        activeBosses = [];
        bossTweener = add(new Entity());

        ui = add(new UI());
        canRetry = false;
        isRetrying = false;

        level = add(new Level("level"));
        var skies = new Array<Entity>();
        for(entity in level.entities) {
            if(entity.name == "player") {
                player = cast(entity, Player);
                var currentCheckpoint = Data.read(
                    "currentCheckpoint", new Vector2(player.x, player.y)
                );
                var checkpoint = GameScene.bossCheckpoint != null ? GameScene.bossCheckpoint : currentCheckpoint;
                player.moveTo(checkpoint.x, checkpoint.y);
            }
            else if(entity.type == "boss" && isBossDefeated(entity.name)) {
                //trace('Boss with name "${entity.name}" already defeated. Skipping...');
                continue;
            }
            add(entity);
        }

        if(sfx == null) {
            sfx = [
                "restart" => new Sfx("audio/restart.ogg"),
                "retryprompt" => new Sfx("audio/retryprompt.ogg"),
                "retry" => new Sfx("audio/retry.wav"),
                "backtosavepoint" => new Sfx("audio/backtosavepoint.ogg"),
                "ambience" => new Sfx("audio/ambience.wav")
            ];
        }
        if(!sfx["ambience"].playing) {
            sfx["ambience"].loop();
        }
    }

    public function defeatBoss(boss:Boss) {
        activeBosses.remove(boss);
        defeatedBossNames.push(boss.name);
    }

    public function isAnyBossActive() {
        return activeBosses.length > 0;
    }

    public function isBossDefeated(bossName:String) {
        return defeatedBossNames.indexOf(bossName) != -1;
    }

    public function triggerBoss(bossName:String, newBossCheckpoint:Vector2) {
        if(isBossDefeated(bossName)) {
            return;
        }
        var boss = cast(getInstance(bossName), Boss);
        boss.active = true;
        activeBosses.push(boss);
        GameScene.bossCheckpoint = newBossCheckpoint;
    }

    public function onDeath() {
        Boss.sfx["klaxon"].stop();
        Data.load(SAVE_FILE_NAME);
        GameScene.deathCount++;
        HXP.alarm(1, function() {
            ui.showRetryPrompt();
            sfx["retryprompt"].play();
            canRetry = true;
        });
    }

    override public function update() {
        bossTweener.active = isAnyBossActive();
        if(canRetry && !isRetrying) {
            var retry = false;
            if(Input.pressed("jump")) {
                sfx["retry"].play(0.75);
                retry = true;
            }
            else if(GameScene.bossCheckpoint != null && Input.pressed("action")) {
                sfx["backtosavepoint"].play();
                GameScene.bossCheckpoint = null;
                retry = true;
            }
            if(retry) {
                isRetrying = true;
                curtain.fadeIn(0.2);
                var reset = new Alarm(0.2, function() {
                    HXP.scene = new GameScene();
                });
                addTween(reset, true);
            }
        }

        totalTime += HXP.elapsed;
        super.update();
        var screenX = Math.floor(player.centerX / GAME_WIDTH);
        var screenY = Math.floor(player.centerY / GAME_HEIGHT);
        if(isCameraFar()) {
            screenX = Math.floor(screenX / 2) * 2;
            screenY = Math.floor(screenY / 2) * 2;
            camera.setTo(screenX * GAME_WIDTH, screenY * GAME_HEIGHT, 0, 0);
            camera.scaleX = 0.5;
            camera.scaleY = 0.5;
        }
        else {
            camera.setTo(screenX * GAME_WIDTH, screenY * GAME_HEIGHT, 0, 0);
            camera.scaleX = 1;
            camera.scaleY = 1;
        }
        debug();
    }

    public function isCameraFar() {
        var screenX = Math.floor(player.centerX / GAME_WIDTH);
        var screenY = Math.floor(player.centerY / GAME_HEIGHT);
        return level.cameraFar.getTile(screenX, screenY);
    }

    private function debug() {
        if(Input.pressed("restart")) {
            Data.clear(SAVE_FILE_NAME);
            HXP.scene = new GameScene();
            sfx["restart"].play();
        }

        player.active = !(Key.check(Key.DIGIT_0) || Key.check(Key.DIGIT_9));

        // Debug movement (smooth)
        if(Key.check(Key.DIGIT_9)) {
            if(Key.check(Key.A)) {
                player.x -= DEBUG_MOVE_SPEED * HXP.elapsed;
            }
            if(Key.check(Key.D)) {
                player.x += DEBUG_MOVE_SPEED * HXP.elapsed;
            }
            if(Key.check(Key.W)) {
                player.y -= DEBUG_MOVE_SPEED * HXP.elapsed;
            }
            if(Key.check(Key.S)) {
                player.y += DEBUG_MOVE_SPEED * HXP.elapsed;
            }
        }
    }
}
