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
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var extra:FlxSprite;
	var effectFloor:FlxSprite;

	var lePlayState:PlayState;

	var songUnlocked:UnlockObject;

	private var camAchievement:FlxCamera;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	function resetGameOver()
	{
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;
		bf = new Boyfriend(x, y, characterName);
		add(bf);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case "light-on":
				extra.x = x - 700;
				extra.y = bf.getGraphicMidpoint().y;
			case "mugen":
				extra.x = x - 150;
				effectFloor.x = x - 300;
				effectFloor.y = y + 210;
				camFollow = new FlxPoint(650, 380);
			default:
				camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);
		}

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
	}

	override function create()
	{
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.add(camAchievement);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case "light-on":
				extra = new FlxSprite(1300, 400);
				extra.frames = Paths.getSparrowAtlas('lighton/victorydance', 'shared');
				extra.animation.addByPrefix('victorydance', "el baile del troleo0169", 60);
				extra.scale.set(3, 3);
				extra.animation.play('victorydance');
				add(extra);
			case "mugen":
				extra = new FlxSprite(1300, 400);
				extra.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				extra.animation.addByPrefix('ko', "keiou", 60);
				extra.animation.addByPrefix('continue', "continiu", 24, true);
				extra.antialiasing = ClientPrefs.globalAntialiasing;
				extra.scale.set(3, 3);
				extra.animation.play("ko");
				add(extra);

				effectFloor = new FlxSprite(1300, 400);
				effectFloor.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				effectFloor.animation.addByPrefix('waaa', "gameoverland", 60);
				effectFloor.antialiasing = ClientPrefs.globalAntialiasing;
				effectFloor.visible = false;
				add(effectFloor);
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if (updateCamera)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
			if (PlayState.SONG.song.toLowerCase() == "mugen")
			{
				FlxTween.tween(extra, {alpha: 0}, 0.2, {ease: FlxEase.linear});
			}
			resetGameOver();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new MainMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
			resetGameOver();
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if (PlayState.SONG.song.toLowerCase() == "mugen")
			{
				switch (bf.animation.curAnim.curFrame)
				{
					case 4:
						effectFloor.visible = true;
						effectFloor.animation.play("waaa");
					case 15:
						effectFloor.visible = false;
				}

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxTween.tween(extra, {alpha: 0}, 0.5, {ease: FlxEase.linear});
				});
			}
			else
			{
				if (bf.animation.curAnim.curFrame == 12)
				{
					FlxG.camera.follow(camFollowPos, LOCKON, 1);
					updateCamera = true;
				}
			}
			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (bf.animation.curAnim.name == 'deathLoop')
		{
			if (PlayState.SONG.song.toLowerCase() == "light-on")
			{
				if (extra.alpha == 0)
				{
					FlxTween.tween(extra, {alpha: 1}, 0.5, {ease: FlxEase.linear});
					FlxTween.tween(camFollow, {x: bf.x - 100}, 0.5, {ease: FlxEase.linear});
				}
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	#if ACHIEVEMENTS_ALLOWED
	function checkAchievement()
	{
		var checkThis:Array<String> = ['manco', 'no_hands', 'gane', 'telones'];
		for (i in 0...checkThis.length)
		{
			var achievementName:String = checkThis[i];
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
					achieveObj(achievementName);
				}
			}
		}
	}

	function achieveObj(achieve:String)
	{
		add(new AchievementObject(achieve, camAchievement));
		if (achieve == 'gane')
		{
			add(new UnlockObject("lighton", camAchievement));
		}
	}
	#end

	function coolStartDeath(?volume:Float = 1):Void
	{
		#if ACHIEVEMENTS_ALLOWED
		checkAchievement();
		#end
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
