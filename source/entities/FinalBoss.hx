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

class FinalBoss extends Boss {
    //public static inline var GRAVITY = 800;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "queen";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/finalboss.png");
        mask = new Hitbox(100, 100);
    }

    override function update() {
        super.update();
    }
}
