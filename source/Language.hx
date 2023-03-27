package;

import openfl.utils.Assets;
import haxe.format.JsonParser;
import haxe.Json;
using StringTools;

typedef LanguageData =
{
    //Todas las cosas traducibles (Json)
	var achievements_names:Array<String>;
	var achievements_descriptions:Array<String>;
    var achievements_song_unlock:Array<String>;
    var credits_categorys:Array<String>;
    var credits_descriptions:Array<String>;
    var options_names:Array<String>;
    var options_title_names:Array<String>;
    var options_rpc:Array<String>;
    var options_sub_controls_names:Array<String>;
    var options_sub_graphics_names:Array<String>;
    var options_sub_graphics_descriptions:Array<String>;
    var options_sub_preferences_names:Array<String>;
    var options_sub_preferences_descriptions:Array<String>;
    var options_sub_visuals_names:Array<String>;
    var options_sub_visuals_descriptions:Array<String>;
    var cutscene_text:Array<String>;
}

class Language{
    //Todos los idiomas disponibles
    public static var languages:Array<Dynamic> = [
        ['English', 'eng'],
        ['Spanish', 'esp']
    ];

    //El idioma actual
    public static var curLanguage:String = 'English';

    //Todas las cosas traducibles
    public static var achievements_names:Array<String> = [];
    public static var achievements_descriptions:Array<String> = [];
    public static var achievements_song_unlock:Array<String> = [];
    public static var credits_categorys:Array<String> = [];
    public static var credits_descriptions:Array<String> = [];
    public static var options_names:Array<String> = [];
    public static var options_title_names:Array<String> = [];
    public static var options_rpc:Array<String> = [];
    public static var options_sub_controls_names:Array<String> = [];
    public static var options_sub_graphics_names:Array<String> = [];
    public static var options_sub_graphics_descriptions:Array<String> = [];
    public static var options_sub_preferences_names:Array<String> = [];
    public static var options_sub_preferences_descriptions:Array<String> = [];
    public static var options_sub_visuals_names:Array<String> = [];
    public static var options_sub_visuals_descriptions:Array<String> = [];
    public static var cutscene_text:Array<String> = [];
    //Devuelve la abreviatura del lenguaje actual
    public static function giveLanguage():String{
        var fileName:String = '';
        for(i in 0...languages.length){
            if (ClientPrefs.language == languages[i][0]){
                trace('Current Language: ' + languages[i][0]);
                curLanguage = languages[i][0];
                fileName = languages[i][1];
            } 
        }
        return fileName;
    }

    //Carga el json del idioma correspondiente
    public static function loadJson(){
        var path:String = Paths.getPreloadPath("languages/"+ giveLanguage() + ".json");
        var rawJson = Assets.getText(path);
        var languageData:LanguageData = cast Json.parse(rawJson);
        
        achievements_names = languageData.achievements_names;
        achievements_descriptions = languageData.achievements_descriptions;
        achievements_song_unlock = languageData.achievements_song_unlock;
        credits_categorys = languageData.credits_categorys;
        credits_descriptions = languageData.credits_descriptions;
        options_names = languageData.options_names;
        options_title_names = languageData.options_title_names;
        options_rpc = languageData.options_rpc;
        options_sub_controls_names = languageData.options_sub_controls_names;
        options_sub_graphics_names = languageData.options_sub_graphics_names;
        options_sub_graphics_descriptions = languageData.options_sub_graphics_descriptions;
        options_sub_preferences_names = languageData.options_sub_preferences_names;
        options_sub_preferences_descriptions = languageData.options_sub_preferences_descriptions;
        options_sub_visuals_names = languageData.options_sub_visuals_names;
        options_sub_visuals_descriptions = languageData.options_sub_visuals_descriptions;
        cutscene_text = languageData.cutscene_text;
    }

}