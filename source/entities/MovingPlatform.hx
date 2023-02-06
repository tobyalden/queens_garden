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

class MovingPlatform extends MiniEntity
{
    public static inline var SPEED = 200;

    public var attached:Array<MiniEntity>;
    private var sprite:ColoredRect;
    private var path:LinearPath;

    public function new(x:Float, y:Float, width:Int, height:Int, pathPoints:Array<Vector2>) {
        super(x, y);
        type = "platform";
        mask = new Hitbox(width, height);
        sprite = new ColoredRect(width, height, 0xFF0000);
        graphic = sprite;
        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        attached = [];
    }

    override public function update() {
        var oldPosition = new Vector2(x, y);
        var player = cast(scene.getInstance("player"), Player);

        // Vertical movement
        var carryPlayer = (
            player.collideWith(this, player.x, player.y + 1) != null
            && player.collide("walls", player.x, player.y + 1) == null
        );
        moveTo(x, path.y);
        if(player.collideWith(this, player.x, player.y) != null && player.y < y) {
            carryPlayer = true;
        }
        if(carryPlayer) {
            player.moveTo(player.x, top - player.height);
        }
        else if(player.collideWith(this, player.x, player.y) != null) {
            player.moveTo(player.x, bottom);
        }

        // Horizontal movement
        carryPlayer = (
            player.collideWith(this, player.x, player.y + 1) != null
            && player.collide("walls", player.x, player.y + 1) == null
        );
        moveTo(path.x, y);
        if(carryPlayer) {
            player.moveBy(path.x - oldPosition.x, 0, "walls");
        }
        if(collideWith(player, x, y) != null) {
            if(centerX < player.centerX) {
                player.moveTo(right, player.y);
            }
            else if(centerX > player.centerX) {
                player.moveTo(left - player.width, player.y);
            }
        }

        for(e in attached) {
            e.moveBy(path.x - oldPosition.x, path.y - oldPosition.y);
        }

        super.update();
    }
}


