package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Hurtbox extends MiniEntity
{
    public var sprite:Image;
    public var duration:Float;
    public var delay:Float;

    public function new(x:Float, y:Float, width:Int, height:Int, delay:Float, duration:Float) {
        super(x, y);
        trace('adding hitbox at ${x}, ${y}');
        type = "hazard";
        this.duration = duration + delay;
        this.delay = delay;
        mask = new Hitbox(width, height);
        sprite = Image.createRect(width, height, 0xFF0000);
        sprite.alpha = 0.5;
        collidable = false;
        graphic = sprite;
    }

    override public function update() {
        duration -= HXP.elapsed;
        delay -= HXP.elapsed;
        if(delay <= 0) {
            sprite.alpha = 1;
            collidable = true;
        }
        if(duration <= 0) {
            HXP.scene.remove(this);
        }
        super.update();
    }
}

