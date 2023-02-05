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

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "testbosstwo";
        health = 10;
        startingHealth = health;
        graphic = new Image("graphics/testbosstwo.png");
        mask = new Hitbox(50, 50);

        spreadShotTimer = new Alarm(SPREAD_SHOT_INTERVAL, function() {
            //spreadShot(4, 8, 150, getAngleTowardsPlayer(), Math.PI / 6, 0xE0BBE4);
        }, TweenType.Looping);
        addTween(spreadShotTimer, true);
    }
}
