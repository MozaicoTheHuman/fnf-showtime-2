import flixel.graphics.FlxGraphic;
import sys.thread.Thread;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import sys.FileSystem;
import sys.io.File;

class SongPreload extends FlxState {

    var music = [];
    var loadText:FlxText;

    override public function create() {
        super.create();

        FlxG.mouse.visible = false;
        FlxG.camera.alpha = 0;

        FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {//this is if you guys want to add a bg image for this screen.
            onComplete: function(tween:FlxTween){//for now it will just be a black void.
                Thread.create(function(){
                    songsGenerate();
                });
            }
        });

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
        {
            music.push(i);
        }
    
        loadText = new FlxText(15, FlxG.height - (32 + 10), 0, 'Loading...', 32);
        loadText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadText);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    function songsGenerate() {
        for (i in music)
        {
            trace(i);
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
        }

        CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

        CoolUtil.precacheMusic('breakfast');

        FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, {//to go to titlestate
            onComplete: function(tween:FlxTween){
                FlxG.switchState(new TitleState());
            }
        });
    }
}