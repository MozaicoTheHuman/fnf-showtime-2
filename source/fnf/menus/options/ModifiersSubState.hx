package fnf.menus.options;

class ModifiersSubState extends BaseOptionsMenu
{
	public function new(x:Float, y:Float, fOM:Bool = true)
	{
		languageName = Language.options_sub_graphics_names;
		languageDesc = Language.options_sub_graphics_descriptions;

		title = Language.options_title_names[3];
		rpcTitle = Language.options_rpc[3];

		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', 'bool', true);
		addOption(option);

		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool', true);
		addOption(option);

		var option:Option = new Option('Dynamic Camera', "If checked, the camera will move in the note direction.", 'dynamicCamera', 'bool', true);
		addOption(option);

		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool', false);
		addOption(option);

		var option:Option = new Option('Hide Song Length', "If checked, the bar showing how much time is left\nwill be hidden.", 'hideTime', 'bool', false);
		addOption(option);

		super();
	}
}
