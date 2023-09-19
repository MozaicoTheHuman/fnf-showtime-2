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
	var categorys:Array<String>;
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
	var credits:CreditsStructure;
	var options:Array<OptionsMenuStructure>;
	var cutscene:Array<String>;
	var score:Array<String>;
	var rating:Array<String>;
}

typedef SubtitleStructure =
{
	var time:Float;
	var text:String;
}

typedef SubtitlesData =
{
	var subtitles:Array<SubtitleStructure>;
}

class Language
{
	// All Avaiable Languages
	public static var languages:Array<Dynamic> = [['English', 'eng'], ['Spanish', 'esp'], ['Portuguese (Brazil)', 'pt'], ['French', 'fr'], ['French (Canada)', 'frc'], ['Danish', 'dk'], ['Japanese', 'jap']];
	public static var achievements:Array<AchievementStructure> = [];
	public static var unlockguide:Array<String> = [];
	public static var credits:CreditsStructure = {
		categorys: [],
		part: []
	};
	public static var options:Array<OptionsMenuStructure> = [];
	public static var cutscene:Array<String> = [];
	public static var score:Array<String> = [];
	public static var rating:Array<String> = [];
	public static var subtitles:Array<SubtitleStructure> = [];

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
		score = languageData.score;
		rating = languageData.rating;
	}

	public static function getSubtitles(name:String):Array<SubtitleStructure>
	{
		var path:String = Paths.getPreloadPath('languages/subtitles/$name-${getLAN()}.json');
		var rawJson = OpenFLAssets.getText(path);
		var subsData:SubtitlesData = cast Json.parse(rawJson);
		return subsData.subtitles;
	}
}
