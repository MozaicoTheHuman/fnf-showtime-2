package fnf.menus.submenus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import fnf.system.Boyfriend;
import fnf.system.ClientPrefs;
import fnf.system.Conductor;
import fnf.system.CoolUtil;
import fnf.system.MusicBeatState;
import fnf.system.MusicBeatSubstate;
import fnf.system.Paths;
import fnf.system.unlockeables.Achievements;
import fnf.system.unlockeables.UnlockObject;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;

	var stageSuffix:String = "";

	var extra:FlxSprite;
	var effectFloor:FlxSprite;

	var lePlayState:PlayState;

	var songUnlocked:UnlockObject;

	private var camAchievement:FlxCamera;

	public static var characterName:String;
	public static var deathSoundName:String;
	public static var loopSoundName:String;
	public static var endSoundName:String;

	public static function setGameOver(char:String = 'bf', death:String = 'fnf_loss_sfx', loop:String = 'gameOver', end:String = 'gameOverEnd')
	{
		characterName = char;
		deathSoundName = death;
		loopSoundName = loop;
		endSoundName = end;
	}

	public function new(x:Float, y:Float, dadX:Float, dadY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;
		bf = new Boyfriend(x, y, characterName);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);
		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camFollow.x, camFollow.y);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);

		if (PlayState.isLightOn)
		{
			var martin:FlxSprite = new FlxSprite(dadX, dadY + 250);
			martin.frames = Paths.getSparrowAtlas('lighton/victorydance', 'shared');
			martin.animation.addByPrefix('dance', "el baile del troleo", 24, true);
			martin.animation.play('dance');
			martin.scale.set(3.2, 3.2);
			add(martin);
		}

		if (!PlayState.isMugen)
			FlxTween.tween(FlxG.camera, {zoom: 0.6}, 1.75, {ease: FlxEase.expoOut});
	}

	override function create()
	{
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.add(camAchievement);
		super.create();
	}

	var selectedSmthg:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.8, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSmthg)
		{
			if (controls.ACCEPT && !selectedSmthg)
			{
				selectedSmthg = true;
				endBullshit();
			}
			if (controls.BACK)
			{
				selectedSmthg = true;
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				if (PlayState.isStoryMode)
					MusicBeatState.switchState(new MainMenuState());
				else
					MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				lePlayState.callOnLuas('onGameOverConfirm', [false]);
			}
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName))
			{
				var unlock:Bool = false;
				switch (achievementName)
				{
					case 'manco':
						if (PlayState.deathCounter == 3)
						{
							unlock = true;
						}
					case 'no_hands':
						if (PlayState.deathCounter == 10)
						{
							unlock = true;
						}
					case 'gane':
						if (PlayState.SONG.song == "Lovely")
						{
							unlock = true;
						}
					case 'telones':
						if (Achievements.isAllUnlocked())
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

	var achievementObj:AchievementObject = null;

	function tryAchievement()
	{
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement(['manco', 'no_hands', 'gane', 'telones']);
			if (achieve != null)
			{
				achievementObj = new AchievementObject(achieve, camAchievement);
				achievementObj.onFinish = function()
				{
					achievementObj = null;
					tryAchievement();
				};
				add(achievementObj);

				if (achieve == 'gane')
					add(new UnlockObject("lighton", camAchievement));
			}
		}
	}

	function coolStartDeath(?volume:Float = 1):Void
	{
		#if ACHIEVEMENTS_ALLOWED
		tryAchievement();
		#end
		if (PlayState.isLightOn)
			camFollow.x = camFollow.x / 2;

		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		bf.playAnim('deathConfirm', true);
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.music(endSoundName));
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
			{
				MusicBeatState.resetState();
			});
		});
		lePlayState.callOnLuas('onGameOverConfirm', [true]);
	}
}
