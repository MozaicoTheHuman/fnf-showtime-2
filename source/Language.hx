package;

import openfl.utils.Assets;
import haxe.format.JsonParser;
import haxe.Json;
using StringTools;
typedef LanguageData =
{
	var achievements:Array<String>;
	var achievements_desc:Array<String>;
    var achievements_song_unlock:Array<String>;
}
class Language{

    public static var currentLanguage:String = "English";
    public static var languages:Array<String> = ['English','Spanish'];
    public static var achievementsnames:Array<String> = ["",""];
    public static var achievementsdescnames:Array<String> = ["",""];
    public static var achievementsUnlockDesc:Array<String> = ["",""];

    public static function giveLan():String{
        //ClientPrefs.saveSettings();
        var st:String = 'eng';
        if (ClientPrefs.language == "English"){
            st = 'eng';
        }else{
            st = 'esp';
        }
        //trace(st);
        //trace(ClientPrefs.language);
        return st;
    }

    public static function startJson(){
        var path:String = Paths.getPreloadPath("languages/"+ giveLan() + ".json");
        var rawJson = Assets.getText(path);
        var languageData:LanguageData = Json.parse(rawJson);
        
        achievementsnames = languageData.achievements;
        achievementsdescnames = languageData.achievements_desc;
        achievementsUnlockDesc = languageData.achievements_song_unlock;
        //trace(rawJson);
        //trace(languageData.achievements);
    }

}