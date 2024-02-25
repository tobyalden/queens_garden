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

class Bull extends Boss {
    public static inline var CHARGE_COOLDOWN = 1;
    public static inline var CHARGE_SPEED = 300;
    public static inline var CHARGE_DECEL = 300;

    private var velocity:Vector2;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;
    private var chargeCooldown:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "bull";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/bull.png");
        mask = new Hitbox(50, 50);
        velocity = new Vector2();
        attackOptions = ["charge", "charge", "retreat"];
        attackIndex = 0;
        chargeCooldown = new Alarm(CHARGE_COOLDOWN);
        addTween(chargeCooldown);
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "charge") {
            charge();
        }
        else if(attackOption == "retreat") {
            retreat();
        }
        attackIndex = increment(attackIndex, attackOptions.length);
        if(attackIndex == 0) {
            do { HXP.shuffle(attackOptions); } while (attackOptions[0] == attackOption);
        };
    }

    private function dropMine() {
        shoot({
            radius: 8,
            angle: getAngleTowardsPlayer(),
            speed: 0,
            color: 0xFFF7AB,
            accel: 0,
            tracking: 600 * 1.5,
            callback: function(b:Bullet) {
                var bullet = new Bullet(b.centerX, b.centerY, {
                    radius: 8,
                    angle: getAngleTowardsPlayer(),
                    speed: 1,
                    color: 0xFF0000,
                    accel: 300,
                    tracking: 600 * 1.5
                });
                HXP.scene.add(bullet);
                HXP.scene.remove(b);
            },
            callbackDelay: 1,
        });
    }

    private function charge() {
        dropMine();
        velocity = getHeadingTowards(getPlayer());
        velocity.normalize(CHARGE_SPEED);
        chargeCooldown.start();
    }

    private function retreat() {
        dropMine();
        velocity = getHeadingTowards(getPlayer());
        velocity.normalize(CHARGE_SPEED);
        velocity.inverse();
        chargeCooldown.start();
    }

    override function update() {
        if(!chargeCooldown.active) {
            attack();
        }
        var speed = MathUtil.approach(
            velocity.length, 0, CHARGE_DECEL * HXP.elapsed
        );
        velocity.normalize(speed);
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = -velocity.x / 2;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = -velocity.y / 2;
        return true;
    }
}


