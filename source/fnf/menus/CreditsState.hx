package fnf.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import fnf.system.CoolUtil;
import fnf.system.Language;
import fnf.system.MusicBeatState;
import fnf.system.Paths;
import fnf.system.visuals.Alphabet;
import fnf.system.visuals.AttachedSprite;
import lime.utils.Assets;

using StringTools;

#if desktop
import fnf.system.Discord.DiscordClient;
#end
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;
	var creditsDesc:Array<String>;

	var offsetThing:Float = -75;

	static var isEasterEgg:Bool = false;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Credits Menu", null);
		#end
		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		creditsDesc = Language.credits.part;

		var pisspoop:Array<Array<String>> = [
			[Language.credits.categorys[0]],
			['Mozaico', 'mozaico', '', 'https://youtube.com/@MozaicoTheHuman', 'FFDD33'],
			['Derker Bluer', 'derki', '', 'https://youtube.com/@DerkerBluer', 'FFDD33'],
			['Joan Atlas', 'joancitoatlantis', '', 'https://twitter.com/joan_atlas', 'FFDD33'],
			['Ejsu Multimedia', 'ejsu', '', 'https://youtube.com/@EjsuMultimedia', 'FFDD33'],
			['Vtroy Jerof', 'vtroy', '', 'https://youtube.com/@VtroyJerof', 'FFDD33'],
			[
				'Soga Celeste',
				'hanzo',
				'',
				'https://youtube.com/@SogaCeleste.-HanzoSantiago-',
				'FFDD33'
			],
			['FlameMind', 'flamemind', '', 'https://twitter.com/flamemind10', 'FFDD33'],
			['Gabriel ML', 'gabo', '', 'https://youtube.com/@gabrielml4925', 'FFDD33'],
			['Krimson', 'krimson', '', 'https://youtube.com/@krimson7430', 'FFDD33'],
			['Vzer', 'nada', '', 'https://youtube.com/@TheVzer', 'FFDD33'],
			['NaxoAtWork', 'nada', '', 'https://youtube.com/@NaxoAtWork', 'FFDD33'],
			['DIA', 'dia', 'UTAU Voicebanks', 'https://twitter.com/YanKitiCats', 'FFDD33'],
			[
				'Sandwich',
				'sandwich',
				'',
				'https://rare-gallery.com/mocahbig/26506-Sandwich-4k-Ultra-HD-Wallpaper.jpg',
				'FFDD33'
			],
			[
				'Beru',
				'beru',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'FFDD33'
			],
			[
				'YOUK',
				'youkdev',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'FFDD33'
			],
			['Shiroko', 'shiroko', '', 'https://twitter.com/Shiroko_dev', 'FFDD33'],
			[
				'GenoX',
				'genox',
				'',
				'https://i.pinimg.com/474x/90/23/5c/90235c8967171e76274234c3fd8aac03.jpg',
				'FFDD33'
			],
			['SrPerez', 'penez', '', 'https://twitter.com/NewSrPerez/', 'FFDD33'],
			['Stzr', 'nada', '', 'https://twitter.com/stzr_real', 'FFDD33'],
			[
				'ValEnd',
				'elpepe',
				'',
				'estovademasiadodificilhermanosientaselibresdedispararlealapantalla',
				'FFFFFF'
			],
			['EsoMarx', 'elchavoballistic', '', 'https://youtube.com/@esomarx3074', 'FFDD33'],
			['Teeth', 'nada', '', 'https://twitter.com/teethlust', 'FFDD33'],
			['Koi', 'nada', '', 'https://twitter.com/_Sir_Koi_', 'FFDD33'],
			['Natu', 'natu', '', 'https://twitter.com/nataliofag', 'FFDD33'],
			['LeBasth', 'lebasth', '', 'https://twitter.com/Le_Basth', 'FFDD33'],
			[
				'Maris',
				'maris',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'FFDD33'
			],
			[
				'TzenZoule',
				'tzen',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'FFDD33'
			],
			['Shey Pancake', 'sheicita', '', 'https://twitter.com/shey_pancake', 'FFDD33'],
			[
				'Cote',
				'cote',
				'',
				'https://cdn.discordapp.com/attachments/893308970213720065/1062570173489483786/maZmDeNx_400x400.jpg',
				'FFDD33'
			],
			['TatoxicLG', 'nada', '', 'https://twitter.com/tatoxicLg', 'FFDD33'],
			['Nautical', 'nautical', '', 'https://twitter.com/nauticallll', 'FFDD33'],
			['Valenn', 'valenn', '', 'https://twitter.com/oh_pls_jsjss', 'FFDD33'],
			['Beezy', 'beezy', '', 'https://www.twitter.com/BeezyLoove', 'FFDD33'],
			['thixie', 'thixie', '', 'https://twitter.com/thixieedy', 'FFDD33'],
			['Wach', 'wach', '', 'https://twitter.com/Wachine_Machine', 'FFDD33'],
			['Poncho', 'poncho', '', 'https://twitter.com/ElPonchitoPio', 'FFDD33'],
			['DegoDraws', 'dego', '', 'https://twitter.com/DegoDraws', 'FFDD33'],
			['KoiM4', 'koichi', '', 'https://twitter.com/koim4_', 'FFDD33'],
			['Andere', 'andere', '', 'https://youtube.com/@4ndere', 'FFDD33'],
			[
				'AndresLoquendero0',
				'nada',
				'',
				'https://www.youtube.com/@AndresELLoquendero0',
				'FFDD33'
			],
			[Language.credits.categorys[1]],
			['ShaminBECA', 'nada', '', 'https://twitter.com/ShaminBECA', 'FFDD33'],
			['InukoExo', 'nada', '', 'https://twitter.com/InukoExo', 'FFDD33'],
			[
				'CompotaHyper',
				'compotito',
				"",
				'https://youtube.com/@compotahyperlol6245',
				'F73838'
			],
			['Sulayre', 'sul', '', 'https://twitter.com/Sulayre', 'FFDD33'],
			[
				'Miki',
				'miki',
				'',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'FFDD33'
			],
			[
				'Riusaki Fujioka',
				'nada',
				'',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'FFDD33'
			],
			['Neru', 'nada', '', 'https://twitter.com/Neru_Sleep', 'FFDD33'],
			['Tanjiro Taidana', 'nada', '', 'https://twitter.com/tanjirotaidana', 'FFDD33'],
			[
				'Kishio',
				'nada',
				'',
				'http://web.archive.org/web/20140214203506/http://www1.bbiq.jp/gdgdgdgd/',
				'FFDD33'
			],
			[
				'Matriculaso',
				'nada',
				'',
				'http://web.archive.org/web/20140214203506/http://www1.bbiq.jp/gdgdgdgd/',
				'FFDD33'
			],
			['PointyyESM', 'nada', '', 'https://twitter.com/PointyyESM', 'FFDD33'],
			[
				'Los Basuros',
				'nada',
				'',
				'https://cdn.discordapp.com/attachments/899372708851249282/990441090333159474/unknown.png',
				'FFDD33'
			]
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.screenCenter(X);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);
			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}
				if (creditsStuff[i][1] != 'nada')
				{
					var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
					icon.xAdd = optionText.width + 10;
					icon.sprTracker = optionText;
					icon.copyAlpha = creditsStuff[i][1] != 'elpepe';
					iconArray.push(icon);
					add(icon);
				}

				if (i == 20 && isEasterEgg)
					iconArray[16].visible = false;

				if (curSelected == -1)
					curSelected = i;
			}
			else
				optionText.alignment = CENTERED;
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER /*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	var lock:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7 && !lock)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music.volume > 0 && lock)
			FlxG.sound.music.volume -= 0.7 * FlxG.elapsed;

		if (!quitting && !lock)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT)
			{
				if (curSelected != 20)
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
				else if (!isEasterEgg)
					changeDaWorld();
			}
			if (controls.BACK)
			{
				if (colorTween != null)
				{
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		super.update(elapsed);
	}

	// 0, 2, 4.5, 7.5, 10.5
	function changeDaWorld()
	{
		isEasterEgg = lock = true;
		iconArray[16].loadGraphic(Paths.image('credits/estovademasiadodificilhermanosientaselibresdedispararlealapantalla'));
		FlxG.sound.play(Paths.sound('easterEgg/goodbye'), 0.7);
		FlxTween.color(bg, 1, bg.color, 0xFF252525, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(iconArray[16], {alpha: 0}, 3.5, {startDelay: 6.5});
				FlxTween.color(bg, 3, bg.color, getCurrentBGColor(), {startDelay: 9.5});
			}
		});

		for (item in grpOptions.members)
		{
			FlxTween.tween(item, {alpha: 0.2}, 1, {
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(item, {alpha: 1}, 3, {
						startDelay: 9.5,
						onComplete: function(twn:FlxTween)
						{
							lock = false;
						}
					});
				}
			});
		}
	}

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsDesc[curSelected];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor()
	{
		var bgColor:String = creditsStuff[curSelected][4];
		if (!bgColor.startsWith('0x'))
		{
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}
}
