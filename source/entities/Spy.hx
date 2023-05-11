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

class Spy extends Boss {
    public static inline var ATTACK_INTERVAL = 2;

    private var pointNodes:Array<Vector2>;
    private var pointIndex:Int;
    private var mover:MultiVarTween;
    private var movePause:Alarm;
    private var isFirstMove:Bool;
    private var attackTimer:Alarm;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;

    public function new(x:Float, y:Float, pointNodes:Array<Vector2>) {
        super(x, y);
        this.pointNodes = pointNodes;
        pointIndex = 0;
        name = "spy";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/spy.png");
        mask = new Hitbox(50, 50);
        mover = new MultiVarTween();
        mover.onComplete.bind(function() {
            isFirstMove = false;
            if(!attackTimer.active) {
                attackTimer.start();
            }
        });
        addTween(mover);
        isFirstMove = true;
        movePause = new Alarm(1, function() {
            move();
        });
        addTween(movePause);
        attackTimer = new Alarm(ATTACK_INTERVAL, function() {
            attack();
        }, TweenType.Looping);
        addTween(attackTimer);

        attackOptions = ["homing", "bomb"];
        HXP.shuffle(attackOptions);
        attackIndex = 0;
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "homing") {
            for(i in 1...4) {
                HXP.alarm(i * 0.07, function() {
                    shoot({
                        radius: 8,
                        angle: getAngleTowardsPlayer(),
                        speed: 100,
                        color: 0xC3B1E1,
                        accel: 300,
                        tracking: 900,
                    });
                }, getScene().bossTweener);
            }
        }
        else if(attackOption == "bomb") {
            shoot({
                radius: 16,
                angle: Math.PI,
                speed: 1,
                color: 0xfdfd96,
                accel: 300,
                callback: function(b:Bullet) {
                    var numBullets = 30;
                    var iterStart = Std.int(-Math.floor(numBullets / 2));
                    var iterEnd = Std.int(Math.ceil(numBullets / 2));
                    for(i in iterStart...iterEnd) {
                        var bullet = new Bullet(b.centerX, b.centerY, {
                            radius: 8,
                            angle: i * Math.PI * 2 / numBullets,
                            speed: 300,
                            color: 0xff6961,
                            callback: function(b:Bullet) {
                                HXP.scene.remove(b);
                            },
                            callbackDelay: 0.5,
                        });
                        HXP.scene.add(bullet);
                    }
                    HXP.scene.remove(b);
                },
                callbackDelay: 1.35,
            });
        }
        attackIndex = MathUtil.increment(attackIndex, attackOptions.length, function() {
            HXP.shuffle(attackOptions);
        });
    }

    private function move() {
        var destination = pointNodes[pointIndex];
        mover.tween(
            this,
            {"x": destination.x, "y": destination.y},
            isFirstMove ? 1.5 : 3,
            Ease.sineInOut
        );
        pointIndex = MathUtil.increment(pointIndex, pointNodes.length, function() {
            do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
        });
    }

    override function update() {
        if(!mover.active && !movePause.active) {
            movePause.start();
        }
        super.update();
    }
}

