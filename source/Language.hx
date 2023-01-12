package;

using StringTools;

class Language{

    public static var currentLanguage:String = "English";
    public static var languages:Array<String> = ['English','Spanish'];

    public static function giveLan():String{
        //ClientPrefs.saveSettings();
        var st:String = 'eng';
        if (ClientPrefs.language == "English"){
            st = 'eng';
        }else{
            st = 'esp';
        }
        trace(st);
        return st;
    }


}