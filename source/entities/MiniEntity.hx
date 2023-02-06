package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class MiniEntity extends Entity
{
    public static var solids = ["walls", "platform"];

    public function new(x:Float, y:Float) {
        super(x, y);
    }

    private function isOnGround() {
        return collideAny(solids, x, y + 1) != null;
    }

    private function isOnCeiling() {
        return collideAny(solids, x, y - 1) != null;
    }

    private function isOnWall() {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall() {
        return collideAny(solids, x + 1, y) != null;
    }

    private function isOnLeftWall() {
        return collideAny(solids, x - 1, y) != null;
    }

    private function collideAny(types:Array<String>, virtualX:Float, virtualY:Float) {
        for(collideType in types) {
            var collided = collide(collideType, virtualX, virtualY);
            if(collided != null) {
                return collided;
            }
        }
        return null;
    }

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(player.centerY - centerY, player.centerX - centerX)
            + Math.PI / 2
        );
    }

    public function getAngleTowardsEntity(e:Entity) {
        return (
            Math.atan2(e.centerY - centerY, e.centerX - centerX)
            + Math.PI / 2
        );
    }

    public function getAngleTowardsPoint(v:Vector2) {
        return (
            Math.atan2(v.y - centerY, v.x - centerX)
            + Math.PI / 2
        );
    }

    private function explode() {
        var numExplosions = 50;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2 / numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count], 1, 1
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        scene.camera.shake(1, 4);
    }
}
