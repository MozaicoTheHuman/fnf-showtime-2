package fnf.system.video;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import hxcodec.vlc.VLCBitmap;
import openfl.Lib;
import openfl.events.Event;
import sys.FileSystem;

class VideoHandler
{
	public var path:String;
	public var bitmap:VLCBitmap;
	public var isVideoPlaying:Bool = false;

	public var sprite:FlxSprite;
	public var spriteWidth:Null<Int> = null;
	public var spriteHeight:Null<Int> = null;

	public var canUseSound:Bool = true;
	public var autoResize:Bool = false;
	public var pauseMusic:Bool = false;

	public var isPaused:Bool = false;

	public var openingCallback:Void->Void = null;
	public var finishCallback:Void->Void = null;

	public function new(path:String, ?sprite:FlxSprite = null):Void
	{
		this.path = path;
		this.sprite = sprite;
	}

	public function playVideo(loop:Bool = false, pauseMusic:Bool = false):Void
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		bitmap = new VLCBitmap();

		bitmap.onOpening = onVLCOpening;
		bitmap.onEndReached = onVLCEndReached;
		bitmap.onEncounteredError = onVLCEncounteredError;

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		FlxG.addChildBelowMouse(bitmap);

		if (FlxG.autoPause)
		{
			FlxG.signals.focusGained.add(resumeFocus);
			FlxG.signals.focusLost.add(pauseFocus);
		}

		// in case if you want to use another dir then the application one.
		// android can already do this, it can't use application's storage.
		if (FileSystem.exists(Sys.getCwd() + path))
			bitmap.play(Sys.getCwd() + path, loop);
		else
			bitmap.play(path, loop);

		if (sprite != null)
		{
			bitmap.alpha = 0;
		}
		isVideoPlaying = true;
	}

	private function onVLCOpening():Void
	{
		trace("the video is opening!");

		bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));

		if (openingCallback != null)
			openingCallback();
	}

	private function onVLCEndReached():Void
	{
		trace("the video reached the end!");

		bitmap.stop();

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();
		if (FlxG.stage.hasEventListener(Event.ENTER_FRAME))
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resumeFocus))
				FlxG.signals.focusGained.remove(resumeFocus);
			if (FlxG.signals.focusLost.has(pauseFocus))
				FlxG.signals.focusLost.remove(pauseFocus);
		}

		bitmap.dispose();

		if (FlxG.game.contains(bitmap))
		{
			FlxG.game.removeChild(bitmap);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	private function onVLCEncounteredError():Void
	{
		Lib.application.window.alert('Error cannot be specified', "VLC Error!");
		onVLCEndReached();
	}

	private function update(?E:Event):Void
	{
		if (sprite != null)
		{
			if (bitmap.isPlaying && bitmap.isDisplaying && bitmap.bitmapData != null)
			{
				var graphic:FlxGraphic = FlxG.bitmap.add(bitmap.bitmapData, false, bitmap.mrl);
				sprite.loadGraphic(graphic);
				sprite.setGraphicSize(spriteWidth, spriteHeight);
				sprite.updateHitbox();
			}
		}
		if (autoResize && (bitmap.videoWidth > 0 && bitmap.videoHeight > 0))
		{
			bitmap.width = calcSize(0);
			bitmap.height = calcSize(1);
		}

		bitmap.volume = Std.int((FlxG.sound.muted ? 0 : 1) * (FlxG.sound.volume * 100));
	}

	function pauseFocus():Void
	{
		if (!isPaused)
		{
			bitmap.pause();
		}
	}

	function resumeFocus():Void
	{
		if (!isPaused)
		{
			bitmap.resume();
		}
	}

	public function pause():Void
	{
		if (!isPaused)
		{
			bitmap.pause();
			isPaused = true;
		}
	}

	public function resume():Void
	{
		if (isPaused)
		{
			bitmap.resume();
			isPaused = false;
		}
	}

	public function calcSize(Ind:Int):Int
	{
		var appliedWidth:Float = Lib.current.stage.stageHeight * (FlxG.width / FlxG.height);
		var appliedHeight:Float = Lib.current.stage.stageWidth * (FlxG.height / FlxG.width);

		if (appliedHeight > Lib.current.stage.stageHeight)
			appliedHeight = Lib.current.stage.stageHeight;

		if (appliedWidth > Lib.current.stage.stageWidth)
			appliedWidth = Lib.current.stage.stageWidth;

		switch (Ind)
		{
			case 0:
				return Std.int(appliedWidth);
			case 1:
				return Std.int(appliedHeight);
		}

		return 0;
	}
}
