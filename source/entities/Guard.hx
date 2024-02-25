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

class Guard extends Boss {
    public static inline var JUMP_POWER = 400;
    public static inline var GRAVITY = 800;

    private var pointNodes:Array<Vector2>;
    private var pointIndex:Int;
    private var jumpXTween:MultiVarTween;
    private var jumpPause:Alarm;
    private var currentFloor:Float;
    private var yVelocity:Float;
    private var isFirstJump:Bool;

    public function new(x:Float, y:Float, pointNodes:Array<Vector2>) {
        super(x, y);
        this.pointNodes = pointNodes;
        pointIndex = 0;
        name = "guard";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/guard.png");
        mask = new Hitbox(50, 50);
        jumpXTween = new MultiVarTween();
        addTween(jumpXTween);
        jumpPause = new Alarm(1, function() {
            jump();
        });
        addTween(jumpPause);
        currentFloor = y;
        isFirstJump = true;
    }

    private function jump() {
        var destination = pointNodes[pointIndex];
        currentFloor = destination.y;
        yVelocity = -JUMP_POWER;
        if(isFirstJump) {
            yVelocity *= 1.5;
            isFirstJump = false;
            pointIndex = increment(pointIndex, pointNodes.length);
            if(pointIndex == 0) {
                do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
            };
        }
        var testY = y;
        var testYVelocity = yVelocity;
        var totalTime = 0.0;
        while(testYVelocity <= 0 || testY <= currentFloor) {
            testYVelocity += GRAVITY * (1/60);
            testY += testYVelocity * (1/60);
            totalTime += (1/60);
        }
        jumpXTween.tween(this, {x: destination.x}, totalTime);
        pointIndex = increment(pointIndex, pointNodes.length);
        if(pointIndex == 0) {
            do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
        };
    }

    override function update() {
        if(!jumpXTween.active && !jumpPause.active) {
            jumpPause.start();
        }
        yVelocity += GRAVITY * HXP.elapsed;
        y += yVelocity * HXP.elapsed;
        if(yVelocity > 0 && y > currentFloor) {
            y = currentFloor;
            yVelocity = 0;
        }
        super.update();
    }
}
