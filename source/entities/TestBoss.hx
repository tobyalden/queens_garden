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
    public static inline var JUMP_HORIZONTAL_SPEED = 150;
    public static inline var JUMP_HORIZONTAL_SPEED_VARIANCE = 150;
    public static inline var ATTACK_PAUSE = 0.75;
    public static inline var DASH_SPEED = 800;
    public static inline var DASH_TIME = 0.75;
    public static inline var PREDASH_TIME = 0.25;

    private var velocity:Vector2;
    private var attackTimer:Alarm;
    private var willAttack:Bool;
    private var wasOnGround:Bool;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;
    private var dashVelocity:Float;
    private var dashTimer:VarTween;
    private var preDashTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "testboss";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/testboss.png");
        mask = new Hitbox(50, 50);
        velocity = new Vector2();
        attackTimer = new Alarm(ATTACK_PAUSE, function() {
            willAttack = true;
        });
        addTween(attackTimer);
        willAttack = false;
        wasOnGround = false;
        attackOptions = ["jump", "jump", "spray", "dash"];
        //attackOptions = ["dash"];
        HXP.shuffle(attackOptions);
        attackIndex = 0;
        dashVelocity = 0;
        dashTimer = new VarTween();
        addTween(dashTimer);
        preDashTimer = new Alarm(PREDASH_TIME, function() {
            velocity.x = dashVelocity;
            dashTimer.tween(velocity, "x", 0, DASH_TIME);
            graphic.color = 0xFFFFFF;
        });
        preDashTimer.onStart.bind(function() {
            graphic.color = 0xFF0000;
        });
        addTween(preDashTimer);
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "jump") {
            jump();
        }
        else if(attackOption == "dash") {
            preDashTimer.start();
            dashVelocity = DASH_SPEED * (centerX < getPlayer().centerX ? 1 : -1);
        }
        else { // "spray"
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
            if(!dashTimer.active) {
                velocity.x = 0;
            }
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
        if(willAttack && isOnGround()) {
            attack();
            willAttack = false;
        }
        else if(isOnGround() && !attackTimer.active && !dashTimer.active && !preDashTimer.active) {
            attackTimer.start();
        }
        velocity.y += GRAVITY * HXP.elapsed;
        velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        wasOnGround = isOnGround();
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    private function jump() {
        if(centerX < getPlayer().centerX) {
            velocity.x = JUMP_HORIZONTAL_SPEED + (Random.random * JUMP_HORIZONTAL_SPEED_VARIANCE);
        }
        else {
            velocity.x = -(JUMP_HORIZONTAL_SPEED + (Random.random * JUMP_HORIZONTAL_SPEED_VARIANCE));
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

