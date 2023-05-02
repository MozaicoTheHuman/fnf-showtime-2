package fnf.system;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#else
import openfl.OpenFLAssets;
#end
import fnf.system.Song;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef StageFile =
{
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
}

class StageData
{
	public static var forceNextDirectory:String = null;

	public static function loadDirectory(SONG:SwagSong)
	{
		var stage:String = '';
		if (SONG.stage != null)
		{
			stage = SONG.stage;
		}
		else if (SONG.song != null)
		{
			switch (SONG.song.toLowerCase().replace(' ', '-'))
			{
				case 'lovely' | 'wannabe' | 'finale' | 'showtime':
					stage = 'show';
				case 'pondering':
					stage = 'ponderingmall';
				case 'light-on':
					stage = 'callejon';
				case 'mugen':
					stage = 'kfm';
				default:
					stage = 'void';
			}
		}
		else
		{
			stage = 'void';
		}

		var stageFile:StageFile = getStageFile(stage);
		if (stageFile == null)
		{ // preventing crashes
			forceNextDirectory = '';
		}
		else
		{
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile
	{
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('stages/' + stage + '.json');

		#if MODS_ALLOWED
		var modPath:String = Paths.modFolders('stages/' + stage + '.json');
		if (FileSystem.exists(modPath))
		{
			rawJson = File.getContent(modPath);
		}
		else if (FileSystem.exists(path))
		{
			rawJson = File.getContent(path);
		}
		#else
		if (OpenFLAssets.exists(path))
		{
			rawJson = OpenFLAssets.getText(path);
		}
		#end
	else
	{
		return null;
	}
		return cast Json.parse(rawJson);
	}
}
