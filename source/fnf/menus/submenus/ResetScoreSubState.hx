package fnf.menus.submenus;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import fnf.system.CoolUtil;
import fnf.system.Highscore;
import fnf.system.MusicBeatSubstate;
import fnf.system.Paths;
import fnf.system.WeekData;
import fnf.system.visuals.Alphabet;
import fnf.system.visuals.HealthIcon;

using StringTools;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var icon:HealthIcon;
	var camUI:FlxCamera;
	var yesText:Alphabet;
	var noText:Alphabet;

	var song:String;
	var difficulty:Int;
	var week:Int;

	var onYes:Bool = false;

	// Week -1 = Freeplay
	public function new(song:String, difficulty:Int, character:String, week:Int = -1)
	{
		super();

		this.song = song;
		this.difficulty = difficulty;
		this.week = week;

		camUI = new FlxCamera();
		camUI.bgColor = 0;
		FlxG.cameras.add(camUI, false);

		var name:String = song;

		if (week > -1)
		{
			name = WeekData.weeksLoaded.get(WeekData.weeksList[week]).weekName;
		}

		name += ' (' + CoolUtil.difficultyStuff[difficulty][0] + ')?';

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.cameras = [camUI];
		add(bg);

		var tooLong:Float = (name.length > 18) ? 0.8 : 1; // Fucking Winter Horrorland

		var resetText:Alphabet = new Alphabet(0, 180, "Reset the score of", true);
		resetText.screenCenter(X);
		resetText.alpha = 0;
		resetText.cameras = [camUI];
		add(resetText);

		var songText:Alphabet = new Alphabet(0, resetText.y + 90, name, true);
		songText.scaleX = tooLong;
		songText.screenCenter(X);
		if (week == -1)
			songText.x += 60 * tooLong;
		songText.alpha = 0;
		songText.cameras = [camUI];
		add(songText);

		if (week == -1)
		{
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(resetText.x - icon.width + (10 * tooLong), resetText.y - 30);
			icon.alpha = 0;
			icon.cameras = [camUI];
			add(icon);
		}
		alphabetArray.push(resetText);
		alphabetArray.push(songText);

		yesText = new Alphabet(0, songText.y + 150, 'Yes', true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.cameras = [camUI];
		add(yesText);

		noText = new Alphabet(0, songText.y + 150, 'No', true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.cameras = [camUI];
		add(noText);

		updateOptions();
	}

	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if (bg.alpha > 0.6)
			bg.alpha = 0.6;

		for (i in 0...alphabetArray.length)
		{
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}
		if (week == -1)
			icon.alpha += elapsed * 2.5;

		if (controls.UI_LEFT_P || controls.UI_RIGHT_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		else if (controls.ACCEPT)
		{
			if (onYes)
			{
				if (week == -1)
				{
					Highscore.resetSong(song, difficulty);
				}
				else
				{
					Highscore.resetWeek(WeekData.weeksList[week], difficulty);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
	}

	function updateOptions()
	{
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		if (week == -1)
			icon.animation.curAnim.curFrame = confirmInt;
	}
}
