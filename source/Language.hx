package;

using StringTools;

class Language{

    public static var currentLanguage:String = "english";
    public static var languages:Array<String> = ['english','spanish'];

    public static function giveLan():String{
        //ClientPrefs.saveSettings();
        var st:String = 'eng';
        if (ClientPrefs.language == "english"){
            st = 'eng';
        }else{
            st = 'esp';
        }
        trace(st);
        return st;
    }


}