package options;

class PreferencesSubState extends BaseOptionsMenu
{
	public function new()
	{
		languageName = Language.options_sub_preferences_names;
		languageDesc = Language.options_sub_preferences_descriptions;

		title = Language.options_title_names[2];
		rpcTitle = Language.options_rpc[2]; //for Discord Rich Presence

		var option:Option = new Option(languageName[0],
			languageDesc[0],
			'language',
			'string',
			'English',
			giveAllLan());
		addOption(option);
		
		var option:Option = new Option(languageName[1], //Name
			languageDesc[1], //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option(languageName[2],
			languageDesc[2],
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option(languageName[3],
			languageDesc[3],
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option(languageName[4],
			languageDesc[4],
			'noteQuant',
			'bool',
			false);
		addOption(option);

		super();
	}

	function giveAllLan():Array<String>{
		var languagesList:Array<String> = [];
		for(i in 0...Language.languages.length){
			languagesList.push(Language.languages[i][0]);
		}
		return languagesList;
	}
}