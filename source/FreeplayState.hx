package;

#if desktop
import Discord.DiscordClient;
#end
import WeekData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var griddiffs:FlxSprite;
	var gridcenter:FlxSprite;
	var griddown:FlxSprite;
	var album:FlxSprite;
	var star:FlxSprite;
	var songsBG:FlxSprite;
	var diffText:FlxSprite;
	var arrLeft:FlxSprite;
	var arrRight:FlxSprite;

	var waveA:FlxBackdrop;
	var waveB:FlxBackdrop;
	var waveC:FlxBackdrop;
	var waveA2:FlxBackdrop;
	var waveB2:FlxBackdrop;
	var waveC2:FlxBackdrop;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Freeplay", null);
		#end

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

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('freeplaymenu/bg'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		waveA = new FlxBackdrop(null, 0.25, 0.25, true, false);
		waveA.loadGraphic(Paths.image('freeplaymenu/blackthingup'));
		add(waveA);

		waveB = new FlxBackdrop(null, 0.50, 0.50, true, false);
		waveB.loadGraphic(Paths.image('freeplaymenu/darkredthingup'));
		add(waveB);

		waveC = new FlxBackdrop(null, 1, 1, true, false);
		waveC.loadGraphic(Paths.image('freeplaymenu/redthingup'));
		add(waveC);

		gridcenter = new FlxSprite(360, 210).loadGraphic(Paths.image('freeplaymenu/gridCenter'));
		gridcenter.antialiasing = ClientPrefs.globalAntialiasing;
		add(gridcenter);

		album = new FlxSprite(105, 140);
		album.loadGraphic(Paths.image('freeplaymenu/albums/placeholder'));
		album.antialiasing = ClientPrefs.globalAntialiasing;
		add(album);

		star = new FlxSprite(370, 130);
		star.loadGraphic(Paths.image('freeplaymenu/star'));
		star.antialiasing = ClientPrefs.globalAntialiasing;
		add(star);

		griddown = new FlxSprite(0, 365).loadGraphic(Paths.image('freeplaymenu/grid'));
		griddown.antialiasing = ClientPrefs.globalAntialiasing;
		add(griddown);

		songsBG = new FlxSprite(455, 0).loadGraphic(Paths.image('freeplaymenu/songsBG'));
		songsBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(songsBG);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		griddiffs = new FlxSprite(780, 0).loadGraphic(Paths.image('freeplaymenu/gridDiffs'));
		griddiffs.antialiasing = ClientPrefs.globalAntialiasing;
		add(griddiffs);

		diffText = new FlxSprite(870, 25);
		diffText.loadGraphic(Paths.image('freeplaymenu/diffs'), true, 370, 45);
		diffText.animation.add('diffficult', [2, 1, 0], 0, false);
		diffText.animation.play('diffficult');
		add(diffText);

		var ui_tex = Paths.getSparrowAtlas('freeplaymenu/arrows');

		arrRight = new FlxSprite(1240, 25);
		arrRight.frames = ui_tex;
		arrRight.animation.addByIndices('idle', "arrRight", [0], "", 0);
		arrRight.animation.addByIndices('pressed', "arrRight", [1], "", 0);
		arrRight.animation.play('idle');
		add(arrRight);

		arrLeft = new FlxSprite(845, 25);
		arrLeft.frames = ui_tex;
		arrLeft.animation.addByIndices('idle', "arrLeft", [0], "", 0);
		arrLeft.animation.addByIndices('pressed', "arrLeft", [1], "", 0);
		arrLeft.animation.play('idle');
		add(arrLeft);

		waveA2 = new FlxBackdrop(null, 0.25, 0.25, true, false);
		waveA2.y = 630;
		waveA2.loadGraphic(Paths.image('freeplaymenu/blackthing'));
		add(waveA2);

		waveB2 = new FlxBackdrop(null, 0.50, 0.50, true, false);
		waveB2.y = 660;
		waveB2.loadGraphic(Paths.image('freeplaymenu/darkredthing'));
		add(waveB2);

		waveC2 = new FlxBackdrop(null, 1, 1, true, false);
		waveC2.y = 660;
		waveC2.loadGraphic(Paths.image('freeplaymenu/redthing'));
		add(waveC2);

		scoreText = new FlxText(5, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);

		scoreBG = new FlxSprite().makeGraphic(1, 42, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		changeSelection();
		changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "P para abrir el skin selector/SPACE to listen the Song / RESET to Reset the Score";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x + 4, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
		text.scrollFactor.set();
		add(text);
		super.create();
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

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;

				if (songCharacters.length != 1)
					num++;
			}
	}*/
	var instPlaying:Int = -1;

	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var chars = FlxG.keys.justPressed.P;
		var shiftMult:Int = 1;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

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

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
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
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if (!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop))
				&& !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop)))
			{
			#else
			if (!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop)))
			{
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
		}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
	else if (controls.RESET)
	{
		openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
		if (chars)
			MusicBeatState.switchState(new CharactersMenuState());
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

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length - 1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
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
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		if (OpenFlAssets.exists(Paths.image('freeplaymenu/albums/' + songs[curSelected].album)))
			album.loadGraphic(Paths.image('freeplaymenu/albums/' + songs[curSelected].album));
		else
			album.loadGraphic(Paths.image('freeplaymenu/albums/'));

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
