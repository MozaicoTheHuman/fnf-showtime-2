package fnf.system.video;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import fnf.system.Language.SubtitleStructure;
import haxe.Json;
import openfl.OpenFLAssets;

class CutsceneSubstate extends MusicBeatSubstate
{
	var name:String;
	var videoPath:String;
	var callback:Void->Void;

	var video:VideoHandler;
	var spriteOut:FlxSprite;

	var skip:FlxSprite;

	var subsAlreadyShowed:Array<Float> = [];
	var subText:FlxText;

	var videoCamera:FlxCamera;
	var uiCamera:FlxCamera;

	public function new(name:String, endCallback:Void->Void)
	{
		super();
		this.name = name;
		videoPath = Paths.video(name);
		callback = endCallback;
	}

	public override function create()
	{
		super.create();

		// Cameras
		videoCamera = new FlxCamera();
		videoCamera.bgColor = 0;
		FlxG.cameras.add(videoCamera, false);

		uiCamera = new FlxCamera();
		uiCamera.bgColor = 0;
		FlxG.cameras.add(uiCamera, false);

		// VIDEO
		spriteOut = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		spriteOut.cameras = [videoCamera];
		spriteOut.antialiasing = ClientPrefs.globalAntialiasing;
		add(spriteOut);

		video = new VideoHandler(videoPath, spriteOut);
		video.finishCallback = close;
		video.spriteWidth = videoCamera.width;
		video.spriteHeight = videoCamera.height;
		cameras = [videoCamera];

		// UI

		skip = new FlxSprite(20).loadGraphic(Paths.image("skip"));
		skip.y = 0 - skip.height;
		skip.antialiasing = ClientPrefs.globalAntialiasing;
		skip.cameras = [uiCamera];
		add(skip);

		if (ClientPrefs.showSubs)
		{
			subText = new FlxText(50, 600, 1180, "", 32);
			subText.setFormat(Paths.font("arial.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			subText.scrollFactor.set();
			subText.borderSize = 2.4;
			subText.cameras = [uiCamera];
			add(subText);
		}
		video.playVideo(false, true);
	}

	var paused:Bool = false;
	var canPressNow:Bool = true;
	var skipTweem:FlxTween;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ClientPrefs.showSubs)
		{
			var subs:Array<SubtitleStructure> = Language.getSubtitles(name);
			for (i in 0...subs.length)
				if (itsTime(subs[i].time))
					newSubtitle(subs[i]);
		}

		if (canPressNow)
		{
			if (FlxG.keys.justPressed.ENTER && paused)
			{
				close();
			}
			else
			{
				if (FlxG.keys.justPressed.ANY)
				{
					canPressNow = false;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						canPressNow = true;
					});
					FlxG.sound.play(Paths.sound('pauseMenu'));
					if (!paused)
					{
						video.pause();
						skipTweem = FlxTween.tween(skip, {y: 20}, 0.5, {ease: FlxEase.cubeOut});
					}
					else
					{
						video.resume();
						if (skipTweem != null)
							skipTweem.cancel();
						skip.y = 0 - skip.height;
					}
					paused = !paused;
				}
			}
		}
	}

	function newSubtitle(sub:SubtitleStructure)
	{
		subsAlreadyShowed.push(sub.time);
		subText.text = sub.text;
		subText.screenCenter(Y);
		subText.y += 270;
	}

	function itsTime(check:Float):Bool
	{
		var time:Float = check * 1000;
		return video.bitmap.time >= time && !subsAlreadyShowed.contains(check);
	}

	override function close()
	{
		callback();
		super.close();
	}

	override function destroy()
	{
		FlxG.cameras.remove(videoCamera, true);
		FlxG.cameras.remove(uiCamera, true);
		super.destroy();
	}
}
