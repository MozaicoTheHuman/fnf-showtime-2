package fnf.system;

import haxe.Json;
import openfl.OpenFLAssets;

using StringTools;

typedef AchievementStructure =
{
	var name:String;
	var description:String;
}

typedef CreditsStructure =
{
	var category:String;
	var part:Array<String>;
}

typedef OptionsMenuStructure =
{
	var name:String;
	var title:String;
	var rpc:String;
	@:optional var options:Array<OptionStructure>;
}

typedef OptionStructure =
{
	var name:String;
	@:optional var description:String;
}

typedef LanguageData =
{
	var achievements:Array<AchievementStructure>;
	var unlockguide:Array<String>;
	var credits:Array<CreditsStructure>;
	var options:Array<OptionsMenuStructure>;
	var cutscene:Array<String>;
}

class Language
{
	// All Avaiable Languages
	public static var languages:Array<Dynamic> = [['English', 'eng'], ['Spanish', 'esp']];
	public static var achievements:Array<AchievementStructure> = [];
	public static var unlockguide:Array<String> = [];
	public static var credits:Array<CreditsStructure> = [];
	public static var options:Array<OptionsMenuStructure> = [];
	public static var cutscene:Array<String> = [];

	public static function getLAN():String
	{
		var LAN:String = '';
		for (i in 0...languages.length)
		{
			if (ClientPrefs.language == languages[i][0])
			{
				LAN = languages[i][1];
			}
		}
		return LAN;
	}

	public static function loadJson()
	{
		var path:String = Paths.getPreloadPath('languages/language-${getLAN()}.json');
		var rawJson = OpenFLAssets.getText(path);
		var languageData:LanguageData = cast Json.parse(rawJson);

		achievements = languageData.achievements;
		unlockguide = languageData.unlockguide;
		credits = languageData.credits;
		options = languageData.options;
		cutscene = languageData.cutscene;
	}
}
