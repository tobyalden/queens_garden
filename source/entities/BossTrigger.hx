package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class BossTrigger extends MiniEntity
{
    public var bossNames(default, null):Array<String>;

    public function new(startX:Float, startY:Float, startWidth:Int, startHeight:Int, bossNames:String) {
        super(startX, startY);
        this.bossNames = bossNames.split(",");
        type = "bosstrigger";
        mask = new Hitbox(startWidth, startHeight);
        graphic = new ColoredRect(width, height, 0xFFFF00);
        graphic.alpha = 0.5;
    }

    override public function update() {
        if(collide("player", x, y) != null) {
            scene.remove(this);
            var gameScene = cast(HXP.scene, GameScene);
            var bossCheckpoint = new Vector2(x + width / 2 - 6, bottom - 48);
            for(bossName in bossNames) {
                gameScene.triggerBoss(bossName, bossCheckpoint);
            }
        }
        super.update();
    }
}
