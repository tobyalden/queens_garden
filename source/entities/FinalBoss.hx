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

class FinalBoss extends Boss {
    public static inline var FLOWER_COOLDOWN = 1 / 2.5;

    private var attackOptions:Array<String>;
    private var attackIndex:Int;
    private var flowerCooldown:Alarm;
    private var flowerAngleOffset:NumTween;
    private var spawnedOption:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "queen";
        health = 100;
        startingHealth = health;
        graphic = new Image("graphics/finalboss.png");
        mask = new Hitbox(100, 100);
        attackOptions = ["flower"];
        attackIndex = 0;
        flowerCooldown = new Alarm(FLOWER_COOLDOWN);
        addTween(flowerCooldown);
        flowerAngleOffset = new NumTween(TweenType.PingPong);
        addTween(flowerAngleOffset);
        spawnedOption = false;
    }

    private function attack() {
        //var attackOption = attackOptions[attackIndex];
        //if(attackOption == "flower") {
            //flower();
        //}
        //else if(attackOption == "retreat") {
            //retreat();
        //}
        //attackIndex = increment(attackIndex, attackOptions.length);
        //if(attackIndex == 0) {
            //do { HXP.shuffle(attackOptions); } while (attackOptions[0] == attackOption);
        //};
        var numBullets = 2;
        spreadShot(
            numBullets,
            Math.PI * 2 / numBullets,
            {
                radius: 10,
                //angle: flowerAngleOffset.value,
                //speed: 250 / 1.5 + flowerAngleOffset.value * 10,
                angle: age,
                speed: 250 / 1.5,
                color: 0xFF0000,
                //gravity: Player.GRAVITY / 15,
            }
        );
        flowerCooldown.start();
    }

    override function update() {
        if(!spawnedOption) {
            var option = new FinalBossOption(x + 25, y + 25);
            option.velocity.setTo(150, -100);
            HXP.scene.add(option);
            var option2 = new FinalBossOption(x + 25, y + 25);
            option2.velocity.setTo(-150, -100);
            HXP.scene.add(option2);
            //var option3 = new FinalBossOption(x + 25, y + 25);
            //option3.velocity.setTo(200, -50);
            //HXP.scene.add(option3);
            //var option4 = new FinalBossOption(x + 25, y + 25);
            //option4.velocity.setTo(-200, -50);
            //HXP.scene.add(option4);

            var floorOption1 = new FinalBossOption(x + 25 - 400, y + 300);
            floorOption1.velocity.setTo(200, 0);
            HXP.scene.add(floorOption1);

            var floorOption2 = new FinalBossOption(x + 25 + 400, y + 300);
            floorOption2.velocity.setTo(-200, 0);
            HXP.scene.add(floorOption2);

            spawnedOption = true;
        }
        if(!flowerCooldown.active) {
            attack();
            if(!flowerAngleOffset.active) {
                flowerAngleOffset.tween(0, Math.PI * 2, 4, Ease.sineInOut);
            }
        }
        super.update();
    }
}
