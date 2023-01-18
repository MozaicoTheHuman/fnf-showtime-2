import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Hidden achievement
		["Gran Espectaculo",		 "Termina la Week con mas del 90% de acurracy en hard",																			 false],
		["Maldito Experto",		     "Completa 'Showtime' sin fallos",																								 false],
		["Detective",				 "Pon el codigo secreto en el menu debug. \nPistas: Motor de videojuegos de lucha, primera aparicion de Maavo, Ronald McDonald", false],
		["Partida Perfecta",		 "Completa la cancion 'kfm.mid' sin fallos",																					 false],
		["Manco",					 "Pierde 3 veces seguidas",																										 false],
		["Literal no tienes manos",	 "Pierde 10 veces en total",																									 false],
		["WIII GANE!",			 	 "Pierde en Lovely",																											 false],
		["Perfeccionista",		 	 "Completa todas las canciones sin fallos en Hard",																				 false],
		["Enfermo",				 	 "Completa 'Tokyo Teddy Bear' en dificultad Extrema sin fallos",																 false],
		["Friday Night Funkin'", 	 "Juega un viernes por la noche xd",							 																  true],
		["Y los telones se cierran", "Consigue todos los logros",																									 false],
		["Le sabes",				 "Savedata del mod del Derker",																									  true]
	];

	public static var achievementsUnlocked:Array<Dynamic> = [ //Save string and Achievement tag + is it unlocked?
		['great_show', 	      false],		//0
		['expert', 			  false],		//1
		['detective', 		  false],		//2
		['perfect', 		  false],		//3
		['manco', 			  false],		//4
		['no_hands', 		  false],		//5
		['gane', 			  false],		//6
		['perfeccionist',     false],		//7
		['sick', 			  false],		//8
		['friday_night_play', false],		//9
		['telones', 		  false], 		//10
		['good_taste', 		  false] 		//11
	];

	public static var henchmenDeath:Int = 0;
	public static function unlockAchievement(id:Int):Void {
		FlxG.log.add('Completed achievement "' + achievementsStuff[id][0] +'"');
		achievementsUnlocked[id][1] = true;
		FlxG.sound.play(Paths.sound('awardMenu'), 0.7);
	}
	public static function changeLang(){
		if (ClientPrefs.language == "English")
		{
			for (i in 0...achievementsUnlocked.length)
				{
					achievementsStuff[i][0] = Language.achievementsnames[i];
					achievementsStuff[i][1] = Language.achievementsdescnames[i];
				}
		}
		else if (ClientPrefs.language == "Spanish")
		{
			for (i in 0...achievementsUnlocked.length)
				{
					achievementsStuff[i][0] = Language.achievementsnames[i];
					achievementsStuff[i][1] = Language.achievementsdescnames[i];
				}
		}
	}
	public static function allAchievements(){
		var logros:Array<Bool> = [];
		var x:Int = 0;
		for (i in 0...10)
		{
			trace(i);
			if (achievementsUnlocked[i][1])
			{
				logros[x] = true;
				x++;
				trace(achievementsUnlocked[i][1]);

			}
			
		}
		trace(logros);
		trace(logros.length);
		if (logros.length == 10)
		{
			return true;
		}
		return false;
	}
	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsUnlocked != null) {
				FlxG.log.add("Trying to load stuff");
				var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
				for (i in 0...achievementsUnlocked.length) {
					for (j in 0...savedStuff.length) {
						if(achievementsUnlocked[i][0] == savedStuff[j]) {
							achievementsUnlocked[i][1] = true;
						}
					}
				}
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
			changeLang();
		}

		// You might be asking "Why didn't you just fucking load it directly dumbass??"
		// Well, Mr. Smartass, consider that this class was made for Mind Games Mod's demo,
		// i'm obviously going to change the "Psyche" achievement's objective so that you have to complete the entire week
		// with no misses instead of just Psychic once the full release is out. So, for not having the rest of your achievements lost on
		// the full release, we only save the achievements' tag names instead. This also makes me able to rename
		// achievements later as long as the tag names aren't changed of course.

		// Edit: Oh yeah, just thought that this also makes me able to change the achievements orders easier later if i want to.
		// So yeah, if you didn't thought about that i'm smarter than you, i think

		// buffoon
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	public function new(x:Float = 0, y:Float = 0, id:Int = 0) {
		super(x, y);

		if(Achievements.achievementsUnlocked[id][1]) {
			loadGraphic(Paths.image('achievementgrid'), true, 150, 150);
			animation.add('icon', [id], 0, false, false);
			animation.play('icon');
		} else {
			loadGraphic(Paths.image('lockedachievement'));
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}

class AchievementObject extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
	public function new(id:Int, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();
		var achievementBG:FlxSprite = new FlxSprite(60, 50).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		var achievementIcon:FlxSprite = new FlxSprite(achievementBG.x + 10, achievementBG.y + 10).loadGraphic(Paths.image('achievementgrid'), true, 150, 150);
		achievementIcon.animation.add('icon', [id], 0, false, false);
		achievementIcon.animation.play('icon');
		achievementIcon.scrollFactor.set();
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();
		achievementIcon.antialiasing = ClientPrefs.globalAntialiasing;

		var achievementName:FlxText = new FlxText(achievementIcon.x + achievementIcon.width + 20, achievementIcon.y + 16, 280, Achievements.achievementsStuff[id][0], 16);
		achievementName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementName.scrollFactor.set();

		var achievementText:FlxText = new FlxText(achievementName.x, achievementName.y + 32, 280, Achievements.achievementsStuff[id][1], 16);
		achievementText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		achievementText.scrollFactor.set();

		add(achievementBG);
		add(achievementName);
		add(achievementText);
		add(achievementIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		achievementBG.cameras = cam;
		achievementName.cameras = cam;
		achievementText.cameras = cam;
		achievementIcon.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}
