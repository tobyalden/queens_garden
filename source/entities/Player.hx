package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Player extends MiniEntity
{
    public static inline var ITEM_GUN = 0;
    public static inline var ITEM_STORED_JUMP = 1;
    public static inline var ITEM_HIGH_JUMP = 2;

    public static inline var RUN_ACCEL = 9999;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 9999;
    public static inline var AIR_DECEL = 9999;
    public static inline var MAX_RUN_SPEED = 210;
    public static inline var MAX_AIR_SPEED = 200;
    public static inline var GRAVITY = 800;
    public static inline var JUMP_POWER = 380;
    public static inline var HIGH_JUMP_POWER = 450;
    public static inline var LAUNCHER_JUMP_POWER = 500;
    public static inline var JUMP_CANCEL_POWER = 20;
    public static inline var MAX_FALL_SPEED = 370;
    public static inline var MAX_RISE_SPEED = 400;

    public static inline var SHOT_SPEED = 500;
    public static inline var SHOT_COOLDOWN = 1 / 60 * 5 * 2;
    public static inline var SHOT_DAMAGE = 2;
    public static inline var SWORD_DAMAGE = 3;

    public static inline var COYOTE_TIME = 1 / 60 * 5;

    public static inline var JETPACK_POWER = 4000;
    public static inline var FUEL_USE_RATE = 500 * 2;
    public static inline var MAX_FUEL_PODS = 1;
    //public static inline var MAX_FUEL = 200;
    public static inline var MAX_FUEL = 100;

    public static var sfx:Map<String, Sfx> = null;

    public var sprite(default, null):Spritemap;
    public var isDead(default, null):Bool;
    public var fuelPods(default, null):Int;
    public var fuel(default, null):Float;
    private var velocity:Vector2;
    private var canMove:Bool;
    private var canJump:Bool;
    private var shotCooldown:Alarm;
    private var isCrouching:Bool;
    private var airTime:Float;
    private var inventory:Array<Int>;
    private var crouchHitbox:Hitbox;
    private var releasedJump:Bool;
    private var isUsingJetpack:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        type = "player";
        layer = -10;
        sprite = new Spritemap("graphics/player.png", 32, 48);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("fall", [5]);
        sprite.add("crouch", [6]);
        sprite.add("idle_gun", [7]);
        sprite.add("run_gun", [8, 9, 10, 9], 8);
        sprite.add("jump_gun", [11]);
        sprite.add("fall_gun", [12]);
        sprite.add("crouch_gun", [13]);
        sprite.add("ride_gun", [14]);
        sprite.add("ride", [15]);
        sprite.play("idle");
        var hitbox = new Hitbox(24, 48);
        crouchHitbox = new Hitbox(24, 32, 0, 16);
        releasedJump = false;
        isUsingJetpack = false;
        fuelPods = 3;
        fuel = MAX_FUEL;
        mask = new Masklist([hitbox, crouchHitbox]);
        sprite.x = -2;
        graphic = sprite;
        velocity = new Vector2();
        isDead = false;
        canMove = false;
        canJump = false;
        var allowMove = new Alarm(0.2, function() {
            canMove = true;
        });
        addTween(allowMove, true);
        shotCooldown = new Alarm(SHOT_COOLDOWN);
        addTween(shotCooldown);
        isCrouching = false;
        airTime = 0;
        inventory = [ITEM_GUN];
        //inventory = [];
        if(sfx == null) {
            sfx = [
                "jump" => new Sfx("audio/jump.ogg"),
                "superjump" => new Sfx("audio/superjump.wav"),
                "youwin" => new Sfx("audio/youwin.wav"),
                "run" => new Sfx("audio/run.wav"),
                "die" => new Sfx("audio/death.ogg"),
                "save" => new Sfx("audio/save.ogg"),
                "shoot" => new Sfx("audio/shoot.ogg"),
                "usefuelpod" => new Sfx("audio/usefuelpod.wav")
            ];
        }
        sprite.flipX = Data.read("flipX", false);
    }

    public function hasItem(item:Int) {
        return inventory.indexOf(item) != -1;
    }

    override public function update() {
        if(!isDead) {
            if(canMove) {
                shooting();
                movement();
            }
            animation();
            if(canMove) {
                sound();
            }
            collisions();
        }
        super.update();
    }

    private function shooting() {
        if(Input.check("action") && !shotCooldown.active) {
            //var spreadAmount = Math.PI / 16;
            var spreadAmount = 0;
            //if(isCrouching) {
                //spreadAmount = 0;
            //}
            var shotAngle = (sprite.flipX ? -1 : 1) * Math.PI / 2 + (Math.random() - 0.5) * spreadAmount;
            if(Input.check("up")) {
                shotAngle = 0;
            }
            else if(!isOnGround() && Input.check("down")) {
                shotAngle = Math.PI;
            }
            var sword = new Bullet(
                sprite.flipX ? centerX - sprite.x - 32: centerX - sprite.x + 32, centerY + (isCrouching ? 5 : 0),
                {
                    width: 64,
                    height: 32,
                    angle: shotAngle,
                    speed: 0,
                    shotByPlayer: true,
                    collidesWithWalls: true,
                    color: 0xADD8E6,
                    duration: SHOT_COOLDOWN / 2,
                    isSword: true
                }
            );
            HXP.scene.add(sword);
            attached.push(sword);
            shotCooldown.start();
            var bullets = [];
            HXP.scene.getType("playerbullet", bullets);
            if(bullets.length >= 3) {
                return;
            }
            var bullet = new Bullet(
                sprite.flipX ? centerX - sprite.x : centerX - sprite.x, centerY + (isCrouching ? 5 : 0),
                {
                    width: 16,
                    height: 8,
                    angle: shotAngle,
                    speed: SHOT_SPEED,
                    shotByPlayer: true,
                    collidesWithWalls: true
                }
            );
            HXP.scene.add(bullet);
        }
        //if(Input.check("action")) {
            //if(!sfx["shoot"].playing) {
                //sfx["shoot"].loop(0.25);
            //}
        //}
        //else {
            //sfx["shoot"].stop();
        //}
    }

    private function collisions() {
        var checkpoint = collide("checkpoint", x, y);
        if(Input.pressed("down") && checkpoint != null) {
            cast(checkpoint, Checkpoint).flash();
            sfx["save"].play();
        }
        var hazard = collide("hazard", x, y);
        if(hazard != null) {
            if(isCrouching) {
                if(crouchHitbox.collide(hazard.mask)) {
                    die();
                }
            }
            else {
                die();
            }
        }
        var boss = collide("boss", x, y);
        if(boss != null) {
            if(isCrouching) {
                if(crouchHitbox.collide(boss.mask)) {
                    die();
                }
            }
            else {
                die();
            }
        }
        for(solid in MiniEntity.alwaysSolids) {
            if(collide(solid, x, y) != null) {
                die();
            }
        }
    }

    private function stopSounds() {
        sfx["run"].stop();
        sfx["shoot"].stop();
    }

    public function die() {
        if(Key.check(Key.G)) {
            return;
        }
        visible = false;
        collidable = false;
        isDead = true;
        explode();
        stopSounds();
        sfx["die"].play(0.8);
        cast(HXP.scene, GameScene).onDeath();
    }

    private function movement() {
        var accel = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        var decel = isOnGround() ? RUN_DECEL : AIR_DECEL;

        if(isOnGround() && Input.check("down") && collide("checkpoint", x, y) == null) {
            isCrouching = true;
        }
        else {
            isCrouching = false;
        }

        if(isCrouching) {
            velocity.x = 0;
        }
        else if(Input.check("left") && !isOnLeftWall()) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(Input.check("right") && !isOnRightWall()) {
            velocity.x += accel * HXP.elapsed;
        }
        else {
            velocity.x = MathUtil.approach(
                velocity.x, 0, decel * HXP.elapsed
            );
        }
        var maxSpeed:Float = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        if(isUsingJetpack) {
            maxSpeed *= 1.5;
        }
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        isUsingJetpack = false;
        if(isOnGround()) {
            canJump = true;
            velocity.y = 0;
            airTime = 0;
            fuelPods = MAX_FUEL_PODS;
            fuel = 0;
        }
        else {
            airTime += HXP.elapsed;
            if(airTime > COYOTE_TIME) {
                canJump = false;
            }

            if(Input.check("jump")) {
                if(releasedJump && Input.pressed("jump")) {
                    if(fuelPods > 0) {
                        useFuelPod();
                        if(velocity.y > JUMP_CANCEL_POWER) {
                            velocity.y = JUMP_CANCEL_POWER;
                        }
                    }
                }
                if(releasedJump && fuel > 0) {
                    isUsingJetpack = true;
                }
            }
            else {
                if(fuelPods < MAX_FUEL_PODS) {
                    fuel = 0;
                }
                releasedJump = true;
            }

            if(Input.released("jump")) {
                var jumpCancelPower = JUMP_CANCEL_POWER;
                velocity.y = Math.max(velocity.y, -jumpCancelPower);
            }
            if(isUsingJetpack) {
                velocity.y -= JETPACK_POWER * HXP.elapsed;
                fuel -= FUEL_USE_RATE * HXP.elapsed;
                fuel = Math.max(fuel, 0);
                if(fuel == 0) {
                    //if(fuelPods > 0) {
                        //useFuelPod();
                    //}
                    //else {
                        isUsingJetpack = false;
                    //}
                }
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = MathUtil.clamp(velocity.y, -MAX_RISE_SPEED, MAX_FALL_SPEED);
        }

        if(
            Input.pressed("jump") && Input.check("down")
            && collide("oneway", x, y + 1) != null
            && collideAny(MiniEntity.alwaysSolids, x, y + 1) == null
        ) {
            y += 1;
        }
        else if(Input.pressed("jump") && canJump) {
            sfx["jump"].play();
            velocity.y = -JUMP_POWER;
            canJump = false;
            makeDustAtFeet();
            releasedJump = false;
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, MiniEntity.solids);
    }

    private function makeDustAtFeet() {
        var dust = new Dust(centerX - 5, bottom - 4);
        var platform = collide("platform", x, y + 1);
        if(platform != null) {
            cast(platform, MovingPlatform).attached.push(dust);
        }
        HXP.scene.add(dust);
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = 0;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(velocity.y < 0) {
            velocity.y = -velocity.y / 2.5;
        }
        else {
            velocity.y = 0;
        }
        return true;
    }

    private function animation() {
        if(!Input.check("action") || isCrouching || !hasItem(ITEM_GUN)) {
            if(Input.check("left")) {
                sprite.flipX = true;
            }
            else if(Input.check("right")) {
                sprite.flipX = false;
            }
        }

        var animationSuffix = hasItem(ITEM_GUN) ? "_gun" : "";

        if(!canMove) {
            if(isOnGround()) {
                sprite.play("idle" + animationSuffix);
            }
            else {
                sprite.play("jump" + animationSuffix);
            }
        }
        else if(!isOnGround()) {
            if(velocity.y < -JUMP_CANCEL_POWER) {
                sprite.play("jump" + animationSuffix);
            }
            else {
                sprite.play("fall" + animationSuffix);
            }
        }
        else if(velocity.x != 0) {
            sprite.play("run" + animationSuffix);
        }
        else {
            if(isCrouching) {
                sprite.play("crouch" + animationSuffix);
            }
            else {
                sprite.play("idle" + animationSuffix);
            }
        }
    }

    private function useFuelPod() {
        fuelPods -= 1;
        sfx["usefuelpod"].play(0.2);
        fuel = MAX_FUEL;
    }

    private function sound() {
        if(isOnGround() && Math.abs(velocity.x) > 0) {
            if(!sfx["run"].playing) {
                sfx["run"].loop();
            }
        }
        else {
            sfx["run"].stop();
        }
    }
}
