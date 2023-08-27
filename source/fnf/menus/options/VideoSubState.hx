package fnf.menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import fnf.system.Character;
import fnf.system.ClientPrefs;
import fnf.system.Language;

class VideoSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;

	public function new()
	{
		translation = Language.options[1].options;
		title = Language.options[1].title;
		rpcTitle = Language.options[1].rpc;

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function(name:String) boyfriend.dance();
		boyfriend.visible = false;

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
		antialiasingOption = optionsArray.length - 1;

		var option:Option = new Option(translation[4].name, translation[4].description, 'lowQuality', 'bool', false);
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function getResList():Array<String>
	{
		var resListStrings:Array<String> = [];
		for (i in 0...ClientPrefs.resList.length)
		{
			var resString:String = ClientPrefs.resList[i][0] != "Full Screen" ? "x" + ClientPrefs.resList[i][1] : "";
			resListStrings.push(ClientPrefs.resList[i][0] + resString);
		}
		return resListStrings;
	}

	function onChangeResolution()
	{
		var resArr:Array<String> = getResList();
		for (i in 0...resArr.length)
		{
			if (ClientPrefs.resolution == resArr[i])
			{
				if (ClientPrefs.resolution != "Full Screen")
				{
					if (FlxG.fullscreen)
						FlxG.fullscreen = false;
					FlxG.resizeWindow(ClientPrefs.resList[i][0], ClientPrefs.resList[i][1]);
					FlxG.resizeGame(ClientPrefs.resList[i][0], ClientPrefs.resList[i][12]);
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
			var sprite:FlxSprite = cast sprite;
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
			{
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}
