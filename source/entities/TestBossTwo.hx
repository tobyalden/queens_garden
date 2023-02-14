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

    private var spreadShotTimer:Alarm;
    private var pointNodes:Array<Vector2>;

    private var mover:MultiVarTween;
    private var movePause:Alarm;
    private var pointIndex:Int;
    private var shotAngle:Float;
    private var shotPosition:Vector2;

    public function new(x:Float, y:Float, pointNodes:Array<Vector2>) {
        super(x, y);
        this.pointNodes = pointNodes;
        name = "testbosstwo";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/testbosstwo.png");
        mask = new Hitbox(50, 50);

        spreadShotTimer = new Alarm(SPREAD_SHOT_INTERVAL, function() {
            //spreadShot(4, 8, 150, getAngleTowardsPlayer(), Math.PI / 6, 0xE0BBE4);
        }, TweenType.Looping);
        addTween(spreadShotTimer, true);

        HXP.shuffle(pointNodes);

        mover = new MultiVarTween();
        addTween(mover);
        movePause = new Alarm(0.3, function() {
            move();
        });
        addTween(movePause);
        pointIndex = 0;
        shotAngle = 0;
        shotPosition = new Vector2();
    }

    private function move() {
        var destination = pointNodes[pointIndex];
        var travelTime = distanceToPoint(destination.x, destination.y) / 200;
        mover.tween(
            this,
            {"x": destination.x, "y": destination.y},
            travelTime
            //Ease.sineInOut
        );
        pointIndex = MathUtil.increment(pointIndex, pointNodes.length);
        if(pointIndex == 0) {
            do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
        }
        var travelIncrements = [
            0.4, 0.425, 0.45, 0.475,
            0.5, 0.525, 0.55, 0.575,
            0.6
        ];
        for(i in 0...travelIncrements.length) {
            HXP.alarm(travelIncrements[i], function() {
                if(i == 0) {
                    shotAngle = getAngleTowardsPlayer();
                    shotPosition = new Vector2(x, y);
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
            }, this);
        }
    }

    override function update() {
        if(!mover.active && !movePause.active) {
            movePause.start();
        }
    }
}
