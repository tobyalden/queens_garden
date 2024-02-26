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
import entities.Bullet;

typedef SequenceStep = {
    var time:Float;
    var action:Void->Void;
}

class Boss extends MiniEntity {
    public static inline var DEFAULT_ENRAGE_THRESHOLD = 0.25;
    public static inline var KLAXON_THRESHOLD = 0.25;

    public var health(default, null):Int;
    public var startingHealth(default, null):Int;
    private var sprite:Spritemap;
    private var age:Float;
    private var isEnraged:Bool;
    private var enrageThreshold:Float;

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
        isEnraged = false;
        enrageThreshold = DEFAULT_ENRAGE_THRESHOLD;
    }

    private function increment(index: Int, max:Int) {
        index += 1;
        if(index >= max) {
            index = 0;
        }
        return index;
    }

    private function doSequence(sequence:Array<SequenceStep>) {
        var timeSum = 0.0;
        for(step in sequence) {
            timeSum += step.time;
            HXP.alarm(timeSum, step.action, getScene().bossTweener);
        }
        return timeSum;
    }

    public function takeHit(damage:Int) {
        if(!active) {
            return;
        }
        sfx['bullethit${HXP.choose(1, 2, 3)}'].play();
        health -= damage;
        if(health <= startingHealth * enrageThreshold) {
            if(!isEnraged) {
                triggerEnrage();
            }
        }
        if(health <= startingHealth * KLAXON_THRESHOLD) {
            if(!sfx["klaxon"].playing && !getPlayer().isDead) {
                sfx["klaxon"].loop(0.8);
            }
        }
        if(health <= 0) {
            die();
        }
    }

    private function triggerEnrage() {
        isEnraged = true;
    }

    private function die() {
        scene.remove(this);
        sfx["klaxon"].stop();
        sfx["die"].play();
        explode();
        cast(HXP.scene, GameScene).defeatBoss(this);
    }

    private function spreadShot(
        numBullets:Int, spreadAngle:Float, bulletOptions:BulletOptions
    ) {
        var iterStart = Std.int(-Math.floor(numBullets / 2));
        var iterEnd = Std.int(Math.ceil(numBullets / 2));
        var angleOffset = numBullets % 2 == 0 ? spreadAngle / 2 : 0;
        var originalAngle = bulletOptions.angle;
        for(i in iterStart...iterEnd) {
            bulletOptions.angle = originalAngle + i * spreadAngle + angleOffset;
            shoot(bulletOptions);
        }
    }

    private function shoot(bulletOptions:BulletOptions) {
        var bullet = new Bullet(centerX, centerY, bulletOptions);
        scene.add(bullet);
    }

    private function shootFrom(bulletPosition:Vector2, bulletOptions:BulletOptions) {
        var bullet = new Bullet(bulletPosition.x, bulletPosition.y, bulletOptions);
        scene.add(bullet);
    }

    public override function update() {
        age += HXP.elapsed;
        if(health <= startingHealth * KLAXON_THRESHOLD) {
            graphic.color = 0xFF0000;
            graphic.x = Math.random() * 3;
            graphic.y = Math.random() * 3;
        }
        super.update();
    }
}
