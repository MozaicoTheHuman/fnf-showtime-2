package fnf.system;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import fnf.menus.TitleState;
import fnf.system.Controls;

class ClientPrefs
{
	// Controls
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		// trace(defaultKeys);
	}

	// Graphics
	public static var resList:Array<Dynamic> = [
		  ["640x360", 640, 360],   ["768x432", 768, 432],     ["896x504", 896, 504],   ["1024x576", 1024, 576],   ["1152x648", 1152, 648],
		["1280x720", 1280, 720],
		["1366x768", 1366, 768], ["1600x900", 1600, 900], ["1920x1080", 1920, 1080], ["2560x1440", 2560, 1440], ["3840x2160", 3840, 2160],
		        ["Full Screen"]
	];
	public static var resolution:String = "1280x720";
	public static var framerate:Int = 60;
	public static var showFPS:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var lowQuality:Bool = false;

	// Preferences
	public static var language:String = "English";
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var noteQuant:Bool = false;

	// Visuals
	public static var flashing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var camZooms:Bool = true;
	public static var dynamicCamera:Bool = true;
	public static var hideHud:Bool = false;
	public static var hideTime:Bool = false;

	// Note Offset
	public static var noteOffset:Int = 0;
	public static var comboOffset:Array<Int> = [0, 0, 0, 0];

	private static var save:FlxSave = new FlxSave();

	public static function saveSettings()
	{
		// Achievements
		save.bind('achievements', 'Mozaico');
		save.data.achievementsMap = fnf.system.unlockeables.Achievements.achievementsMap;
		save.flush();

		// Controls
		save.bind('controls', 'Mozaico');
		save.data.customControls = keyBinds;
		save.flush();

		// Graphics
		save.bind('settings', 'Mozaico');
		save.data.resolution = resolution;
		save.data.framerate = framerate;
		save.data.showFPS = showFPS;
		save.data.globalAntialiasing = globalAntialiasing;
		save.data.lowQuality = lowQuality;

		// Preferences
		save.data.language = language;
		save.data.downScroll = downScroll;
		save.data.middleScroll = middleScroll;
		save.data.ghostTapping = ghostTapping;
		save.data.noteQuant = noteQuant;

		// Visuals
		save.data.flashing = flashing;
		save.data.noteSplashes = noteSplashes;
		save.data.camZooms = camZooms;
		save.data.dynamicCamera = dynamicCamera;
		save.data.hideHud = hideHud;
		save.data.hideTime = hideTime;

		// Note Offset
		save.data.noteOffset = noteOffset;
		save.data.comboOffset = comboOffset;
		save.flush();
		FlxG.save.flush();
	}

	public static function loadPrefs()
	{
		// Controls
		save.bind('controls', 'Mozaico');
		if (save != null && save.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls)
			{
				keyBinds.set(control, keys);
			}
			reloadControls();
		}

		// Graphics
		save.bind('settings', 'Mozaico');
		if (save.data.resolution != null)
		{
			resolution = save.data.resolution;

			for (i in 0...resList.length)
			{
				if (resolution == resList[i][0])
				{
					if (resolution != "Full Screen")
					{
						FlxG.resizeWindow(resList[i][1], resList[i][2]);
						FlxG.resizeGame(resList[i][1], resList[i][2]);
					}
					else
					{
						FlxG.fullscreen = true;
					}
				}
			}
		}
		if (save.data.framerate != null)
		{
			framerate = save.data.framerate;
			if (framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			}
			else
			{
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			}
		}
		if (save.data.showFPS != null)
		{
			showFPS = save.data.showFPS;
			if (Main.fpsVar != null)
			{
				Main.fpsVar.visible = showFPS;
			}
		}
		if (save.data.globalAntialiasing != null)
		{
			globalAntialiasing = save.data.globalAntialiasing;
		}
		if (save.data.lowQuality != null)
		{
			lowQuality = save.data.lowQuality;
		}

		// Preferences
		if (save.data.language != null)
		{
			language = save.data.language;
		}
		if (save.data.downScroll != null)
		{
			downScroll = save.data.downScroll;
		}
		if (save.data.middleScroll != null)
		{
			middleScroll = save.data.middleScroll;
		}
		if (save.data.ghostTapping != null)
		{
			ghostTapping = save.data.ghostTapping;
		}
		if (save.data.noteQuant != null)
		{
			noteQuant = save.data.noteQuant;
		}

		// Visuals
		if (save.data.flashing != null)
		{
			flashing = save.data.flashing;
		}
		if (save.data.noteSplashes != null)
		{
			noteSplashes = save.data.noteSplashes;
		}
		if (save.data.camZooms != null)
		{
			camZooms = save.data.camZooms;
		}
		if (save.data.dynamicCamera != null)
		{
			dynamicCamera = save.data.dynamicCamera;
		}
		if (save.data.hideHud != null)
		{
			hideHud = save.data.hideHud;
		}
		if (save.data.hideTime != null)
		{
			hideTime = save.data.hideTime;
		}

		// Note Offset
		if (save.data.noteOffset != null)
		{
			noteOffset = save.data.noteOffset;
		}
		if (save.data.comboOffset != null)
		{
			comboOffset = save.data.comboOffset;
		}

		// Sound
		if (FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}
	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
