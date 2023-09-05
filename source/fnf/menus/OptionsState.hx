package fnf.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import fnf.menus.options.ControlsSubState;
import fnf.menus.options.NoteOffsetState;
import fnf.menus.options.PreferencesSubState;
import fnf.menus.options.VideoSubState;
import fnf.menus.options.VisualsSubState;
import fnf.system.ClientPrefs;
import fnf.system.Language;
import fnf.system.LoadingState;
import fnf.system.MusicBeatState;
import fnf.system.MusicBeatSubstate;
import fnf.system.Paths;
import fnf.system.visuals.Alphabet;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	static var options:Array<String> = [
		'Controls',
		'Video Settings',
		'Preferences',
		'Visuals Settings',
		'Offset and Combo'
	];

	private static var grpOptions:FlxTypedGroup<Alphabet>;
	public static var onPlayState:Bool = false;

	private static var curSelected:Int = 0;

	function goTo(label:String)
	{
		switch (label)
		{
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Video Settings':
				openSubState(new VideoSubState());
			case 'Preferences':
				openSubState(new PreferencesSubState());
			case 'Visuals Settings':
				openSubState(new VisualsSubState());
			case 'Offset and Combo':
				LoadingState.loadAndSwitchState(new NoteOffsetState());
		}
	}

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xffe74dff;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		restartAlphabet();
		changeSelection();

		ClientPrefs.saveSettings();

		super.create();
	}

	public static function restartAlphabet():Void
	{
		var curAlpha:Float = 1;
		for (i in 0...grpOptions.members.length)
		{
			var obj = grpOptions.members[0];
			curAlpha = obj.alpha;
			obj.kill();
			grpOptions.remove(obj, true);
			obj.destroy();
		}
		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 320, Language.options[i].name, true);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.changeX = false;
			optionText.distancePerItem.y = 150;
			optionText.targetY = i - curSelected;
			optionText.alpha = curAlpha;
			optionText.snapToPosition();
			grpOptions.add(optionText);
		}
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();

		for (item in grpOptions.members)
		{
			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else
				MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			if (options[curSelected] != "Offset and Combo")
			{
				for (item in grpOptions.members)
				{
					item.alpha = 0;
				}
			}
			goTo(options[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
