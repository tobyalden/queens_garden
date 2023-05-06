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
    //public static inline var PREDASH_TIME = 0.25;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "guard";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/guard.png");
        mask = new Hitbox(50, 50);
    }


    override function update() {
        super.update();
    }
}
