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

        //attackOptions = ["move", "spell", "special"];
        attackOptions = ["special"];
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
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "move") {
            move();
        }
        else if(attackOption == "spell") {
            spell();
        }
        else { // "special"
            special();
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
        HXP.alarm(travelTime + 1, function() {
            HXP.scene.add(new Hurtbox(
                HXP.scene.camera.x + 10, HXP.scene.camera.y,
                70, GameScene.GAME_HEIGHT,
                1, numPillars * delayBetweenPillars + 3
            ));
            HXP.scene.add(new Hurtbox(
                HXP.scene.camera.x + GameScene.GAME_WIDTH - 70 - 10, HXP.scene.camera.y,
                70, GameScene.GAME_HEIGHT,
                1, numPillars * delayBetweenPillars + 3
            ));
            HXP.alarm(2, function() {
                for(i in 0...numPillars) {
                    var delay = fromLeft ? i * delayBetweenPillars : (numPillars - 1) * delayBetweenPillars - i * delayBetweenPillars;
                    HXP.alarm(delay, function() {
                        HXP.scene.add(new Hurtbox(
                            HXP.scene.camera.x + GameScene.GAME_WIDTH / (numPillars + 1) * (i + 1) - pillarWidth / 2, HXP.scene.camera.y,
                            pillarWidth, GameScene.GAME_HEIGHT,
                            0.5, 0.5
                        ));
                    }, getScene().bossTweener);
                }
            }, getScene().bossTweener);
        }, getScene().bossTweener);
        attackPause.reset(travelTime + 1 + numPillars * delayBetweenPillars + 1 + 3);
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
        attackPause.reset(0.7);
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
            attackPause.reset(0.3);
        }
    }
}
