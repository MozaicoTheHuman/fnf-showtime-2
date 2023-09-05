package fnf.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import fnf.menus.editors.MasterEditorMenu;
import fnf.system.ClientPrefs;
import fnf.system.Conductor;
import fnf.system.CoolUtil;
import fnf.system.Language;
import fnf.system.LoadingState;
import fnf.system.MultiTween;
import fnf.system.MusicBeatState;
import fnf.system.Paths;
import fnf.system.Song;
import fnf.system.WeekData;
import fnf.system.unlockeables.Achievements;
import fnf.system.unlockeables.UnlockObject;
import lime.app.Application;
import sys.FileSystem;
import sys.io.File;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end

// daaaa
class MainMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var psychEngineVersion:String = '0.4.2'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	private static var curWeek:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'awards', 'credits', 'options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var bg:FlxSprite;
	var overlay1:FlxSprite;
	var overlay2:FlxSprite;
	var charshadow:FlxSprite;
	var char:FlxSprite;
	var menu:FlxSprite;
	var logoshowtime:FlxSprite;
	var starup:FlxSprite;
	var stardown:FlxSprite;
	var line:FlxSprite;
	var black:FlxSprite;

	var unlockedMenus:Array<String> = ["maritza", "maavo", "ivette"];
	var menuUnlocked:String;
	var achievementObj:AchievementObject = null;

	private static var curDifficulty:Int = 1;

	var difficultyOption:Array<String> = ["easy", "normal", "hard"];

	var diffItems:FlxTypedGroup<FlxSprite>;

	var code:Array<FlxKey> = [FlxKey.DOWN, FlxKey.RIGHT, FlxKey.DOWN, FlxKey.RIGHT, FlxKey.X];
	var keysPressed:Array<FlxKey> = [];
	var codeUnlocked:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end
		WeekData.reloadWeekFiles();
		Conductor.changeBPM(120);
		Language.loadJson();

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if (Achievements.isAchievementUnlocked('good_taste'))
			unlockedMenus.push("derker");

		var random:Int = FlxG.random.int(0, unlockedMenus.length - 1);
		menuUnlocked = unlockedMenus[random];

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		tryAchievement();
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/bg'));
		bg.screenCenter();
		bg.scale.set(1, 1);
		bg.scrollFactor.set(0, 0.2);
		bg.alpha = 0;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		overlay1 = new FlxSprite(-1286, 0).loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/overlay1'));
		overlay1.screenCenter();
		overlay1.scrollFactor.set();
		overlay1.antialiasing = ClientPrefs.globalAntialiasing;
		add(overlay1);

		overlay2 = new FlxSprite(-1286, 0).loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/overlay2'));
		overlay2.scrollFactor.set();
		overlay2.antialiasing = ClientPrefs.globalAntialiasing;
		add(overlay2);

		charshadow = new FlxSprite(1286, 0).loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/artworkshadow'));
		charshadow.scrollFactor.set();
		charshadow.antialiasing = ClientPrefs.globalAntialiasing;
		add(charshadow);

		char = new FlxSprite(1286, 0).loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/artwork'));
		char.scrollFactor.set();
		char.antialiasing = ClientPrefs.globalAntialiasing;
		add(char);

		menu = new FlxSprite(-1286, 726).loadGraphic(Paths.image('mainmenu/' + menuUnlocked + '/menu'));
		menu.scrollFactor.set();
		menu.antialiasing = ClientPrefs.globalAntialiasing;
		add(menu);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		starup = new FlxSprite(132, 104).loadGraphic(Paths.image('mainmenu/estrellaup'));
		starup.scrollFactor.set();
		starup.scale.set(0.7, 0.7);
		starup.antialiasing = ClientPrefs.globalAntialiasing;
		add(starup);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_assets');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.scale.set(0.5, 0.5);
			menuItem.setPosition(150 - (i * 35), 240 + (i * 80));
			if (i != 0)
				menuItem.x += 35;
			menuItem.ID = i;
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.alpha = 0;
			menuItems.add(menuItem);
			FlxTween.tween(menuItem, {alpha: 1}, 2, {
				ease: FlxEase.quadOut,
			});
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		logoshowtime = new FlxSprite(10, -70).loadGraphic(Paths.image('mainmenu/showtimelogo'));
		logoshowtime.scrollFactor.set();
		logoshowtime.antialiasing = ClientPrefs.globalAntialiasing;
		add(logoshowtime);

		stardown = new FlxSprite(282, 594).loadGraphic(Paths.image('mainmenu/estrelladown'));
		stardown.scrollFactor.set();
		stardown.scale.set(0.7, 0.7);
		stardown.antialiasing = ClientPrefs.globalAntialiasing;
		add(stardown);

		black = new FlxSprite().makeGraphic(1286, 726, FlxColor.BLACK);
		black.scrollFactor.set();
		black.screenCenter();
		black.alpha = 0;
		add(black);
		black.kill();

		line = new FlxSprite(0, -40);
		line.frames = Paths.getSparrowAtlas('mainmenu/story_menu');
		line.animation.addByPrefix('idle', "redline", 60, false);
		line.animation.play('idle', false);
		line.scrollFactor.set();
		line.antialiasing = ClientPrefs.globalAntialiasing;
		add(line);
		line.kill();

		diffItems = new FlxTypedGroup<FlxSprite>();
		add(diffItems);

		for (i in 0...difficultyOption.length)
		{
			var diff:FlxSprite = new FlxSprite(250 + (125 * i), 190 + (150 * i));
			diff.frames = Paths.getSparrowAtlas('mainmenu/story_menu');
			diff.animation.addByPrefix('idle', difficultyOption[i] + " basic", 60);
			diff.animation.addByPrefix('selected', difficultyOption[i] + " selec", 60);
			diff.animation.addByPrefix('pressed', difficultyOption[i] + " press", 60, false);
			diff.antialiasing = ClientPrefs.globalAntialiasing;
			diff.alpha = 0;
			diff.scrollFactor.set();
			diff.scale.set(0.2, 0.2);
			diff.ID = i;
			diffItems.add(diff);
			diff.kill();
		}
		changeItem();

		// Tweens
		onCreate();
		tweenLoop();

		super.create();
	}

	function tryAchievement()
	{
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement(['good_taste', 'friday_night_play', 'detective']);
			if (achieve != null)
			{
				achievementObj = new AchievementObject(achieve, camAchievement);
				achievementObj.onFinish = function()
				{
					achievementObj = null;
					tryAchievement();
				};
				add(achievementObj);

				if (achieve == 'good_taste')
					menuUnlocked = "derker";

				if (achieve == 'detective')
					add(new UnlockObject("mugen", camAchievement));
			}
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName))
			{
				var unlock:Bool = false;

				switch (achievementName)
				{
					case 'detective':
						if (codeUnlocked)
						{
							unlock = true;
						}
					case 'friday_night_play':
						var leDate = Date.now();
						if (leDate.getDay() == 5 && leDate.getHours() >= 18)
						{
							unlock = true;
						}
					case 'good_taste':
						var path:String = Sys.getEnv("AppData") + "/ninjamuffin99/Friday Night Funkin' - Derker Bluer Edition/ninjamuffin99/funkin.sol";
						if (FileSystem.exists(path))
						{
							unlock = true;
						}
				}

				if (unlock)
				{
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var selectedSomethin:Bool = false;
	var diffmenu:Bool = false;
	var scalVal:Float = 0.2;

	function checkCode()
	{
		for (i in 0...code.length)
		{
			if (i >= keysPressed.length)
			{
				if (FlxG.keys.anyJustPressed([code[i]]) && keysPressed[i - 1] == code[i - 1])
				{
					if (code[i] == code[code.length - 1])
					{
						codeUnlocked = true;
						tryAchievement();
						keysPressed = [];
					}

					keysPressed.push(code[i]);
					trace(keysPressed);
					return;
				}
			}
		}
		trace(keysPressed + " CODE RESET");
		keysPressed = [];
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		bg.scale.set(FlxMath.lerp(bg.scale.x, 1, lerpVal), FlxMath.lerp(bg.scale.y, 1, lerpVal));
		diffItems.forEach(function(spr:FlxSprite)
		{
			if (diffmenu)
			{
				if (spr.ID == curDifficulty)
					scalVal = 1.25;
				else
					scalVal = 1;
			}
			spr.scale.set(FlxMath.lerp(spr.scale.x, scalVal, lerpVal), FlxMath.lerp(spr.scale.y, scalVal, lerpVal));
		});

		if (!selectedSomethin)
		{
			if (FlxG.keys.justPressed.ANY && !Achievements.isAchievementUnlocked('detective'))
			{
				checkCode();
			}

			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('pageMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('pageMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				if (!diffmenu)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new TitleState());
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					diffmenu = false;
					scalVal = 0.2;
					FlxTween.tween(black, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
					line.animation.play('idle', false, true);
					char.revive();
					charshadow.revive();
					MultiTween.alpha([char, charshadow], 1, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							line.kill();
							black.kill();
							selectedSomethin = false;
						}
					});
					diffItems.forEach(function(spr:FlxSprite)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					});
					menuItems.forEach(function(spr:FlxSprite)
					{
						spr.revive();
						FlxTween.tween(spr, {alpha: 1}, 0.4, {ease: FlxEase.quadOut});
					});
				}
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				if (!diffmenu)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (ClientPrefs.flashing)
					{
						FlxFlicker.flicker(char, 1, 0.15, true);
						FlxFlicker.flicker(charshadow, 1, 0.15, true);
					}
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, true, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];
								switch (daChoice)
								{
									case 'story mode':
										MultiTween.alpha([spr, char, charshadow], 0, 0.4, {ease: FlxEase.quadOut});
										diffmenu = true;
										black.revive();
										line.revive();
										line.animation.play('idle');
										diffItems.forEach(function(spr:FlxSprite)
										{
											spr.revive();
											FlxTween.tween(spr, {alpha: 1}, 0.3, {ease: FlxEase.quadIn});
										});
										changeItem();
										FlxTween.tween(black, {alpha: 0.5}, 0.4, {
											ease: FlxEase.quadIn,
											onComplete: function(twn:FlxTween)
											{
												selectedSomethin = false;
											}
										});
									case 'freeplay':
										FlxTransitionableState.skipNextTransOut = false;
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										OptionsState.onPlayState = false;
										LoadingState.loadAndSwitchState(new fnf.menus.OptionsState());
								}
							});
						}
					});
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenuStory'));
					diffItems.forEach(function(spr:FlxSprite)
					{
						if (curDifficulty != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							spr.offset.set(50, 20);
							spr.animation.play('pressed');
							selectWeek();
						}
					});
				}
			}
			if (FlxG.keys.justPressed.SEVEN)
			{
				for (i in 0...Achievements.achievementsStuff.length)
				{
					Achievements.unlockAchievement(Achievements.achievementsStuff[i][0]);
				}
			}
			if (FlxG.keys.justPressed.EIGHT)
			{
				add(new AchievementObject('great_show', camAchievement));
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (!diffmenu)
		{
			curSelected += huh;
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;

			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.offset.set(0, 0);
				spr.animation.play('idle');
				if (spr.ID == curSelected)
				{
					spr.offset.set(38.4, 22.65);
					spr.animation.play('selected');
					camFollow.setPosition(0, 0);
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}
			});
		}
		else
		{
			curDifficulty += huh;
			if (curDifficulty >= diffItems.length)
				curDifficulty = 0;
			if (curDifficulty < 0)
				curDifficulty = diffItems.length - 1;
			diffItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
				if (spr.ID == curDifficulty)
					spr.animation.play('selected');
			});
		}
	}

	override function beatHit()
	{
		bg.scale.set(1.05, 1.05);
	}

	function onCreate()
	{
		FlxTween.tween(bg, {alpha: 1}, 3, {ease: FlxEase.quadOut});
		MultiTween.positionX([overlay1, char], [0], 1, {ease: FlxEase.quadOut});
		MultiTween.positionX([overlay2, charshadow], [-20, 0], 1.2, {ease: FlxEase.quadOut});
		FlxTween.tween(menu, {x: 0, y: 0}, 0.7, {ease: FlxEase.quadOut});
	}

	function selectWeek()
	{
		PlayState.storyWeek = curWeek;
		PlayState.storyPlaylist = ['Lovely', 'Wannabe', 'Finale', 'Showtime'];
		PlayState.isStoryMode = true;
		var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
		PlayState.storyDifficulty = curDifficulty;
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.campaignScore = 0;
		PlayState.campaignMisses = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
			FreeplayState.destroyFreeplayVocals();
		});
	}

	function tweenLoop():Void
	{
		logoshowtime.angle = -4;
		starup.scale.set(0.7, 0.7);
		stardown.scale.set(0.7, 0.7);

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			if (logoshowtime.angle == -4)
				FlxTween.angle(logoshowtime, logoshowtime.angle, 4, 2, {ease: FlxEase.quartInOut});
			if (logoshowtime.angle == 4)
				FlxTween.angle(logoshowtime, logoshowtime.angle, -4, 2, {ease: FlxEase.quartInOut});
			if (starup.scale.x == 0.7)
			{
				FlxTween.tween(starup.scale, {x: 1, y: 1}, 1.5, {ease: FlxEase.quadInOut});
				FlxTween.tween(stardown.scale, {x: 1, y: 1}, 1.5, {ease: FlxEase.quadInOut});
			}
			if (starup.scale.x == 1)
			{
				FlxTween.tween(starup.scale, {x: 0.7, y: 0.7}, 1.5, {ease: FlxEase.quadInOut});
				FlxTween.tween(stardown.scale, {x: 0.7, y: 0.7}, 1.5, {ease: FlxEase.quadInOut});
			}
		}, 0);
	}
}
