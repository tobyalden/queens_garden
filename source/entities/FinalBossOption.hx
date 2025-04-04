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

class FinalBossOption extends MiniEntity {
    public var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "hazard";
        graphic = new Image("graphics/finalbossoption.png");
        mask = new Circle(25);
        velocity = new Vector2();
    }

    override public function update() {
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            MiniEntity.solids
        );
        velocity.y += Player.GRAVITY * HXP.elapsed;
        velocity.y = Math.min(velocity.y, Player.MAX_FALL_SPEED * 2);
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
