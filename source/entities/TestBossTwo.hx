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

class TestBossTwo extends Boss {
    public static inline var SPREAD_SHOT_INTERVAL = 1.5;

    private var pointNodes:Array<Vector2>;
    private var startPosition:Vector2;

    private var mover:MultiVarTween;
    private var attackPause:Alarm;
    private var pointIndex:Int;
    private var shotAngle:Float;
    private var shotPosition:Vector2;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;
    private var hasUsedSpecial:Bool;
    private var pauseBetweenAttacks:Float;

    public function new(x:Float, y:Float, pointNodes:Array<Vector2>) {
        super(x, y);
        this.pointNodes = pointNodes;
        this.startPosition = new Vector2(x, y);
        name = "testbosstwo";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/testbosstwo.png");
        mask = new Hitbox(50, 50);

        HXP.shuffle(pointNodes);

        attackOptions = ["move", "spell"];
        HXP.shuffle(attackOptions);
        attackIndex = 0;

        mover = new MultiVarTween();
        addTween(mover);
        attackPause = new Alarm(0.3, function() {
            attack();
        });
        addTween(attackPause);
        pointIndex = 0;
        shotAngle = 0;
        shotPosition = new Vector2();
        hasUsedSpecial = false;
        pauseBetweenAttacks = 1;
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(health <= startingHealth / 2 && !hasUsedSpecial) {
            special();
            hasUsedSpecial = true;
        }
        else if(attackOption == "move") {
            move();
        }
        else if(attackOption == "spell") {
            spell();
        }
        attackIndex = MathUtil.increment(attackIndex, attackOptions.length, function() {
            HXP.shuffle(attackOptions);
        });
    }

    private function special() {
        var travelTime = distanceToPoint(startPosition.x, startPosition.y) / 200;
        mover.tween(
            this,
            {"x": startPosition.x, "y": startPosition.y},
            travelTime
        );
        var numPillars = 5;
        var pillarWidth = 30;
        var delayBetweenPillars = 0.4;
        var fromLeft = getPlayer().centerX > centerX;
        var timeSum = doSequence([
            {
                time: travelTime + 1,
                action: function() {
                    HXP.scene.add(new Hurtbox(
                        HXP.scene.camera.x + 10, HXP.scene.camera.y,
                        70, GameScene.GAME_HEIGHT,
                        1, (numPillars * delayBetweenPillars) * 2 + 4 + 1
                    ));
                    HXP.scene.add(new Hurtbox(
                        HXP.scene.camera.x + GameScene.GAME_WIDTH - 70 - 10, HXP.scene.camera.y,
                        70, GameScene.GAME_HEIGHT,
                        1, (numPillars * delayBetweenPillars) * 2 + 4 + 1
                    ));
                }
            },
            {
                time: 2,
                action: function() {
                    for(i in 0...numPillars) {
                        var delay = (
                            fromLeft
                            ? i * delayBetweenPillars
                            : (numPillars - 1) * delayBetweenPillars - i * delayBetweenPillars
                        );
                        HXP.alarm(delay, function() {
                            HXP.scene.add(new Hurtbox(
                                (
                                    HXP.scene.camera.x + GameScene.GAME_WIDTH
                                    / (numPillars + 1) * (i + 1)
                                    - pillarWidth / 2
                                ),
                                HXP.scene.camera.y,
                                pillarWidth, GameScene.GAME_HEIGHT,
                                0.5, 0.5
                            ));
                        }, getScene().bossTweener);
                    }
                }
            },
            {
                time: numPillars * delayBetweenPillars + 2,
                action: function() {
                    fromLeft = !fromLeft;
                    for(i in 0...numPillars) {
                        var delay = (
                            fromLeft
                            ? i * delayBetweenPillars
                            : (numPillars - 1) * delayBetweenPillars - i * delayBetweenPillars
                        );
                        HXP.alarm(delay, function() {
                            HXP.scene.add(new Hurtbox(
                                (
                                    HXP.scene.camera.x + GameScene.GAME_WIDTH
                                    / (numPillars + 1) * (i + 1)
                                    - pillarWidth / 2
                                ),
                                HXP.scene.camera.y,
                                pillarWidth, GameScene.GAME_HEIGHT,
                                0.5, 0.5
                            ));
                        }, getScene().bossTweener);
                    }
                }
            },
        ]);
        timeSum += numPillars * delayBetweenPillars + 3;

        attackPause.reset(timeSum);
        pauseBetweenAttacks = 0.5;
    }

    private function spell() {
        shoot({
            radius: 16,
            angle: getAngleTowardsPlayer(),
            speed: 100,
            color: 0xFFF7AB,
            accel: 600,
            tracking: 600 * 2,
        });
        var resetTime = 0.7;
        if(attackOptions[attackIndex] != "spell") {
            resetTime += 1;
        }
        attackPause.reset(resetTime);
    }

    private function move() {
        var destination = pointNodes[pointIndex];
        var travelTime = distanceToPoint(destination.x, destination.y) / 200;
        mover.tween(
            this,
            {"x": destination.x, "y": destination.y},
            travelTime
        );
        pointIndex = MathUtil.increment(pointIndex, pointNodes.length, function() {
            do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
        });
        var travelIncrements = [
            0, 0.025, 0.05, 0.075,
            0.1, 0.125, 0.15, 0.175,
            0.2
        ];
        for(i in 0...travelIncrements.length) {
            HXP.alarm(travelTime * 0.4 + travelIncrements[i], function() {
                if(i == 0) {
                    shotAngle = getAngleTowardsPlayer();
                    shotPosition = new Vector2(centerX, centerY);
                }
                shootFrom(
                    shotPosition,
                    {
                        radius: 8,
                        angle: shotAngle,
                        speed: 300,
                        color: 0xACECAE
                    }
                );
            }, getScene().bossTweener);
        }
    }

    override function update() {
        if(!mover.active && !attackPause.active) {
            attackPause.reset(0.3 + 1);
        }
    }
}
