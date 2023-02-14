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

class OneWayPlatform extends MiniEntity
{
    public function new(x:Float, y:Float, width:Int) {
        super(x, y);
        type = "oneway";
        mask = new Hitbox(width, 10);
        graphic = new ColoredRect(width, 10, 0x0000FF);
    }

    override public function update() {
        collidable = getPlayer().bottom <= top;
        super.update();
    }
}
