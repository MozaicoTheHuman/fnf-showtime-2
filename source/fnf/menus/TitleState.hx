package fnf.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import fnf.system.ClientPrefs;
import fnf.system.Conductor;
import fnf.system.Highscore;
import fnf.system.Language;
import fnf.system.MusicBeatState;
import fnf.system.Paths;
import fnf.system.PlayerSettings;
import fnf.system.visuals.Alphabet;
import openfl.CacheManagement;
import openfl.MemoryManagement;
import openfl.OpenFLAssets;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
import sys.thread.Thread;
#end

class TitleState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; // This is also used for Discord RPC
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var logoSpr:FlxSprite;

	var curWacky:Array<String> = [];

	override public function create():Void
	{
		super.create();
		MemoryManagement.init();
		CacheManagement.init();

		FlxG.game.focusLostFramerate = 24;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.mouse.visible = false;

		PlayerSettings.init();
		curWacky = FlxG.random.getObject(getIntroTextShit());
		FlxG.save.bind('data', 'Mozaico');
		Highscore.load();
		Language.loadJson();

		if (FlxG.save.data.weekCompleted != null)
		{
			MainMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		var save:FlxSave = new FlxSave();
		save.bind('settings', 'Mozaico');

		if (save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
	}

	var logoBl:FlxSprite;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			if (FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(2, 0, 0.7);
			}
		}

		Conductor.changeBPM(120);
		persistentUpdate = true;

		var redbg:FlxSprite = new FlxSprite(0, 0);
		redbg.frames = Paths.getSparrowAtlas('titlescreen/bg');
		redbg.animation.addByPrefix('idle', "bg instance 1", 60);
		redbg.animation.play('idle');
		redbg.antialiasing = ClientPrefs.globalAntialiasing;

		var building:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('titlescreen/building'));
		var showWhite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('titlescreen/showteam white'));
		var showTeam:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('titlescreen/showteam'));

		logoBl = new FlxSprite(-13, -23);
		logoBl.frames = Paths.getSparrowAtlas('titlescreen/logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.updateHitbox();

		var pressstart:FlxSprite = new FlxSprite(0, 480);
		pressstart.frames = Paths.getSparrowAtlas('titlescreen/start');
		pressstart.animation.addByPrefix('idle', "start instance 1", 40);
		pressstart.animation.play('idle');
		pressstart.antialiasing = ClientPrefs.globalAntialiasing;

		add(redbg);
		add(building);
		add(showWhite);
		add(showTeam);
		add(logoBl);
		add(pressstart);

		FlxTween.tween(logoBl, {y: logoBl.y + 30}, 0.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.8));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = OpenFLAssets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}
		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter)
		{
			if (!skippedIntro)
			{
				skipIntro();
			}
			else
			{
				if (!transitioning)
				{
					if (titleText != null)
						titleText.animation.play('press');

					FlxG.camera.flash(FlxColor.WHITE, 1);
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

					transitioning = true;

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new MainMenuState());
						closedState = true;
					});
				}
			}
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
			logoBl.animation.play('bump');

		if (!closedState)
		{
			switch (curBeat)
			{
				case 1:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['In association', 'with'], -60);
				case 7:
					addMoreText('newgrounds', -60);
					logoSpr.visible = true;
				case 8:
					deleteCoolText();
					logoSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Friday');
				case 14:
					addMoreText('Night');
				case 15:
					addMoreText('Funkin');
				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);
			FlxG.camera.flash(FlxColor.WHITE, 2);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
