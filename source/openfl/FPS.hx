package openfl;

import flixel.FlxG;
import flixel.math.FlxMath;
import fnf.system.ClientPrefs;
import fnf.system.Conductor;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var infoType:String = 'Benchmark';

	public var currentFPS(default, null):Int;
	public var memoryPeak:Float = 0;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		textColor = 0xFFFFFFFF;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent)
		{
			switch (e.keyCode)
			{
				case #if web Keyboard.NUMBER_3 #else Keyboard.F3 #end: // 3 on web or F3 on windows, linux and other things that runs code
					infoType = infoType == 'Benchmark' ? 'Flixel' : 'Benchmark';
			}
		});
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		text = "FNF Showtime V2 Beta Build 0.1.2";
		text += '\n --- $infoType Info ---';
		switch (infoType)
		{
			case 'Benchmark':
				currentTime += deltaTime;
				times.push(currentTime);
				while (times[0] < currentTime - 1000)
				{
					times.shift();
				}
				var currentCount = times.length;
				currentFPS = Math.round((currentCount + cacheCount) / 2);
				if (currentFPS > ClientPrefs.framerate)
					currentFPS = ClientPrefs.framerate;
				text += '\nFPS: ${currentFPS} / ${ClientPrefs.framerate}';
				#if openfl
				var memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
				if (memoryMegas > memoryPeak)
					memoryPeak = memoryMegas;
				text += '\nMemory: ${FlxMath.roundDecimal(memoryMegas / 1024, 2)} GB / ${FlxMath.roundDecimal(memoryPeak / 1024, 2)} GB';
				#end

				if (currentFPS < 25 || memoryMegas > 3000)
					textColor = 0xFFFF0000;
				else
					textColor = 0xFFFFFFFF;

				if (currentCount != cacheCount)
					cacheCount = currentCount;
			case 'Flixel':
				@:privateAccess
				{
					var c:Int = 0;
					for (_ in FlxG.bitmap._cache.keys())
						c++;

					var objs = FlxG.state.members.length;

					text += '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}';
					text += '\nObjects: ${objs}';
					text += '\nCameras: ${FlxG.cameras.list.length}';
					text += '\nBitmaps: ${c}';
					text += '\nSounds: ${FlxG.sound.list.length}';
					text += '\nFlixel Childs: ${FlxG.game.numChildren}';

					if (objs > 100 || c > 800)
						textColor = 0xFFFF0000;
					else
						textColor = 0xFFFFFFFF;
				}
		}
		text += "\n";
	}
}
