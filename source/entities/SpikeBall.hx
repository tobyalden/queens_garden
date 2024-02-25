package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class SpikeBall extends MiniEntity
{
    public static inline var SPEED = 140;

    public var sprite:Image;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        type = "hazard";
        mask = new Hitbox(30, 30);
        sprite = Image.createRect(30, 30, 0xFF0F00);
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
    }

    override public function update() {
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = -velocity.x;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = -velocity.y;
        return true;
    }
}


