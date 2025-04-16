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

class FinalBossTeleportTell extends Boss {
    public function new(x:Float, y:Float, duration:Float) {
        super(x, y);
        graphic = new Image("graphics/finalboss.png");
        graphic.alpha = 0.5;
        HXP.alarm(duration, function() {
            HXP.scene.remove(this);
        });
    }
}
