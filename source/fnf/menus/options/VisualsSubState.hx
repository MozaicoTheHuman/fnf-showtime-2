package fnf.menus.options;

import fnf.system.Language;

class VisualsSubState extends BaseOptionsMenu
{
	public function new()
	{
		translation = Language.options[3].options;
		title = Language.options[3].title;
		rpcTitle = Language.options[3].rpc;

		var option:Option = new Option(translation[0].name, translation[0].description, 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option(translation[1].name, translation[1].description, 'noteSplashes', 'bool', true);
		addOption(option);

		var option:Option = new Option(translation[2].name, translation[2].description, 'camZooms', 'bool', true);
		addOption(option);

		var option:Option = new Option(translation[3].name, translation[3].description, 'dynamicCamera', 'bool', true);
		addOption(option);

		var option:Option = new Option(translation[4].name, translation[4].description, 'hideHud', 'bool', false);
		addOption(option);

		var option:Option = new Option(translation[5].name, translation[5].description, 'hideTime', 'bool', false);
		addOption(option);

		var option:Option = new Option(translation[6].name, translation[6].description, 'scoreZoom', 'bool', true);
		addOption(option);

		super();
	}
}
