package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Boss extends MiniEntity {
    public var health(default, null):Int;
    public var startingHealth(default, null):Int;
    private var sprite:Spritemap;
    private var age:Float;

    public static var sfx:Map<String, Sfx> = null;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "boss";
        age = 0;
        if(sfx == null) {
            sfx = [
                "bullethit1" => new Sfx("audio/bullethit1.ogg"),
                "bullethit2" => new Sfx("audio/bullethit2.ogg"),
                "bullethit3" => new Sfx("audio/bullethit3.ogg"),
                "die" => new Sfx("audio/bossdeath.ogg"),
                "klaxon" => new Sfx("audio/klaxon.ogg")
            ];
        }
        active = false;
    }

    public function takeHit() {
        if(!active) {
            return;
        }
        sfx['bullethit${HXP.choose(1, 2, 3)}'].play();
        health -= 1;
        if(health <= startingHealth / 4) {
            if(!sfx["klaxon"].playing) {
                if(!cast(scene.getInstance("player"), Player).isDead) {
                    sfx["klaxon"].loop(0.8);
                }
            }
        }
        if(health <= 0) {
            die();
        }
    }

    private function die() {
        scene.remove(this);
        sfx["klaxon"].stop();
        sfx["die"].play();
        explode();
        cast(HXP.scene, GameScene).defeatBoss(this);
    }

    private function spreadShot(
        numBullets:Int, bulletRadius:Int, bulletSpeed:Float, angle:Float, spreadAngle:Float
    ) {
        var iterStart = Std.int(-Math.floor(numBullets / 2));
        var iterEnd = Std.int(Math.ceil(numBullets / 2));
        var angleOffset = numBullets % 2 == 0 ? spreadAngle / 2 : 0;
        for(i in iterStart...iterEnd) {
            var bulletOptions = {
                radius: bulletRadius,
                angle: angle + i * spreadAngle + angleOffset,
                speed: bulletSpeed,
                shotByPlayer: false,
                collidesWithWalls: false,
                color: 0xffc0cb
            };
            var bullet = new Bullet(centerX, centerY, bulletOptions);
            scene.add(bullet);
        }
    }

    public override function update() {
        age += HXP.elapsed;
        if(health <= startingHealth / 4) {
            graphic.x = Math.random() * 3;
            graphic.y = Math.random() * 3;
        }
        super.update();
    }
}
