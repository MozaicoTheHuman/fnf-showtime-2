package fnf.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import fnf.system.ClientPrefs;
import fnf.system.Language;
import fnf.system.MusicBeatState;
import fnf.system.Paths;
import fnf.system.unlockeables.Achievements;
import fnf.system.visuals.Alphabet;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end

class AchievementsMenuState extends MusicBeatState
{
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;

	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;
	private var foto:Bool = false;
	private var fotosprite:FlxSprite;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length)
		{
			if (!Achievements.achievementsStuff[i][1] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][0]))
			{
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length)
		{
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][0];
			var optionText:Alphabet = new Alphabet(280, 300, Language.achievements[achievementIndex[i]].name, false);
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		fotosprite = new FlxSprite().loadGraphic(Paths.image('maavo2023'));
		fotosprite.scrollFactor.set();
		fotosprite.screenCenter();
		fotosprite.alpha = 0;
		add(fotosprite);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			if (foto != true)
				changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			if (foto != true)
				changeSelection(1);
		}
		if (controls.ACCEPT)
		{
			if (Achievements.isAchievementUnlocked('telones') && curSelected == 11)
			{
				foto = true;
				FlxTween.tween(fotosprite, {alpha: 1}, 0.3);
			}
		}
		if (controls.BACK)
		{
			if (foto != true)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(new MainMenuState());
			}
			else
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(fotosprite, {alpha: 0}, 0.3, {
					onComplete: function(twn:FlxTween)
					{
						foto = false;
					}
				});
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length)
		{
			achievementArray[i].alpha = 0.6;
			if (i == curSelected)
			{
				achievementArray[i].alpha = 1;
			}
		}
		descText.text = Language.achievements[curSelected].description;
	}
}
