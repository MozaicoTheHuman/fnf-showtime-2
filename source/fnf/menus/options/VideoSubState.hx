package fnf.menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import fnf.system.ClientPrefs;
import fnf.system.Language;

class VideoSubState extends BaseOptionsMenu
{
	public function new()
	{
		translation = Language.options[1].options;
		title = Language.options[1].title;
		rpcTitle = Language.options[1].rpc;

		#if desktop
		var option:Option = new Option(translation[0].name, translation[0].description, 'resolution', 'string', '1280x720', getResList());
		option.onChange = onChangeResolution;
		addOption(option);
		#end

		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option(translation[1].name, translation[1].description, 'framerate', 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 290;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		#if !mobile
		var option:Option = new Option(translation[2].name, translation[2].description, 'showFPS', 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option(translation[3].name, translation[3].description, 'globalAntialiasing', 'bool', true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing;
		addOption(option);

		var option:Option = new Option(translation[4].name, translation[4].description, 'lowQuality', 'bool', false);
		addOption(option);

		super();
	}

	function getResList():Array<String>
	{
		var resListStrings:Array<String> = [];
		for (i in 0...ClientPrefs.resList.length)
		{
			resListStrings.push(ClientPrefs.resList[i][0]);
		}
		return resListStrings;
	}

	function onChangeResolution()
	{
		for (i in 0...ClientPrefs.resList.length)
		{
			if (ClientPrefs.resolution == ClientPrefs.resList[i][0])
			{
				if (ClientPrefs.resolution != "Full Screen")
				{
					if (FlxG.fullscreen)
						FlxG.fullscreen = false;
					FlxG.resizeWindow(ClientPrefs.resList[i][1], ClientPrefs.resList[i][2]);
					FlxG.resizeGame(ClientPrefs.resList[i][1], ClientPrefs.resList[i][2]);
				}
				else
				{
					FlxG.fullscreen = true;
				}
			}
		}
	}

	function onChangeFramerate()
	{
		if (ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}

	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; // Don't judge me ok
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}
}
