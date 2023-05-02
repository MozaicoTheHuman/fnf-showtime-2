package fnf.menus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import fnf.menus.submenus.ResetScoreSubState;
import fnf.system.ClientPrefs;
import fnf.system.CoolUtil;
import fnf.system.Highscore;
import fnf.system.Language;
import fnf.system.LoadingState;
import fnf.system.MusicBeatState;
import fnf.system.Paths;
import fnf.system.Song;
import fnf.system.WeekData;
import fnf.system.unlockeables.Achievements;
import fnf.system.visuals.AttachedSprite;
import fnf.system.visuals.HealthIcon;
import openfl.OpenFLAssets;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var lerpMisses:Int = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var intendedMisses:Int = 0;

	private var grpSongs:FlxTypedGroup<FlxSprite>;
	private var staricons:FlxTypedGroup<FlxSprite>;
	private var songBG:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var griddiffs:FlxSprite;
	var gridcenter:FlxSprite;
	var griddown:FlxSprite;
	var album:FlxSprite;
	var star:FlxSprite;
	var songsBG:FlxSprite;
	var starIcon:FlxSprite;
	var selectedBG:FlxSprite;
	var diffText:FlxSprite;
	var arrLeft:FlxSprite;
	var arrRight:FlxSprite;
	var songText:FlxSprite;

	var waveA:FlxBackdrop;
	var waveB:FlxBackdrop;
	var waveC:FlxBackdrop;
	var waveA2:FlxBackdrop;
	var waveB2:FlxBackdrop;
	var waveC2:FlxBackdrop;

	var bgTextTween:FlxTween;
	var textTween:FlxTween;

	private var camGame:FlxCamera;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var descText:FlxText;
	var descBox:AttachedSprite;
	var unlockGuide:Array<String>;

	var lockStuff:Array<Dynamic> = [
		["Pondering", 'great_show', false],
		["Light-On", 'gane', false],
		["MUGEN", 'detective', false],
		["Tokyo", 'expert', false]
	];

	override function create()
	{
		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		#end
		WeekData.reloadWeekFiles();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay Menu", null);
		#end

		camGame = new FlxCamera();
		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		unlockGuide = Language.unlockguide;

		for (i in 0...WeekData.weeksList.length)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			var leAlbums:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
				leAlbums.push(leWeek.songs[j][2]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				addSong(song[0], i, song[1], song[2]);
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if (initSonglist[i] != null && initSonglist[i].length > 0)
			{
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], songArray[2]);
			}
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		for (i in 0...lockStuff.length)
		{
			if (Achievements.isAchievementUnlocked(lockStuff[i][1]))
				lockStuff[i][2] = true;
		}

		bg = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/bg'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scrollFactor.set();
		add(bg);

		waveA = new FlxBackdrop(Paths.image('freeplaymenu/blackthingup'), X);
		waveA.scrollFactor.set();
		add(waveA);

		waveB = new FlxBackdrop(Paths.image('freeplaymenu/darkredthingup'), X);
		waveB.scrollFactor.set();
		add(waveB);

		waveC = new FlxBackdrop(Paths.image('freeplaymenu/redthingup'), X);
		waveC.scrollFactor.set();
		add(waveC);

		gridcenter = new FlxSprite(360, 210).loadGraphic(Paths.image('freeplaymenu/gridCenter'));
		gridcenter.antialiasing = ClientPrefs.globalAntialiasing;
		gridcenter.scrollFactor.set();
		add(gridcenter);

		album = new FlxSprite(105, 140);
		album.loadGraphic(Paths.image('freeplaymenu/albums/placeholder'));
		album.antialiasing = ClientPrefs.globalAntialiasing;
		album.scrollFactor.set();
		add(album);

		star = new FlxSprite(370, 130);
		star.loadGraphic(Paths.image('freeplaymenu/star'));
		star.antialiasing = ClientPrefs.globalAntialiasing;
		star.scrollFactor.set();
		add(star);

		griddown = new FlxSprite(0, 365).loadGraphic(Paths.image('freeplaymenu/grid'));
		griddown.antialiasing = ClientPrefs.globalAntialiasing;
		griddown.scrollFactor.set();
		add(griddown);

		songsBG = new FlxSprite(455, 0).loadGraphic(Paths.image('freeplaymenu/songsBG'));
		songsBG.antialiasing = ClientPrefs.globalAntialiasing;
		songsBG.scrollFactor.set();
		add(songsBG);

		songBG = new FlxTypedGroup<FlxSprite>();
		add(songBG);

		grpSongs = new FlxTypedGroup<FlxSprite>();
		add(grpSongs);

		staricons = new FlxTypedGroup<FlxSprite>();
		add(staricons);

		for (i in 0...songs.length)
		{
			Paths.currentModDirectory = songs[i].folder;
			// (songs.length);

			var icon:HealthIcon;

			var offset:Float = 30 - (Math.max(songs.length, 4) - 2) * 80;
			var offsetBG:Float = 80 - (Math.max(songs.length, 4) - 2) * 80;
			var songSprite = songs[i].songName;
			// Change song name distance here

			selectedBG = new FlxSprite(554 - (i * 59) - offsetBG, 80 + (i * 110) + offset).loadGraphic(Paths.image('freeplaymenu/selectedsong'));
			selectedBG.antialiasing = ClientPrefs.globalAntialiasing;
			selectedBG.scrollFactor.set();
			selectedBG.ID = i;
			songBG.add(selectedBG);
			selectedBG.visible = false;

			songText = new FlxSprite(690 - (i * 60) - offset, 80 + (i * 110) + offset).loadGraphic(Paths.image('freeplaymenu/songs/$songSprite'));
			songText.ID = i;
			grpSongs.add(songText);
			songText.color = 0x0084FF;

			starIcon = new FlxSprite(550 - (i * 60) - offset, 95 + (i * 110) + offset);
			starIcon.loadGraphic(Paths.image('freeplaymenu/iconstar'));
			starIcon.antialiasing = ClientPrefs.globalAntialiasing;
			starIcon.scrollFactor.set();
			starIcon.ID = i;
			staricons.add(starIcon);

			if (i > 3 && !lockStuff[i - 4][1])
			{
				icon = new HealthIcon('locked');
				icon.sprTracker = songText;
				iconArray.push(icon);
				add(icon);
			}
			else
			{
				icon = new HealthIcon(songs[i].songCharacter);
				icon.sprTracker = songText;
				iconArray.push(icon);
				add(icon);
			}

			var scr:Float = (songs.length - 3) * 0.135;
			var scr2:Float = (songs.length - 3) * 0.132;
			if (songs.length < 6)
				scr = 0;
			songText.scrollFactor.set(scr / 2, scr);
			songText.antialiasing = ClientPrefs.globalAntialiasing;
			songText.updateHitbox();
			icon.scrollFactor.set(scr / 2, scr);
			icon.antialiasing = ClientPrefs.globalAntialiasing;
			icon.updateHitbox();
			starIcon.scrollFactor.set(scr / 2, scr);
			starIcon.antialiasing = ClientPrefs.globalAntialiasing;
			starIcon.updateHitbox();

			selectedBG.scrollFactor.set(scr2 / 2, scr);
			selectedBG.antialiasing = ClientPrefs.globalAntialiasing;
			selectedBG.updateHitbox();
		}

		WeekData.setDirectoryFromWeek();

		FlxG.camera.follow(camFollowPos, null, 1);

		griddiffs = new FlxSprite(780, 0).loadGraphic(Paths.image('freeplaymenu/gridDiffs'));
		griddiffs.antialiasing = ClientPrefs.globalAntialiasing;
		griddiffs.scrollFactor.set();
		add(griddiffs);

		diffText = new FlxSprite(870, 25);
		diffText.loadGraphic(Paths.image('freeplaymenu/diffs'), true, 370, 45);
		diffText.animation.add('diffficult', [2, 1, 0, 3], 0, false);
		diffText.animation.play('diffficult');
		diffText.scrollFactor.set();
		add(diffText);

		var ui_tex = Paths.getSparrowAtlas('freeplaymenu/arrows');

		arrRight = new FlxSprite(1240, 25);
		arrRight.frames = ui_tex;
		arrRight.animation.addByIndices('idle', "arrRight", [0], "", 0);
		arrRight.animation.addByIndices('pressed', "arrRight", [1], "", 0);
		arrRight.animation.play('idle');
		arrRight.scrollFactor.set();
		add(arrRight);

		arrLeft = new FlxSprite(845, 25);
		arrLeft.frames = ui_tex;
		arrLeft.animation.addByIndices('idle', "arrLeft", [0], "", 0);
		arrLeft.animation.addByIndices('pressed', "arrLeft", [1], "", 0);
		arrLeft.animation.play('idle');
		arrLeft.scrollFactor.set();
		add(arrLeft);

		waveA2 = new FlxBackdrop(Paths.image('freeplaymenu/blackthing'), X);
		waveA2.y = 630;
		waveA2.scrollFactor.set();
		add(waveA2);

		waveB2 = new FlxBackdrop(Paths.image('freeplaymenu/darkredthing'), X);
		waveB2.y = 660;
		waveB2.scrollFactor.set();
		add(waveB2);

		waveC2 = new FlxBackdrop(Paths.image('freeplaymenu/redthing'), X);
		waveC2.y = 660;
		waveC2.scrollFactor.set();
		add(waveC2);

		scoreText = new FlxText(5, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		scoreText.scrollFactor.set();

		scoreBG = new FlxSprite().makeGraphic(1, 42, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.scrollFactor.set();
		add(scoreBG);

		add(scoreText);

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + -75 - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		descBox.sprTracker = descText;
		add(descText);

		changeSelection();
		changeDiff();

		// var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		// textBG.alpha = 0.6;
		// textBG.scrollFactor.set();
		// add(textBG);
		// #if PRELOAD_ALL
		// var leText:String = "P para abrir el skin selector/SPACE to listen the Song / RESET to Reset the Score: " + songIsSelected;
		// #else
		// var leText:String = "Press RESET to Reset your Score and Accuracy.";
		// #end
		// var text:FlxText = new FlxText(textBG.x + 4, textBG.y + 4, FlxG.width, leText, 18);
		// text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
		// text.scrollFactor.set();
		// add(text);
		// super.create();
	}

	override function closeSubState()
	{
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, album:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, album));
	}

	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var shiftMult:Int = 1;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));
		lerpMisses = intendedMisses;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%) MISSES: ' + lerpMisses;
		positionHighscore();

		waveA.x -= 0.125;
		waveB.x -= 0.25;
		waveC.x -= 0.5;

		waveA2.x += 0.125;
		waveB2.x += 0.25;
		waveC2.x += 0.5;

		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (upP)
		{
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			changeSelection(shiftMult);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.UI_RIGHT)
			arrRight.animation.play('pressed');
		else
			arrRight.animation.play('idle');
		if (controls.UI_LEFT)
			arrLeft.animation.play('pressed');
		else
			arrLeft.animation.play('idle');

		if (controls.BACK)
		{
			destroyFreeplayVocals();
			if (textTween != null)
			{
				textTween.cancel();
			}
			if (bgTextTween != null)
			{
				bgTextTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if (space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else
		#end if (accepted)
	{
			if (curSelected > 3 && !lockStuff[curSelected - 4][1])
			{
				FlxG.sound.play(Paths.sound('pageMenu'));
				lockedScreen();
			}
			else
			{
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				#if MODS_ALLOWED
				if (!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop))
					&& !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop)))
				{
				#else
				if (!OpenFLAssets.exists(Paths.json(songLowercase + '/' + poop)))
				{
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
				}
				trace(poop);
				if (textTween != null)
				{
					textTween.cancel();
				}
				if (bgTextTween != null)
				{
					bgTextTween.cancel();
				}

				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				PlayState.storyWeek = songs[curSelected].week;
				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				LoadingState.loadAndSwitchState(new PlayState());

				FlxG.sound.music.volume = 0;

				destroyFreeplayVocals();
		}
		}
		if (controls.RESET)
		{
			for (i in 0...lockStuff.length)
			{
				if (songs[curSelected].songName.toLowerCase() == lockStuff[i][0].toLowerCase() && !lockStuff[i][2])
				{
					trace("This song is Locked, Reset Score Locked");
					return;
				}
			}
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function lockedScreen()
	{
		descBox.alpha = 0;
		descText.alpha = 0;
		descText.y = FlxG.height - descText.height - 135;
		var newText:String = unlockGuide[curSelected - 4];
		if (newText != descText.text)
		{
			descText.text = newText;
			if (textTween != null)
			{
				textTween.cancel();
			}
			if (bgTextTween != null)
			{
				bgTextTween.cancel();
			}
			textTween = FlxTween.tween(descText, {alpha: 1, y: descText.y + 75}, 0.3, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					textTween = FlxTween.tween(textTween, {alpha: 0}, 0.2, {
						startDelay: 2,
						onComplete: function(twn:FlxTween)
						{
							textTween = null;
						}
					});
				}
			});
			bgTextTween = FlxTween.tween(bgTextTween, {alpha: 0.5}, 0.3, {
				ease: FlxEase.sineOut,
				onComplete: function(twn:FlxTween)
				{
					bgTextTween = FlxTween.tween(bgTextTween, {alpha: 0}, 0.2, {
						startDelay: 2.5,
						onComplete: function(twn:FlxTween)
						{
							bgTextTween = null;
						}
					});
				}
			});
		}
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		var tokyoInt:Int = songs[curSelected].songName == "Tokyo" ? 0 : 1;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length - (1 + tokyoInt);
		if (curDifficulty >= CoolUtil.difficultyStuff.length - tokyoInt)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		intendedMisses = Highscore.getMisses(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.animation.curAnim.curFrame = curDifficulty;
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		intendedMisses = Highscore.getMisses(songs[curSelected].songName, curDifficulty);
		#end

		grpSongs.forEach(function(spr:FlxSprite)
		{
			spr.color = 0xFFFFFF;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.color = 0x000000;
				var add:Float = 0;
				if (grpSongs.length > 4)
				{
					add = grpSongs.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x - (curSelected * 56), spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
		staricons.forEach(function(spr:FlxSprite)
		{
			spr.color = 0xFFFFFF;
			if (spr.ID == curSelected)
			{
				spr.color = 0x000000;
			}
		});
		songBG.forEach(function(spr:FlxSprite)
		{
			spr.visible = false;
			if (spr.ID == curSelected)
			{
				spr.visible = true;
			}
		});

		if (OpenFLAssets.exists(Paths.getPath('images/freeplaymenu/albums/' + songs[curSelected].album + '.png', IMAGE), IMAGE))
		{
			if (curSelected > 3 && !lockStuff[curSelected - 4][1])
				album.loadGraphic(Paths.image('freeplaymenu/albums/locked'));
			else
				album.loadGraphic(Paths.image('freeplaymenu/albums/' + songs[curSelected].album));
		}
		else
			album.loadGraphic(Paths.image('freeplaymenu/albums/placeholder'));

		changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	private function positionHighscore()
	{
		scoreBG.scale.x = scoreText.width * 2 + 10;
	}
} class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var album:String = "";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, album:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.album = album;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
