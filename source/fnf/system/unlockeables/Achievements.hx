package fnf.system.unlockeables;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import openfl.OpenFLAssets;

using StringTools;

class Achievements
{
	public static var achievementsStuff:Array<Dynamic> = [
		// Name, Description, ID Name, Hidden achievement
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'great_show', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'expert', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'detective', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'perfect', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'manco', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'no_hands', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'gane', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'perfeccionist', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'sick', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'telones', false],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'friday_night_play', true],
		["NAME IN LANGUAGE FILE", "DESC IN LANGUAGE FILE", 'good_taste', true]
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static function unlockAchievement(name:String):Void
	{
		FlxG.log.add('Completed achievement "$name"');
		achievementsMap.set(name, true);
		ClientPrefs.saveSettings();
		if (name == 'good_taste')
			FlxG.sound.play(Paths.sound('secretSound'), 0.7);
		else
			FlxG.sound.play(Paths.sound('awardMenu'), 0.7);
	}

	public static function getAchievementImage(name:String):flixel.graphics.FlxGraphic
	{
		var image:flixel.graphics.FlxGraphic = Paths.image('achievements/placeholder');
		if (Paths.fileExists('images/achievements/$name.png', IMAGE))
		{
			image = Paths.image('achievements/$name');
		}
		return image;
	}

	public static function isAchievementUnlocked(name:String)
	{
		if (achievementsMap.exists(name) && achievementsMap.get(name))
		{
			return true;
		}
		return false;
	}

	public static function isAllUnlocked():Bool
	{
		for (i in 0...achievementsStuff.length)
		{
			if (!achievementsMap.exists(achievementsStuff[i][2]) && i < 9)
			{
				return false;
			}
		}
		return true;
	}

	public static function getAchievementIndex(name:String)
	{
		for (i in 0...achievementsStuff.length)
		{
			if (achievementsStuff[i][2] == name)
			{
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void
	{
		var save:FlxSave = new FlxSave();
		save.bind('achievements', 'Mozaico');

		if (save.data != null && save.data.achievementsMap != null)
			achievementsMap = save.data.achievementsMap;
	}
}

class AttachedAchievement extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var tag:String;

	public function new(x:Float = 0, y:Float = 0, name:String)
	{
		super(x, y);

		changeAchievement(name);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function changeAchievement(tag:String)
	{
		this.tag = tag;
		reloadAchievementImage();
	}

	public function reloadAchievementImage()
	{
		if (Achievements.isAchievementUnlocked(tag))
			loadGraphic(Achievements.getAchievementImage(tag));
		else
			loadGraphic(Paths.image('achievements/lockedachievement'));

		scale.set(0.7, 0.7);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;

	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Achievements.getAchievementIndex(name);

		var achievementBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(400, 100, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementName:FlxText = new FlxText(achievementBG.x + 20, achievementBG.y + 26, 280, Language.achievements[id].name, 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 28, 280, Language.achievements[id].description, 16);
		achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(0, achievementBG.y).loadGraphic(Achievements.getAchievementImage(name));
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.x = achievementBG.x + achievementBG.width - achievementIcon.width + 80;
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}
		y -= 120;
		x = FlxG.width / 2 - width / 2;
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1, y: 0}, 0.5, {
			onComplete: function(twn:FlxTween)
			{
				alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
					startDelay: 3,
					onComplete: function(twn:FlxTween)
					{
						alphaTween = null;
						remove(this);
						if (onFinish != null)
							onFinish();
					}
				});
			}
		});
	}

	override function destroy()
	{
		if (alphaTween != null)
		{
			alphaTween.cancel();
		}
		super.destroy();
	}
}
