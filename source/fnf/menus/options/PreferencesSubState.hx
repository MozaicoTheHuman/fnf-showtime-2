package fnf.menus.options;

import fnf.system.Language;

class PreferencesSubState extends BaseOptionsMenu
{
	public function new()
	{
		translation = Language.options[2].options;
		title = Language.options[2].title;
		rpcTitle = Language.options[2].rpc;

		var option:Option = new Option(translation[0].name, translation[0].description, 'language', 'string', 'English', giveAllLan());
		option.onChange = onChangeLanguage;
		addOption(option);

		var option:Option = new Option(translation[1].name, translation[1].description, 'downScroll', 'bool', false);
		addOption(option);

		var option:Option = new Option(translation[2].name, translation[2].description, 'middleScroll', 'bool', false);
		addOption(option);

		var option:Option = new Option(translation[3].name, translation[3].description, 'ghostTapping', 'bool', true);
		addOption(option);

		var option:Option = new Option(translation[4].name, translation[4].description, 'noteQuant', 'bool', false);
		addOption(option);

		super();
	}

	function onChangeLanguage()
	{
		Language.loadJson();
		OptionsState.restartAlphabet();
		for (i in 0...optionsArray.length)
		{
			updateTextFrom(optionsArray[i]);
		}
	}

	function giveAllLan():Array<String>
	{
		var languagesList:Array<String> = [];
		for (i in 0...Language.languages.length)
		{
			languagesList.push(Language.languages[i][0]);
		}
		return languagesList;
	}
}
