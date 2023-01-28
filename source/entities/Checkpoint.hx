package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.GameScene;

class Checkpoint extends MiniEntity
{
    public var sprite:Spritemap;
    private var bossName:String;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "checkpoint";
        sprite = new Spritemap("graphics/checkpoint.png", 32, 64);
        sprite.add("idle", [0, 4, 8, 12, 8, 4], 12);
        sprite.add("flash", [1, 5, 9], 18, false);
        sprite.play("idle");
        setHitbox(32, 64);
        graphic = sprite;
        layer = -100;
    }

    public override function update() {
        collidable = !cast(HXP.scene, GameScene).isAnyBossActive();
        visible = collidable;
        if(sprite.complete) {
            sprite.play("idle");
        }
        super.update();
    }

    public function flash() {
        sprite.play("flash");
        cast(HXP.scene, GameScene).saveGame(this);
    }
}
