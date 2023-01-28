package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class GraphicsSubState extends BaseOptionsMenu
{
	public function new()
	{
		languageName = Language.options_sub_graphics_names;
		languageDesc = Language.options_sub_graphics_descriptions;
		
		title = Language.options_title_names[1];
		rpcTitle = Language.options_rpc[1]; //for Discord Rich Presence

		#if desktop
		var option:Option = new Option(languageName[0],
			languageDesc[0],
			'fullScreen',
			'bool',
			false
		);
		option.onChange = onChangeFullscreen;
		addOption(option);

		var option:Option = new Option(languageName[1],
			languageDesc[1],
			'resolution',
			'string',
			'1280x720',
			getResList()
		);
		option.onChange = onChangeResolution;
		addOption(option);
		#end

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option(languageName[2],
			languageDesc[2],
			'framerate',
			'int',
			60
		);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 290;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		#if !mobile
		var option:Option = new Option(languageName[3],
			languageDesc[3],
			'showFPS',
			'bool',
			true
		);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option(languageName[4],
			languageDesc[4],
			'globalAntialiasing',
			'bool',
			true
		);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; 
		addOption(option);

		var option:Option = new Option(languageName[5], //Name
			languageDesc[5], //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false
		); //Default value
		addOption(option);

		super();
	}
	
	function getResList():Array<String>{
		var resListStrings:Array<String> = [];
		for(i in 0...ClientPrefs.resList.length){
			resListStrings.push(ClientPrefs.resList[i][0]);
		}
		return resListStrings;
	}

	function onChangeFullscreen(){
		FlxG.fullscreen = ClientPrefs.fullScreen;
	}

	function onChangeResolution(){
		for(i in 0...ClientPrefs.resList.length){
			if(ClientPrefs.resolution == ClientPrefs.resList[i][0]){
				if(!ClientPrefs.fullScreen)
					FlxG.resizeWindow(ClientPrefs.resList[i][1], ClientPrefs.resList[i][2]);

				FlxG.resizeGame(ClientPrefs.resList[i][1], ClientPrefs.resList[i][2]);
			}
		}
	}

	function onChangeFramerate(){
		if(ClientPrefs.framerate > FlxG.drawFramerate){
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}

	function onChangeFPSCounter(){
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}

	function onChangeAntiAliasing(){
		for (sprite in members){
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

}