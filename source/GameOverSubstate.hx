package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var martin:Character;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var effect:FlxSprite;
	var effectsuelo:FlxSprite;

	var effectx:Float = 0;
	var effecty:Float = 0;

	var effectsuelox:Float = 0;
	var effectsueloy:Float = 0;

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var characterName2:String = 'victorydance';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var loopSoundName2:String = 'gameOverLightOn';
	public static var endSoundName2:String = 'gameOverLightOnEnd';

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		loopSoundName2 = 'gameOverLightOn';
		endSoundName2 = 'gameOverLightOnEnd';
	}
	override function create()
		{
			

			if (PlayState.SONG.song.toLowerCase() == "mugen")
			{
					
				effect = new FlxSprite(1300,400);
				effect.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				effect.animation.addByPrefix('ko', "keiou", 24);
				effect.animation.addByPrefix('continue', "continiu", 24, true);
				effect.antialiasing = ClientPrefs.globalAntialiasing;
				
				effectsuelo = new FlxSprite(1300,400);
				effectsuelo.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				effectsuelo.animation.addByPrefix('waaa', "gameoverland", 24);
				effectsuelo.antialiasing = ClientPrefs.globalAntialiasing;
				effectsuelo.visible = false;
				add(effectsuelo);
			}
			super.create();
		}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();


		Conductor.songPosition = 0;
		bf = new Boyfriend(x, y, characterName);
			add(bf);
	
		if (PlayState.SONG.song.toLowerCase() == "light-on")
		{
			martin = new Character(x, y, characterName2);
			martin.alpha = 0;
			add(martin);
	
			effectx = x - 700;
			effecty = bf.getGraphicMidpoint().y;
			effectsuelox = x - 100;
		}


		if (PlayState.SONG.song.toLowerCase() == "mugen")
		{
			effectsuelox = x - 300;
			effectsueloy = y + 210;

			effectx = x - 150;
			effecty = y - 250;
			camFollow = new FlxPoint(650,380);
		}
		else
		{
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);



		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
			if (PlayState.SONG.song.toLowerCase() == "mugen")
				{
					FlxTween.tween(effect,{alpha :0},0.2,{ease: FlxEase.linear});
				}
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
		}

		
		if (bf.animation.curAnim.name == 'firstDeath' && PlayState.SONG.song.toLowerCase() == "mugen")
			{
				add(effect);
				effect.scale.set(3, 3);
				effect.animation.play("ko");
				effectsuelo.x = effectsuelox;
				effectsuelo.y = effectsueloy;
				if(bf.animation.curAnim.curFrame == 4)
					{
						effectsuelo.visible = true;
						effectsuelo.animation.play("waaa");
					}
					if(bf.animation.curAnim.curFrame == 15)
						{
							effectsuelo.visible = false;
						}
		
					if (bf.animation.curAnim.finished)
					{
						
						coolStartDeath();
						bf.startedDeath = true;
					}
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							FlxTween.tween(effect,{alpha :0},0.5,{ease: FlxEase.linear});
						});
			
			}
			if (bf.animation.curAnim.name == 'firstDeath' && PlayState.SONG.song.toLowerCase() == "light-on")
				{
					
				
				}
			if (bf.animation.curAnim.name == 'firstDeath')
				{
					if(bf.animation.curAnim.curFrame == 12)
					{
						FlxG.camera.follow(camFollowPos, LOCKON, 1);
						updateCamera = true;
					}
		
					if (bf.animation.curAnim.finished)
					{
						coolStartDeath();
						bf.startedDeath = true;
					}
				}

		if (bf.animation.curAnim.name == 'deathLoop' && PlayState.SONG.song.toLowerCase() == "light-on")
		{
		    martin.playAnim('victorydance');
			martin.x = effectx;
		    martin.y = effecty;
			martin.scale.set(3.0, 3.0);
			FlxTween.tween(martin,{alpha : 1},0.5,{ease: FlxEase.linear});
		    FlxTween.tween(camFollow,{x : effectsuelox},0.5,{ease: FlxEase.linear});
		}
		if (bf.animation.curAnim.name == 'deathLoop' && PlayState.SONG.song.toLowerCase() == "mugen")
			{
				effect.alpha = 1;
				effect.scale.set(1, 1);
				effect.animation.play("continue");
				effect.x = effectx;
				effect.y = effecty;
				
			}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
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
}
