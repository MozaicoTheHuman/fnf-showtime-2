package fnf;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import fnf.menus.FreeplayState;
import fnf.menus.MainMenuState;
import fnf.menus.editors.CharacterEditorState;
import fnf.menus.editors.ChartingState;
import fnf.menus.options.*;
import fnf.menus.submenus.*;
import fnf.system.Boyfriend;
import fnf.system.Character;
import fnf.system.ClientPrefs;
import fnf.system.Conductor;
import fnf.system.CoolUtil;
import fnf.system.FunkinLua;
import fnf.system.Highscore;
import fnf.system.Language;
import fnf.system.LoadingState;
import fnf.system.MusicBeatState;
import fnf.system.Note;
import fnf.system.Paths;
import fnf.system.Section.SwagSection;
import fnf.system.Song.SwagSong;
import fnf.system.Song;
import fnf.system.StageData.StageFile;
import fnf.system.StageData;
import fnf.system.StrumNote;
import fnf.system.WeekData;
import fnf.system.unlockeables.*;
import fnf.system.unlockeables.Achievements.AchievementObject;
import fnf.system.visuals.*;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end
#if VIDEOS_ALLOWED
import fnf.system.video.*;
#end
#if sys
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	// Dynamic Camera Variables
	var camX:Int = 0;
	var camY:Int = 0;
	var bfcamX:Int = 0;
	var bfcamY:Int = 0;
	var camMvmntSpd:Int = 30;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public var boyfriend2:Boyfriend;

	var dadEventChar:Character;
	var bfEventChar:Character;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;

	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:FlxSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;

	private var startingSong:Bool = false;
	private var updateTime:Bool = false;

	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camSubs:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var subsAlreadyShowed:Array<Int> = [];
	var subText:FlxText;
	var subs:Array<SubtitleStructure> = [];

	var maavoBopper:BGSprite;
	var maritzaDancer:BGDancer;
	var heyTimer:Float;

	var vfx:FlxSprite;
	var bgM:FlxSprite;
	var maavoportrait:FlxSprite;

	var vfxR:FlxSprite;
	var ronalportrait:FlxSprite;
	var dissapearTime:FlxTimer = null;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignPercent:Float = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	public var inCutscene:Bool = false;

	var finishedText:Bool = true;
	var textIntro:FlxText;
	var textDiscard:FlxSprite;
	var lastTextDiscard:FlxSprite;
	var bgIntro:FlxSprite;
	var curPage:Int = 0;
	var triangleText:FlxSprite;

	public static var isLightOn:Bool = false;
	public static var isTokyo:Bool = false;
	public static var isMugen:Bool = false;

	var lan:String;
	// Tokyo
	var tokyoSprite:FlxSprite;
	#if VIDEOS_ALLOWED
	var tokyoVideo:VideoHandler;
	#end

	var songLength:Float = 0;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var notesDir = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'idle'];

	// MATRICULASO
	private var luaArray:Array<FunkinLua> = [];

	// Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public static var instance:PlayState;

	public var songUiFolder:String = '';

	var introSprites:Array<String> = [null, 'ready', "set", "go"];
	var introSounds:Array<String> = ["intro3", "intro2", "intro1", "introGo"];

	public static var goTo:String = null;

	var timesStunned:Int = 0;
	var stunTimer:FlxTimer = null;

	override public function create()
	{
		Paths.clearStoredMemory();

		goTo = null;
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camSubs = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSubs.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSubs);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		isLightOn = SONG.song.toLowerCase() == "light-on";
		isTokyo = SONG.song.toLowerCase() == "tokyo";
		isMugen = SONG.song.toLowerCase() == "mugen";

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		var songName:String = Paths.formatToSongPath(SONG.song);
		curStage = PlayState.SONG.stage;
		if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
			curStage = 'show';

		var dataValue:String = curStage;

		if (curStage == 'show')
		{
			switch (SONG.song)
			{
				case 'Lovely':
					dataValue = 'maritzaShow';
				case 'Wannabe':
					dataValue = 'maavoShow';
				case 'Finale':
					dataValue = 'ivetteShow';
				default:
					dataValue = curStage;
			}
		}

		var stageData:StageFile = StageData.getStageFile(dataValue);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100]
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		GameOverSubstate.setGameOver();
		switch (curStage)
		{
			case 'show':
				var sky:BGSprite = new BGSprite('show/bgSky', -1000, -750, 0.2, 0.2);
				add(sky);

				if (!ClientPrefs.lowQuality)
				{
					var buildings:BGSprite = new BGSprite('show/BuildingsOne', -1000, -750, 0.5, 0.5);
					add(buildings);
					var buildingsT:BGSprite = new BGSprite('show/BuildingsTwo', -1000, -750, 0.65, 0.65);
					add(buildingsT);
				}

				var stage:BGSprite = new BGSprite('show/bg', -1300, -750);
				add(stage);

				if (!ClientPrefs.lowQuality)
				{
					var changes:Array<String> = ["Lovely", "Wannabe", "Finale"];
					for (i in 0...changes.length)
					{
						if (changes[i] == SONG.song)
						{
							if (changes[i] != "Wannabe")
							{
								if (changes[i] == "Lovely") // Lovely Maavo
									maavoBopper = new BGSprite('show/MaavoWait', -159, 60, 1, 1, ['MaavoWait']);
								else // Finale Maavo
									maavoBopper = new BGSprite('show/MaavoFINALE', -600, 60, 1, 1, ['FinaleIDLE']);

								maavoBopper.updateHitbox();
								maavoBopper.antialiasing = ClientPrefs.globalAntialiasing;
								add(maavoBopper);
							}
							if (changes[i] != "Finale")
							{
								var ivette:FlxSprite = new FlxSprite(-600, 205);
								ivette.frames = Paths.getSparrowAtlas('show/IvetteWait');
								ivette.animation.addByPrefix('idle', "IvetteWait", 24);
								ivette.animation.play('idle');
								ivette.antialiasing = ClientPrefs.globalAntialiasing;
								add(ivette);
							}
						}
					}
				}
			case 'ponderingmall': // Pondering
				GameOverSubstate.setGameOver('maavo-playable', 'fnf_loss_maavo');

				var sky:BGSprite = new BGSprite('mall/bgWalls', -1400, -1385, 0.7, 0.7);
				sky.setGraphicSize(Std.int(sky.width * 1.4));
				sky.updateHitbox();
				add(sky);

				var mall:BGSprite = new BGSprite('mall/fgSnow', -1400, -1385, 1, 1);
				mall.setGraphicSize(Std.int(mall.width * 1.4));
				mall.updateHitbox();
				add(mall);
			case 'ponderingmall2': // Pondering
				GameOverSubstate.setGameOver('maavo-playable', 'fnf_loss_maavo');

				var bg:BGSprite = new BGSprite('mall/Showtime_mall_night_sky', -1400, -1385, 0.7, 0.7);
				bg.setGraphicSize(Std.int(bg.width * 1.4));
				bg.updateHitbox();
				add(bg);

				var bgEscalator:BGSprite = new BGSprite('mall/Showtime_mall_night_nose_pero_lo_del_stage', -1400, -1385, 1, 1);
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 1.4));
				bgEscalator.updateHitbox();
				add(bgEscalator);
			case 'callejon': // Light On
				GameOverSubstate.setGameOver('maavo-playableL-GAMEOVER', 'fnf_loss_maavomaritza', 'gameOverLightOn', 'gameOverLightOnEnd');

				var sky:BGSprite = new BGSprite('lighton/sky', -500, -290, 0.7, 0.7);
				sky.setGraphicSize(Std.int(sky.width * 1.1));
				sky.updateHitbox();
				add(sky);

				var bg:BGSprite = new BGSprite('lighton/bg', -500, -130, 0.95, 0.95);
				bg.setGraphicSize(Std.int(bg.width * 1.1));
				add(bg);

				var trash:BGSprite = new BGSprite('lighton/trash', -1030, -130, 1.3, 1.3);
				trash.setGraphicSize(Std.int(trash.width * 1.2));
				trash.updateHitbox();
				add(trash);

				var trashT:BGSprite = new BGSprite('lighton/trashTwo', -400, -130, 1.3, 1.3);
				trashT.setGraphicSize(Std.int(trashT.width * 1.2));
				trashT.updateHitbox();
				add(trashT);
			case 'kfm':
				GameOverSubstate.setGameOver('maavomugen', 'fnf_loss_mugen');

				var skyyyy:FlxSprite = new FlxSprite(-800, -350).loadGraphic(Paths.image('kfm/stageblissKFM', 'shared'));
				skyyyy.active = false;
				skyyyy.scrollFactor.set(0.7, 0.8);
				skyyyy.setGraphicSize(Std.int(skyyyy.width * 1.2));
				skyyyy.updateHitbox();
				add(skyyyy);

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('kfm/stagebackKFM', 'shared'));
				bg.setGraphicSize(Std.int(bg.width * 1.2));
				bg.active = true;
				add(bg);

				bgM = new FlxSprite(-516, -310);
				bgM.scale.set(4.2, 4);
				bgM.alpha = 0;
				bgM.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				bgM.animation.addByPrefix('effect', "bg", 60, true);
				bgM.animation.play('effect');
				bgM.antialiasing = ClientPrefs.globalAntialiasing;
				bgM.updateHitbox();
				add(bgM);

				maavoportrait = new FlxSprite(670, 0);
				maavoportrait.flipX = true;
				maavoportrait.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				maavoportrait.animation.addByPrefix('wow', "SSBUportrait", 60, false);
				maavoportrait.alpha = 0;
				maavoportrait.antialiasing = ClientPrefs.globalAntialiasing;
				maavoportrait.cameras = [camHUD];
				add(maavoportrait);

				ronalportrait = new FlxSprite(0, 124);
				ronalportrait.scale.set(1.6, 1.6);
				ronalportrait.updateHitbox();
				ronalportrait.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				ronalportrait.animation.addByPrefix('clown', "hyperportrait", 60, false);
				ronalportrait.alpha = 0;
				ronalportrait.antialiasing = false;
				ronalportrait.cameras = [camHUD];
				add(ronalportrait);

				vfx = new FlxSprite(0, 0);
				vfx.scale.set(3, 3);
				vfx.alpha = 0;
				vfx.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				vfx.animation.addByPrefix('punch', "maavohit", 60, false);
				vfx.animation.play('punch');
				vfx.antialiasing = ClientPrefs.globalAntialiasing;
				vfx.centerOrigin();
				vfx.updateHitbox();
				add(vfx);

				vfxR = new FlxSprite(0, 0);
				vfxR.scale.set(3, 3);
				vfxR.alpha = 0;
				vfxR.frames = Paths.getSparrowAtlas('kfm/gfx', 'shared');
				vfxR.animation.addByPrefix('punchR', "ronaldhit1", 60, false);
				vfxR.animation.addByPrefix('punchR2', "ronaldhit2", 60, false);
				vfxR.animation.addByPrefix('spark', "hyperspark", 60, true);
				vfxR.animation.play('spark');
				vfxR.antialiasing = ClientPrefs.globalAntialiasing;
				vfxR.updateHitbox();
				add(vfxR);
			case 'void': // Tokyo y la otra cancion secreta
				GameOverSubstate.setGameOver('maavo-playable', 'fnf_loss_maavo');
		}

		if (isMugen)
			songUiFolder = 'mugen/';

		add(gfGroup);

		if (!ClientPrefs.lowQuality && curStage == 'show' && (SONG.song == "Wannabe" || SONG.song == "Finale"))
		{
			if (SONG.song == "Wannabe") // Wannabe Maritza
				maritzaDancer = new BGDancer(-260, 310);
			else // Finale Maritza
				maritzaDancer = new BGDancer(428, 310);

			add(maritzaDancer);
		}

		// Shitty layering but whatev it works LO
		add(boyfriendGroup);
		add(dadGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var gfVersion:String = SONG.player3;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; // Fix for the Chart Editor
		}

		gf = new Character(0, 0, gfVersion);
		startCharacterPos(gf);
		gf.scrollFactor.set(0.95, 0.95);
		gfGroup.add(gf);

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		dadEventChar = dad;

		if (isLightOn)
		{
			boyfriend2 = new Boyfriend(-70, 0, "MaritzaPlayable");
			startCharacterPos(boyfriend2);
			boyfriendGroup.add(boyfriend2);
		}

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		bfEventChar = boyfriend;

		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}

		Conductor.songPosition = -5000;

		if (isTokyo)
		{
			tokyoSprite = new FlxSprite(0, 0);

			#if VIDEOS_ALLOWED
			if (!ClientPrefs.lowQuality)
			{
				tokyoVideo = new VideoHandler(Paths.video('tokio'), tokyoSprite);
				tokyoVideo.spriteWidth = camHUD.width;
				tokyoVideo.spriteHeight = camHUD.height;
				tokyoVideo.canUseSound = false;
			}
			else
			#end
			{
				tokyoSprite.loadGraphic(Paths.image('tokio_v2'));
			}

			tokyoSprite.cameras = [camHUD];
			tokyoSprite.antialiasing = ClientPrefs.globalAntialiasing;
			add(tokyoSprite);
		}

		strumLine = new FlxSprite(ClientPrefs.middleScroll
			|| isTokyo ? STRUM_X_MIDDLESCROLL : STRUM_X, isMugen ? 120 : 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", isMugen ? 64 : 32);
		timeTxt.setFormat(Paths.font("frank.ttf"), isMugen ? 64 : 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if (ClientPrefs.downScroll && !isMugen)
			timeTxt.y = FlxG.height - 45;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = isMugen ? false : !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = isMugen ? false : !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		var porDad:FlxPoint = new FlxPoint(0, 0);
		var porBF:FlxPoint = new FlxPoint(0, 0);

		if (isMugen)
		{
			var dadMugenPortrait:FlxSprite = new FlxSprite(10, 10);
			dadMugenPortrait.loadGraphic(Paths.image('hud/${songUiFolder}mugenportrait'));
			dadMugenPortrait.scrollFactor.set();
			dadMugenPortrait.cameras = [camHUD];
			dadMugenPortrait.visible = !ClientPrefs.hideHud;
			add(dadMugenPortrait);
			porDad.x = dadMugenPortrait.x;
			porDad.y = dadMugenPortrait.y;
			var bfMugenPortrait:FlxSprite = new FlxSprite(FlxG.width - 127, 10);
			bfMugenPortrait.loadGraphic(Paths.image('hud/${songUiFolder}mugenportrait'));
			bfMugenPortrait.scrollFactor.set();
			bfMugenPortrait.cameras = [camHUD];
			bfMugenPortrait.visible = !ClientPrefs.hideHud;
			add(bfMugenPortrait);
			porBF.x = bfMugenPortrait.x;
			porBF.y = bfMugenPortrait.y;
		}

		healthBarBG = new FlxSprite(172).loadGraphic(Paths.image('hud/${songUiFolder}healthBar'));
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		if (isMugen)
			healthBarBG.screenCenter(X);

		healthBar = new FlxBar(healthBarBG.x + (isMugen ? 16 : 178), 0, RIGHT_TO_LEFT, (isMugen ? 1024 : 575), (isMugen ? 18 : 26), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.x = isMugen ? porBF.x - 13 : healthBarBG.x + healthBarBG.width - 63;
		iconP1.visible = !ClientPrefs.hideHud;

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.x = isMugen ? porDad.x - 20 : healthBarBG.x + 45;
		iconP2.visible = !ClientPrefs.hideHud;

		if (ClientPrefs.downScroll)
		{
			healthBarBG.scale.y = isMugen ? 1 : -1;
			healthBarBG.y = isMugen ? porDad.y + 117 - 36 : 50;
			healthBar.y = healthBarBG.y + (isMugen ? 6 : 12);
			iconP2.y = isMugen ? porBF.y - 21 : healthBarBG.y - 25;
			iconP1.y = isMugen ? porDad.y - 21 : healthBarBG.y - 29;
		}
		else
		{
			healthBarBG.y = isMugen ? porDad.y + 117 - 36 : FlxG.height - healthBarBG.height - 50;
			healthBar.y = healthBarBG.y + (isMugen ? 6 : 119);
			iconP2.y = isMugen ? porBF.y - 21 : healthBarBG.y + 32;
			iconP1.y = isMugen ? porDad.y - 21 : healthBarBG.y + 36;
		}

		if (isMugen)
		{
			iconP1.scale.set(2 / 3, 2 / 3);
			iconP2.scale.set(2 / 3, 2 / 3);
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		add(healthBar);
		add(healthBarBG);
		add(iconP1);
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, 0, FlxG.width, "", isMugen ? 16 : 28);
		scoreTxt.setFormat(Paths.font(isMugen ? "mugen.otf" : "p5.ttf"), isMugen ? 16 : 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,
			FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.45;
		scoreTxt.visible = !ClientPrefs.hideHud;
		scoreTxt.y = isMugen ? healthBarBG.y + 40 : FlxG.height - scoreTxt.height - 14;
		scoreTxt.cameras = [camHUD];
		add(scoreTxt);

		if ((SONG.song.toLowerCase() == "showtime" || SONG.song.toLowerCase() == "pondering") && ClientPrefs.showSubs)
		{
			subs = Language.getSubtitles(Paths.formatToSongPath(SONG.song));

			subText = new FlxText(50, 600, 1180, "", 32);
			subText.setFormat(Paths.font("arial.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			subText.scrollFactor.set();
			subText.borderSize = 2.4;
			subText.cameras = [camSubs];
			add(subText);
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'data/' + Paths.formatToSongPath(SONG.song) + '/script.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		var daSong:String = Paths.formatToSongPath(curSong);

		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case 'lovely':
					introCutscene();
				case 'wannabe' | 'finale':
					startVideo(daSong);
				case 'showtime':
					showtimeCutscene();
			}
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		for (snd in introSounds)
			if (snd != null)
				FlxG.sound.load(Paths.sound(songUiFolder + snd));

		// Misses
		for (i in 1...3)
			FlxG.sound.load(Paths.sound('missnote${i}'));

		// MUGEN HITSOUNDS
		if (isMugen)
		{
			var mugenSounds:Array<String> = ['left', 'down', 'up', 'right'];
			for (i in 0...mugenSounds.length)
			{
				FlxG.sound.load(Paths.sound('mugen/maavohit_' + mugenSounds[i]));
				FlxG.sound.load(Paths.sound('mugen/ronaldhit_' + mugenSounds[i]));
			}
		}

		FlxG.sound.load(Paths.sound('stunsound'));

		#if desktopMUGEN
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
		super.create();
		Paths.clearUnusedMemory();
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors()
	{
		if (isMugen)
		{
			healthBar.createImageBar(Paths.image('hud/${songUiFolder}redbar'), Paths.image('hud/${songUiFolder}yellowbar'));
			healthBar.updateBar();
		}
		else
		{
			healthBarBG.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
			healthBar.createFilledBar(FlxColor.fromRGB(140, 140, 140), FlxColor.fromRGB(0, 255, 255));
			healthBar.updateBar();
		}
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if (!gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	function showtimeCutscene()
	{
		var blackFade:FlxSprite = new FlxSprite(0, 0).makeGraphic(1286, 726, FlxColor.BLACK);
		blackFade.cameras = [camHUD];
		add(blackFade);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if (ClientPrefs.showSubs)
				newSubtitle(subs[0]);

			FlxG.sound.play(Paths.sound('showtime-cutscene'));
			FlxTween.tween(blackFade, {alpha: 0}, 10, {startDelay: 4});
			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				if (ClientPrefs.showSubs)
					remove(subText);

				startCountdown(true);
			});
		});
	}

	function newSubtitle(sub:SubtitleStructure)
	{
		subsAlreadyShowed.push(Std.int(sub.time));
		subText.text = sub.text;
		subText.screenCenter(Y);
		subText.y += 270;
	}

	function itsTime(time:Int):Bool
	{
		return curStep >= time && !subsAlreadyShowed.contains(time);
	}

	function introCutscene()
	{
		finishedText = false;

		bgIntro = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgIntro.screenCenter();
		bgIntro.cameras = [camHUD];
		add(bgIntro);

		textIntro = new FlxText(400, 306);
		textIntro.setFormat(Paths.font("frank.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textIntro.cameras = [camHUD];

		textDiscard = new FlxSprite(-100, -100);
		textDiscard.cameras = [camHUD];

		lastTextDiscard = new FlxSprite(-100, -100);
		lastTextDiscard.cameras = [camHUD];

		add(lastTextDiscard);
		add(textDiscard);
		add(textIntro);

		triangleText = new FlxSprite(861, 472).loadGraphic(Paths.image('triangulito'));
		triangleText.cameras = [camHUD];
		triangleText.updateHitbox();
		add(triangleText);

		nextPage(0);
	}

	function nextPage(add:Int = 1)
	{
		curPage += add;
		if (curPage > 0)
		{
			if (curPage >= 2)
			{
				lastTextDiscard.loadGraphic(textDiscard.graphic);
				lastTextDiscard.x = 66;
				lastTextDiscard.y = 94;
				lastTextDiscard.angle = -10;
				lastTextDiscard.alpha = 0.5;

				FlxTween.tween(lastTextDiscard, {
					x: -268,
					y: -118,
					angle: -20,
					alpha: 0
				}, 0.3);
			}

			textDiscard.loadGraphic(textIntro.graphic);
			textDiscard.x = 400;
			textDiscard.y = 306;
			textDiscard.angle = 0;
			textDiscard.alpha = 1;

			FlxTween.tween(textDiscard, {
				x: 66,
				y: 94,
				angle: -10,
				alpha: 0.5
			}, 0.3);
		}
		textIntro.text = Language.cutscene[curPage];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;
		var filepath:String = Paths.video(name);

		if (!FileSystem.exists(filepath))
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		persistentUpdate = false;
		openSubState(new CutsceneSubstate(name, function()
		{
			startAndEnd();
			return;
		}));
		persistentDraw = false;
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function startCountdown(skipTimer:Bool = false):Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			return;
		}
		seenCutscene = true;

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if (ret != FunkinLua.Function_Stop)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length)
			{
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length)
			{
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if (ClientPrefs.middleScroll || isTokyo)
					opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= skipTimer ? 0 : Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = skipTimer ? 4 : 0;
			var timeTimer:Float = skipTimer ? 0.01 : Conductor.crochet / 1000;

			startTimer = new FlxTimer().start(timeTimer, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0
					&& !gf.stunned
					&& gf.animation.curAnim.name != null
					&& !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if (tmr.loopsLeft % 2 == 0)
				{
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (isLightOn)
					{
						if (boyfriend2.animation.curAnim != null && !boyfriend2.animation.curAnim.name.startsWith('sing'))
						{
							boyfriend2.dance();
						}
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if (dad.danceIdle
					&& dad.animation.curAnim != null
					&& !dad.stunned
					&& !dad.curCharacter.startsWith('gf')
					&& !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}
				// head bopping for bg characters on Mall
				if ((SONG.song == 'Lovely' || SONG.song == 'Finale') && curStage == 'show' && !ClientPrefs.lowQuality)
					maavoBopper.dance(true);

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound(songUiFolder + introSounds[swagCounter]), 0.6);
					case 1 | 2 | 3:
						var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('hud/${songUiFolder}${introSprites[swagCounter]}'));
						spr.scrollFactor.set();
						spr.updateHitbox();
						spr.screenCenter();
						spr.antialiasing = ClientPrefs.globalAntialiasing;
						add(spr);
						countDownSprites.push(spr);
						FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(spr);
								remove(spr);
								spr.destroy();
							}
						});
						FlxG.sound.play(Paths.sound(songUiFolder + introSounds[swagCounter]), 0.6);
				}

				notes.forEachAlive(function(note:Note)
				{
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		if (isTokyo && !ClientPrefs.lowQuality)
		{
			tokyoVideo.playVideo(false);
		}

		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		songSpeed = SONG.speed;

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		{
		#else
		if (OpenFLAssets.exists(file))
		{
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if (songNotes[1] < 0)
					{
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		var secNum = 0;
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if (songNotes[1] > -1)
				{ // Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}
					var oldNote:Note;

					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, secNum);

					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					if (!Std.isOfType(songNotes[3], String))
						swagNote.noteType = fnf.menus.editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
					swagNote.scrollFactor.set();
					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);
					var floorSus:Int = Math.floor(susLength);

					if (floorSus > 0)
					{
						for (susNote in 0...floorSus + 1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
							var sustainNote:Note = new Note(daStrumTime
								+ (Conductor.stepCrochet * susNote)
								+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData,
								oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					if (!noteTypeMap.exists(swagNote.noteType))
					{
						noteTypeMap.set(swagNote.noteType, true);
					}
				}
				else
				{ // Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			secNum++;
			daBeats += 1;
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:Array<Dynamic>)
	{
		switch (event[2])
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event[3].toLowerCase())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if (!eventPushedMap.exists(event[2]))
		{
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float
	{
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if (returnedValue != 0)
		{
			return returnedValue;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll
				|| isTokyo ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length)
			{
				if (chars[i] != null && chars[i].colorTween != null)
				{
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				if (isTokyo && !ClientPrefs.lowQuality)
					tokyoVideo.resume();
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;
			if (stunTimer != null)
				stunTimer.active = true;
			if (dissapearTime != null)
				dissapearTime.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}
		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")", iconP2.getCharacter(), true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		if (!finishedText && controls.ACCEPT)
		{
			if (curPage < 3)
			{
				nextPage();
				FlxG.sound.play(Paths.sound('storyIntroNext'));
			}
			else
			{
				finishedText = true;
				startVideo('lovely');
				textIntro.destroy();
				textDiscard.destroy();
				lastTextDiscard.destroy();
				triangleText.destroy();
				bgIntro.destroy();
			}
		}

		callOnLuas('onUpdate', [elapsed]);

		if ((SONG.song == 'Lovely' || SONG.song == 'Finale') && !ClientPrefs.lowQuality && curStage == 'show')
		{
			if (heyTimer > 0)
			{
				heyTimer -= elapsed;
				if (heyTimer <= 0)
				{
					maavoBopper.dance(true);
					heyTimer = 0;
				}
			}
		}

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if (!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		scoreTxt.text = !cpuControlled ? 'Score: $songScore | Misses: $songMisses | Accuracy: $ratingName ${ratingName != '?' ? '(${Highscore.floorDecimal(ratingPercent * 100, 2)}%)' : ''}${isMugen ? '| Notes Combo: $combo' : ''}' : "--- BotPlay ---";

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if (ret != FunkinLua.Function_Stop)
			{
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				CoolUtil.playSoundMenu('pause');
				if (FlxG.sound.music != null)
				{
					if (isTokyo && !ClientPrefs.lowQuality && tokyoVideo.isVideoPlaying)
						tokyoVideo.pause();
					FlxG.sound.music.pause();
					vocals.pause();
				}

				if (dissapearTime != null)
					dissapearTime.active = false;
				if (stunTimer != null)
					stunTimer.active = false;

				PauseSubState.transCamera = camOther;
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene)
		{
			if (isTokyo && !ClientPrefs.lowQuality)
				tokyoVideo.bitmap.stop();

			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		if (!isMugen)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP1.scale.set(mult, mult);

			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP2.scale.set(mult, mult);
		}

		var iconOffset:Int = 26;

		//	iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		//	iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene)
		{
			if (isTokyo && !ClientPrefs.lowQuality)
				tokyoVideo.bitmap.stop();

			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					var stringTime:String = '';
					if (!isMugen)
					{
						var minutesRemaining:Int = Math.floor(secondsTotal / 60);
						var secondsRemaining:String = '' + secondsTotal % 60;
						if (secondsRemaining.length < 2)
							secondsRemaining = '0' + secondsRemaining; // Dunno how to make it display a zero first in Haxe lol
						stringTime = minutesRemaining + ':' + secondsRemaining;
					}
					else
					{
						stringTime = '$secondsTotal';
					}
					timeTxt.text = stringTime;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET was Pressed");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;
			if (songSpeed < 1)
				time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if (!daNote.mustPress && ClientPrefs.middleScroll || !daNote.mustPress && isTokyo)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if (daNote.mustPress)
				{
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				}
				else
				{
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;

				if (daNote.copyX)
				{
					daNote.x = strumX;
				}
				if (daNote.copyAngle)
				{
					daNote.angle = strumAngle + daNote.pointyAngle;
				}
				if (daNote.copyAlpha)
				{
					daNote.alpha = strumAlpha;
				}
				if (daNote.copyY)
				{
					if (ClientPrefs.downScroll)
					{
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						if (daNote.isSustainNote)
						{
							// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end'))
							{
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								daNote.y -= 19;
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);

							if (daNote.mustPress || !daNote.ignoreNote)
							{
								if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else
					{
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);

						if (daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					if (daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
					{
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							camX = -camMvmntSpd;
							camY = 0;
						case 1:
							camY = camMvmntSpd;
							camX = 0;
						case 2:
							camY = -camMvmntSpd;
							camX = 0;
						case 3:
							camX = camMvmntSpd;
							camY = 0;
					}

					if (!daNote.noAnimation)
					{
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim
								|| daNote.noteType == 'Alt Animation'
								|| daNote.noteType == 'VFX Note')
							{
								altAnim = '-alt';
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if (daNote.noteType == 'VFX Note' && isMugen)
						{
							health -= daNote.hitHealth;

							vfxR.alpha = 1;
							new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								vfxR.alpha = 0.01;
							});

							switch (Math.abs(daNote.noteData))
							{
								case 0:
									vfxR.setPosition(861, 449);
									vfxR.animation.play('punchR', true);
									FlxG.sound.play(Paths.sound('mugen/ronaldhit_left'), 1);
								case 1:
									vfxR.setPosition(902, 730);
									vfxR.animation.play('punchR', true);
									FlxG.sound.play(Paths.sound('mugen/ronaldhit_down'), 1);
								case 2:
									vfxR.setPosition(440, -52);
									vfxR.animation.play('punchR2', true);
									FlxG.sound.play(Paths.sound('mugen/ronaldhit_up'), 1);
								case 3:
									vfxR.setPosition(739, 426);
									vfxR.animation.play('punchR2', true);
									FlxG.sound.play(Paths.sound('mugen/ronaldhit_right'), 1);
							}
						}
						if (daNote.noteType == 'GF Sing')
						{
							gf.playAnim(animToPlay + altAnim, true);
							gf.holdTimer = 0;
						}
						else
						{
							dad.playAnim(animToPlay + altAnim, true);
							dad.holdTimer = 0;
						}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if (daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end'))
					{
						time += 0.15;
					}
					StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)) % 4, time);
					daNote.hitByOpponent = true;

					callOnLuas('opponentNoteHit', [
						notes.members.indexOf(daNote),
						Math.abs(daNote.noteData),
						daNote.noteType,
						daNote.isSustainNote
					]);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if (daNote.mustPress && cpuControlled)
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
						{
							goodNoteHit(daNote);
						}
					}
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
					{
						goodNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
					{
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		if (!inCutscene)
		{
			if (!cpuControlled)
			{
				keyShit();
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
			if (isLightOn)
			{
				if (boyfriend2.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend2.singDuration
					&& boyfriend2.animation.curAnim.name.startsWith('sing')
					&& !boyfriend2.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend2.dance();
				}
			}
		}

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
		#end
	}

	var isDead:Bool = false;

	function doDeathCheck()
	{
		if (health <= 0 && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();
				if (isTokyo && !ClientPrefs.lowQuality)
					tokyoVideo.bitmap.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, dad.x, dad.y, this));
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if (Conductor.songPosition < leStrumTime - early)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if (eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value))
					value = 1;
				gfSpeed = value;
			case 'Set Camera Zoom':
				if (ClientPrefs.camZooms)
				{
					var camZoom:Float = Std.parseFloat(value1);
					if (Math.isNaN(camZoom) || camZoom == 0)
						camZoom = 0.9;

					defaultCamZoom = camZoom;
				}
			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}
			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();
			case 'Ronald Portrait':
				if (isMugen && curStage == 'kfm')
				{
					FlxG.sound.play(Paths.sound('mugen/ronaldHYPER'), 1);
					ronalportrait.alpha = 1;
					ronalportrait.animation.play('clown');
					vfxR.alpha = 1;
					vfxR.setPosition(902, 730);
					vfxR.animation.play('spark', true);
					dissapearTime = new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						dissapearTime = null;
						ronalportrait.alpha = 0;
						vfxR.alpha = 0;
					});
				}

			case 'Maavo Portrait':
				var value:Int = Std.parseInt(value1);
				if (isMugen && curStage == 'kfm')
				{
					FlxG.sound.play(Paths.sound('mugen/maavoHYPER'), 1);

					if (Math.isNaN(value))
						value = 0;
					switch (value)
					{
						case 0:
							maavoportrait.alpha = 1;
							bgM.alpha = 1;
							maavoportrait.animation.play('wow');
							if (maavoportrait.animation.finished) maavoportrait.alpha = 0;
						case 1:
							bgM.alpha = 0;
					}
				}
			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = Std.parseFloat(split[0].trim());
					var intensity:Float = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if (!boyfriend.alreadyLoaded)
							{
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);

							bfEventChar = boyfriend;
						}
					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf)
								{
									gf.visible = true;
								}
							}
							else
							{
								gf.visible = false;
							}
							if (!dad.alreadyLoaded)
							{
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);

							dadEventChar = dad;
						}
					case 2:
						if (gf.curCharacter != value2)
						{
							if (!gfMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							gf.visible = false;
							gf = gfMap.get(value2);
							if (!gf.alreadyLoaded)
							{
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
						}
				}
				reloadHealthBarColors();
			case 'Update Bar':
				var charType:Int = Std.parseInt(value1);
				if (Math.isNaN(charType))
					charType = 0;

				var eventChar:Character = new Character(0, 0, value2);
				switch (charType)
				{
					case 0:
						bfEventChar = eventChar;
						iconP1.changeIcon(eventChar.healthIcon);
					case 1:
						dadEventChar = eventChar;
						iconP2.changeIcon(eventChar.healthIcon);
						FlxTween.color(healthBarBG, 0.75, healthBarBG.color,
							FlxColor.fromRGB(eventChar.healthColorArray[0], eventChar.healthColorArray[1], eventChar.healthColorArray[2]));
				}
			case 'Change Scroll Speed':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (SONG.notes[id] == null)
			return;

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			if (dadEventChar.curCharacter == dad.curCharacter)
			{
				camFollow.x += dad.cameraPosition[0];
				camFollow.y += dad.cameraPosition[1];
			}
			else
			{
				camFollow.x += dadEventChar.cameraPosition[0];
				camFollow.y += dadEventChar.cameraPosition[1];
			}

			if (ClientPrefs.dynamicCamera)
			{
				camFollow.y += camY;
				camFollow.x += camX;
			}

			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			if (bfEventChar.curCharacter == boyfriend.curCharacter)
			{
				camFollow.x -= boyfriend.cameraPosition[0];
				camFollow.y += boyfriend.cameraPosition[1];
			}
			else
			{
				camFollow.x += bfEventChar.cameraPosition[0];
				camFollow.y += bfEventChar.cameraPosition[1];
			}

			if (ClientPrefs.dynamicCamera)
			{
				camFollow.y += bfcamY;
				camFollow.x += bfcamX;
			}

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.0475;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.0475;
				}
			}

			if (doDeathCheck())
			{
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		if (isTokyo && !ClientPrefs.lowQuality)
			tokyoVideo.bitmap.stop();

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement(['great_show', 'expert', 'perfect', 'perfeccionist', 'sick', 'telones']);
			if (achieve != null)
			{
				switch (achieve)
				{
					case 'great_show':
						startChar("pondering");
					case 'expert':
						startChar("tokyo");
				}
				startAchievement(achieve);
				return;
			}
		}
		#end

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song.toLowerCase(), songScore, storyDifficulty, percent, songMisses);
				trace('Song Accuracy: ' + Highscore.floorDecimal(percent * 100, 2));
				trace('Song Score: $songScore');
				trace('Song Misses: $songMisses');
				#end
			}

			if (isStoryMode)
			{
				campaignPercent += ratingPercent;
				campaignScore += songScore;
				campaignMisses += songMisses;

				trace('Week Accuracy: ' + Highscore.floorDecimal(campaignPercent * 100, storyDifficulty));
				trace('Week Score: $campaignScore');
				trace('Week Misses: $songMisses');

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new MainMenuState());

					// if ()
					if (!usedPractice)
					{
						MainMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = MainMenuState.weekCompleted;
						FlxG.save.flush();
					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelFadeTween();
					// resetSpriteCache = true;
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			transitioning = true;
		}
	}

	var songUnlocked:UnlockObject = null;
	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	function startChar(char:String)
	{
		songUnlocked = new UnlockObject(char, camOther);
		songUnlocked.onFinish = endChar;
		add(songUnlocked);
	}

	function endChar():Void
	{
		songUnlocked = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8);
		vocals.volume = 1;

		var placement:Float = FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				sicks++;
		}
		note.rating = daRating;

		if (daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if (!practiceMode && !cpuControlled)
		{
			songScore += score;
			songHits++;
			totalPlayed++;
			RecalculateRating();

			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
			daRating = 'sick';
		else if (combo > 12)
			daRating = 'good'
		else if (combo > 4)
			daRating = 'bad';
	 */

		rating.loadGraphic(Paths.image('hud/$songUiFolder$daRating'));
		rating.cameras = [camHUD];
		rating.visible = !ClientPrefs.hideHud;
		rating.antialiasing = isMugen ? false : ClientPrefs.globalAntialiasing;

		var comboSpr:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		comboSpr.cameras = [camHUD];
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.antialiasing = ClientPrefs.globalAntialiasing;

		if (!isMugen)
		{
			rating.screenCenter();
			rating.x = placement - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			rating.x += ClientPrefs.comboOffset[0];
			rating.y -= ClientPrefs.comboOffset[1];
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.updateHitbox();
			insert(members.indexOf(strumLineNotes), rating);

			comboSpr.screenCenter();
			comboSpr.x = placement;
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y -= FlxG.random.int(140, 160);
			comboSpr.x += ClientPrefs.comboOffset[0];
			comboSpr.y -= ClientPrefs.comboOffset[1];
			comboSpr.y += 60;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.updateHitbox();
		}

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
		{
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;

		for (i in seperatedScore)
		{
			if (!isMugen)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('hud/${songUiFolder}num${Std.int(i)}'));
				numScore.cameras = [camHUD];
				numScore.screenCenter();
				numScore.x = placement + (43 * daLoop) - 90 + ClientPrefs.comboOffset[2];
				numScore.y += 80 - ClientPrefs.comboOffset[3];
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				numScore.visible = !ClientPrefs.hideHud;
				numScore.antialiasing = isMugen ? false : ClientPrefs.globalAntialiasing;

				insert(members.indexOf(strumLineNotes), numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
				if (numScore.x > xThing)
					xThing = numScore.x;
			}
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002
		});
	}

	private function keyShit():Void
	{
		if (FlxG.keys.justPressed.SPACE && !boyfriend.stunned && boyfriend.animOffsets.exists('hey'))
		{
			boyfriend.playAnim('hey', true);
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 0.6;
		}
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					goodNoteHit(daNote);
				}
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong)
			{
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == i)
							{
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0)
						{
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes)
								{
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10)
									{
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									}
									else
										notesStopped = true;
								}

								// eee jack detection before was not super good
								if (controlArray[epicNote.noteData] && !notesStopped)
								{
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);
								}
							}
						}
						else if (canMiss)
							ghostMiss(controlArray[i], i, true);

						// I dunno what you need this for but here you go
						//									- Shubs

						// Shubs, this is for the "Just the Two of Us" achievement lol
						//									- Shadow Mario
						if (!keysPressed[i] && controlArray[i])
							keysPressed[i] = true;
					}
				}
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
			if (isLightOn)
			{
				if (boyfriend2.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend2.singDuration
					&& boyfriend2.animation.curAnim.name.startsWith('sing')
					&& !boyfriend2.animation.curAnim.name.endsWith('miss'))
					boyfriend2.dance();
			}
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if (controlReleaseArray[spr.ID])
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false)
	{
		/* quien chucha querria jugar sin ghost tapping hoy en día de todas formas 🙄🙄🙄🥱🥱🥱🥱
		if (statement) {
			noteMissPress(direction, ghostMiss);
			callOnLuas('noteMissPress', [direction]);
		}
	 */
	}

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 10)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth; // For testing purposes
		combo = 0;
		songMisses++;
		vocals.volume = 0;

		totalPlayed++;
		RecalculateRating();

		if (!boyfriend.stunned)
		{
			var animToPlay:String = '';
			switch (Math.abs(daNote.noteData) % 4)
			{
				case 0:
					animToPlay = 'singLEFTmiss';
				case 1:
					animToPlay = 'singDOWNmiss';
				case 2:
					animToPlay = 'singUPmiss';
				case 3:
					animToPlay = 'singRIGHTmiss';
			}

			if (daNote.noteType == 'GF Sing')
			{
				gf.playAnim(animToPlay, true);
			}
			else if (daNote.noteType == 'SecondCharacter')
			{
				var daAlt = '';
				if (daNote.noteType == 'Alt Animation')
					daAlt = '-alt';

				boyfriend2.playAnim(animToPlay + daAlt, true);
			}
			else if (daNote.noteType == 'MainAndSecondCharacter')
			{
				var daAlt = '';
				if (daNote.noteType == 'Alt Animation')
					daAlt = '-alt';

				boyfriend.playAnim(animToPlay + daAlt, true);
				boyfriend2.playAnim(animToPlay + daAlt, true);
			}
			else
			{
				var daAlt = '';
				if (daNote.noteType == 'Alt Animation')
					daAlt = '-alt';

				boyfriend.playAnim(animToPlay + daAlt, true);
			}
		}

		callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void // You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05;
			combo = 0;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				if (ghostMiss)
					ghostMisses++;
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;
			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
		});*/

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			vocals.volume = 0;
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				switch (note.noteType)
				{
					case 'Stun Note': // Stun Note
						{
							timesStunned++;
							triggerEventNote('Screen Shake', '0.2,0.01', '');
							FlxG.sound.play(Paths.sound('stunsound'), 1);
							boyfriend.playAnim('stun', true);
							boyfriend.specialAnim = true;
							boyfriend.stunned = true;
							stunTimer = new FlxTimer().start(1.5, function(tmr:FlxTimer)
							{
								stunTimer = null;
								boyfriend.stunned = false;
							});
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
				if (combo > 9999)
					combo = 9999;
			}
			health += note.hitHealth;

			switch (Math.abs(note.noteData))
			{
				case 0:
					bfcamX = -camMvmntSpd;
					bfcamY = 0;
				case 1:
					bfcamY = camMvmntSpd;
					bfcamX = 0;
				case 2:
					bfcamY = -camMvmntSpd;
					bfcamX = 0;
				case 3:
					bfcamX = camMvmntSpd;
					bfcamY = 0;
			}

			if (!note.noAnimation)
			{
				var daAlt = '';
				if (note.noteType == 'Alt Animation' || note.noteType == 'VFX Note')
					daAlt = '-alt';

				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
					case 1:
						animToPlay = 'singDOWN';
					case 2:
						animToPlay = 'singUP';
					case 3:
						animToPlay = 'singRIGHT';
				}

				if (isMugen && note.noteType == 'VFX Note')
				{
					vfx.alpha = 1;
					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						vfx.alpha = 0;
					});

					var noteNum = Math.abs(note.noteData);

					switch (noteNum)
					{
						case 0:
							vfx.angle = 95;
							vfx.setPosition(-51, 62);
							FlxG.sound.play(Paths.sound('mugen/maavohit_left'), 1);
						case 1:
							vfx.angle = 85;
							vfx.setPosition(82, 493);
							FlxG.sound.play(Paths.sound('mugen/maavohit_down'), 1);
						case 2:
							vfx.angle = 65;
							vfx.setPosition(103, -43);
							FlxG.sound.play(Paths.sound('mugen/maavohit_up'), 1);
						case 3:
							vfx.angle = 30;
							vfx.setPosition(357, 92);
							FlxG.sound.play(Paths.sound('mugen/maavohit_right'), 1);
					}
					vfx.animation.play('punch', true);
				}

				switch (note.noteType)
				{
					case 'Hey':
						if (boyfriend.animOffsets.exists('hey'))
						{
							boyfriend.playAnim('hey', true);
							boyfriend.specialAnim = true;
							boyfriend.heyTimer = 0.6;
						}

						if (gf.animOffsets.exists('cheer'))
						{
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = 0.6;
						}
					case 'GF Sing':
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					case 'MainAndSecondCharacter':
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
						if (isLightOn)
						{
							boyfriend2.playAnim(animToPlay + daAlt, true);
							boyfriend2.holdTimer = 0;
						}
					default:
						boyfriend.playAnim(animToPlay + daAlt, true);
						boyfriend.holdTimer = 0;
				}
			}
			else
			{
				if (isLightOn && note.noteType == 'SecondCharacter')
				{
					var animToPlay:String = '';
					switch (Std.int(Math.abs(note.noteData)))
					{
						case 0:
							animToPlay = 'singLEFT';
						case 1:
							animToPlay = 'singDOWN';
						case 2:
							animToPlay = 'singUP';
						case 3:
							animToPlay = 'singRIGHT';
					}
					boyfriend2.playAnim(animToPlay, true);
					boyfriend2.holdTimer = 0;
				}
			}
			if (cpuControlled)
			{
				var time:Float = 0.15;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		if (note != null)
		{
			skin = note.noteSplashTexture;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin);
		grpNoteSplashes.add(splash);
	}

	private var preventLuaRemove:Bool = false;

	override function destroy()
	{
		preventLuaRemove = true;
		for (i in 0...luaArray.length)
		{
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];
		super.destroy();
	}

	public function cancelFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua)
	{
		if (luaArray != null && !preventLuaRemove)
		{
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();

		if (SONG.song.toLowerCase() == "pondering" && ClientPrefs.showSubs)
			for (i in 0...subs.length)
				if (itsTime(Std.int(subs[i].time)))
					newSubtitle(subs[i]);

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				// FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		/*if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
	}*/
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		if (!isMugen)
		{
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);
		}

		if (curBeat % gfSpeed == 0
			&& !gf.stunned
			&& gf.animation.curAnim.name != null
			&& !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
			if (isLightOn)
			{
				if (boyfriend2.animation.curAnim.name != null && !boyfriend2.animation.curAnim.name.startsWith("sing"))
				{
					boyfriend2.dance();
				}
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		}
		else if (dad.danceIdle
			&& dad.animation.curAnim.name != null
			&& !dad.curCharacter.startsWith('gf')
			&& !dad.animation.curAnim.name.startsWith("sing")
			&& !dad.stunned)
		{
			dad.dance();
		}

		if (curStage == 'show' && !ClientPrefs.lowQuality)
		{
			switch (SONG.song)
			{
				case 'Lovely':
					if (heyTimer <= 0)
						maavoBopper.dance(true);
				case 'Wannabe':
					maritzaDancer.dance();
				case 'Finale':
					if (heyTimer <= 0)
						maavoBopper.dance(true);
					maritzaDancer.dance();
			}
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat);
		callOnLuas('onBeatHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			var ret:Dynamic = luaArray[i].call(event, args);
			if (ret != FunkinLua.Function_Continue)
			{
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
		{
			spr = strumLineNotes.members[id];
		}
		else
		{
			spr = playerStrums.members[id];
		}

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating()
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if (ret != FunkinLua.Function_Stop)
		{
			if (totalPlayed < 1) // Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if (ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length - 1)
					{
						if (ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0)
				ratingFC = "SFC";
			if (goods > 0)
				ratingFC = "GFC";
			if (bads > 0 || shits > 0)
				ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10)
				ratingFC = "SDCB";
			else if (songMisses >= 10)
				ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	function checkPerfect():Bool
	{
		var songsNames:Array<String> = [
			'lovely',
			'wannabe',
			'finale',
			'showtime',
			'pondering',
			'light-on',
			'mugen',
			'tokyo'
		];
		for (i in 0...songsNames.length)
		{
			if (Highscore.getScore(songsNames[i], 2) > 0)
			{
				if (Highscore.getMisses(songsNames[i], 2) > 0)
				{
					trace(songsNames[i] + ' tiene ${Highscore.getMisses(songsNames[i], 2)} misses');
					return false;
				}
			}
			else
			{
				trace(songsNames[i] + ' no se jugo todavia');
				return false;
			}
		}
		return true;
	}

	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled)
			{
				var unlock:Bool = false;

				switch (achievementName)
				{
					case 'great_show':
						if (isStoryMode
							&& CoolUtil.difficultyString() == 'HARD'
							&& storyPlaylist.length <= 1
							&& WeekData.getWeekFileName() == ('showtime')
							&& !changedDifficulty)
						{
							unlock = true;
						}
					case 'expert':
						if (Paths.formatToSongPath(SONG.song) == 'showtime' && timesStunned < 1)
						{
							unlock = true;
						}
					case 'pondering':
						if (Paths.formatToSongPath(SONG.song) == 'pondering' && CoolUtil.difficultyString() == 'HARD' && songMisses < 1)
						{
							unlock = true;
						}
					case 'maavo_generations':
						if (Paths.formatToSongPath(SONG.song) == 'light-on' && CoolUtil.difficultyString() == 'HARD' && songMisses < 1)
						{
							unlock = true;
						}
					case 'perfect':
						if (Paths.formatToSongPath(SONG.song) == 'mugen' && CoolUtil.difficultyString() == 'HARD' && songMisses < 1)
						{
							unlock = true;
						}
					case 'sick':
						if (Paths.formatToSongPath(SONG.song) == 'tokyo' && CoolUtil.difficultyString() == 'EXTREME' && songMisses < 1)
						{
							unlock = true;
						}
					case 'perfeccionist':
						if (checkPerfect())
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
	#end
}
