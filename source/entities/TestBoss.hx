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
    public static inline var JUMP_POWER = 500;
    public static inline var JUMP_VARIANCE = 100;
    public static inline var MAX_FALL_SPEED = 370;
    public static inline var RUN_SPEED = 150;
    public static inline var RUN_VARIANCE = 150;
    public static inline var JUMP_PAUSE = 0.75;

    private var velocity:Vector2;
    private var jumpTimer:Alarm;
    private var willJump:Bool;
    private var wasOnGround:Bool;

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
    }

    override function update() {
        if(isOnGround()) {
            velocity.x = 0;
            if(!wasOnGround) {
                spreadShot(11, 16, 200, (centerX < getPlayer().centerX ? 1 : -1) * Math.PI / 2, Math.PI * 2 / 11);
                //shoot({
                    //radius: 16,
                    //angle: (centerX < getPlayer().centerX ? 1 : -1) * Math.PI / 2,
                    //speed: 200,
                    //shotByPlayer: false,
                    //collidesWithWalls: false,
                    //color: 0xFF000
                //});
            }
        }
        if(willJump && isOnGround()) {
            jump();
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
        for(i in 0...3) {
            HXP.alarm(0.5 + i * 0.03, function() {
                spreadShot(4, 8, 150, getAngleTowardsPlayer(), Math.PI / 5);
            }, this);
        }
    }
}

