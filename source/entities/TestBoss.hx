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

class TestBoss extends Boss {
    public static inline var GRAVITY = 800;
    public static inline var JUMP_POWER = 525;
    public static inline var JUMP_VARIANCE = 50;
    public static inline var MAX_FALL_SPEED = 370;
    public static inline var RUN_SPEED = 150;
    public static inline var RUN_VARIANCE = 150;
    public static inline var JUMP_PAUSE = 0.75;

    private var velocity:Vector2;
    private var jumpTimer:Alarm;
    private var willJump:Bool;
    private var wasOnGround:Bool;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "testboss";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/testboss.png");
        mask = new Hitbox(50, 50);
        velocity = new Vector2();
        jumpTimer = new Alarm(JUMP_PAUSE, function() {
            willJump = true;
        });
        addTween(jumpTimer);
        willJump = false;
        wasOnGround = false;
        attackOptions = ["jump", "jump", "spray"];
        HXP.shuffle(attackOptions);
        attackIndex = 0;
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "jump") {
            jump();
        }
        else {
            spreadShot(
                7,
                Math.PI / 27,
                {
                    radius: 10,
                    angle: 0,
                    speed: 600,
                    color: 0xB0E3EA,
                    gravity: GRAVITY,
                }
            );
        }
        attackIndex += 1;
        if(attackIndex >= attackOptions.length) {
            attackIndex = 0;
            HXP.shuffle(attackOptions);
        }
    }

    override function update() {
        if(isOnGround()) {
            velocity.x = 0;
            if(!wasOnGround) {
                var numBullets = 13;
                spreadShot(
                    numBullets,
                    Math.PI * 2 / numBullets,
                    {
                        radius: 16,
                        angle: (centerX < getPlayer().centerX ? 1 : -1) * Math.PI / 2,
                        speed: 200,
                        color: 0xFEC8D8
                    }
                );
            }
        }
        if(willJump && isOnGround()) {
            attack();
            willJump = false;
        }
        else if(isOnGround() && !jumpTimer.active) {
            jumpTimer.start();
        }
        velocity.y += GRAVITY * HXP.elapsed;
        velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        wasOnGround = isOnGround();
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    private function jump() {
        if(centerX < getPlayer().centerX) {
            velocity.x = RUN_SPEED + (Random.random * RUN_VARIANCE);
        }
        else {
            velocity.x = -(RUN_SPEED + (Random.random * RUN_VARIANCE));
        }
        velocity.y = -(JUMP_POWER + JUMP_VARIANCE * Random.random);
        for(i in 0...5) {
            HXP.alarm(0.5 + i * 0.03, function() {
                spreadShot(
                    4,
                    Math.PI / 5,
                    {
                        radius: 8,
                        angle: getAngleTowardsPlayer(),
                        speed: 150,
                        color: 0xACECAE
                    }
                );
            }, this);
        }
    }
}

