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

class Bull extends Boss {
    public static inline var GRAVITY = 800;

    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "bull";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/bull.png");
        mask = new Hitbox(50, 50);
        velocity = new Vector2();
    }

    private function attack() {}

    override function update() {
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }
}


