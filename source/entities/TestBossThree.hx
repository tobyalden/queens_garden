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

class TestBossThree extends Boss {

    public static inline var SPEED = 250;
    public static inline var FLAIL_DISTANCE = 200;

    public var flail(default, null):Hurtbox;
    private var mover:MultiVarTween;
    private var pointNodes:Array<Vector2>;
    private var pointIndex:Int;
    private var flailPulse:NumTween;
    private var flailClockwise:Bool;
    private var attackOptions:Array<String>;
    private var attackIndex:Int;
    private var fireStartup:Alarm;
    private var fireCooldown:Alarm;

    public function new(x:Float, y:Float, pointNodes:Array<Vector2>) {
        super(x, y);
        layer = -1;
        HXP.shuffle(pointNodes);
        this.pointNodes = pointNodes;
        name = "testbossthree";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/testbossthree.png");
        mask = new Hitbox(50, 50);

        mover = new MultiVarTween();
        addTween(mover);
        pointIndex = 0;
        flail = new Hurtbox(0, 0, width, height, 0, 999999);
        flailClockwise = true;
        flailPulse = new NumTween(TweenType.PingPong);
        flailPulse.onComplete.bind(function() {
            if(flailPulse.forward) {
                flailClockwise = !flailClockwise;
                flailPulse.active = false;
            }
        });
        addTween(flailPulse, true);

        attackOptions = ["fire", "move"];
        HXP.shuffle(attackOptions);
        attackIndex = 0;

        fireStartup = new Alarm(0.3);
        fireStartup.onComplete.bind(function() {
            fire();
            fireCooldown.start();
        });
        addTween(fireStartup);

        fireCooldown = new Alarm(0.3);
        addTween(fireCooldown);
    }

    private function move() {
        var destination = pointNodes[pointIndex];
        var travelTime = distanceToPoint(destination.x, destination.y) / 200;
        pointIndex = increment(pointIndex, pointNodes.length);
        if(pointIndex == 0) {
            do { HXP.shuffle(pointNodes); } while (pointNodes[0] == destination);
        };
        mover.tween(
            this,
            {"x": destination.x, "y": destination.y},
            travelTime,
            Ease.sineInOut
        );
    }

    private function fire() {
        for(i in 0...4) {
            shoot({
                radius: 32,
                angle: (centerX < HXP.scene.camera.x + GameScene.GAME_WIDTH / 2 ? 1 : -1) * Math.PI / 2,
                speed: 200 * 3 - (i * 10),
                color: 0xFFF7AB
            });
        }
    }

    private function attack() {
        var attackOption = attackOptions[attackIndex];
        if(attackOption == "fire") {
            fireStartup.start();
        }
        if(attackOption == "move") {
            if(!flailPulse.active) {
                flailPulse.tween(0, FLAIL_DISTANCE, 1, Ease.sineInOut);
            }
            move();
        }
        attackIndex = increment(attackIndex, attackOptions.length);
        if(attackIndex == 0) {
            do { HXP.shuffle(attackOptions); } while (attackOptions[0] == attackOption);
        };
    }

    override function update() {
        if(!mover.active && !fireStartup.active && !fireCooldown.active) {
            attack();
        }
        var flailDistance = new Vector2(0, -flailPulse.value);
        flailDistance.rotate(age * (flailClockwise ? -1 : 1));
        flail.moveTo(x + flailDistance.x, y + flailDistance.y);
        super.update();
    }
}
