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
			['Mozaico', 'mozaico','', 'https://youtube.com/@MozaicoTheHuman', 'FF0000'],
			['Derker Bluer', 'derki','', 'https://youtube.com/@DerkerBluer', '2E48E6'],
			['Shey Pancake', 'panquesito','', 'https://twitter.com/shey_pancake', '9400Ff'],
			['Joan Atlas', 'joancitoatlantis','', 'https://twitter.com/joan_atlas', 'FBA4FF'],
			['Ejsu Multimedia', 'ejsu','', 'https://youtube.com/@EjsuMultimedia', 'FF9F2A'],
			['Vtroy Jerof', 'vtroy','', 'https://youtube.com/@VtroyJerof', '2A91FF'],
			[
				'Soga Celeste',
				'hanzo',
				'',
				'https://youtube.com/@SogaCeleste.-HanzoSantiago-',
				'FF2A4C'
			],
			['FlameMind', 'flamemind','', 'https://twitter.com/flamemind10', '5BD1F0'],
			['Gabriel ML', 'gabo','', 'https://gabitoml.newgrounds.com/', '5B7AF0'],
			['Vzer', 'vzer','', 'https://youtube.com/@TheVzer', 'AF5D5D'],
			['JustDemianAgain', 'demian','', 'https://twitter.com/justdemianagain', 'F0A9C0'],
			['NaxoAtWork', 'naxo','', 'https://youtube.com/@NaxoAtWork', 'D16533'],
			['DIA', 'dia', 'UTAU Voicebanks', 'https://twitter.com/JEVILLOVER', 'B069F5'],
			[
				'Sandwich',
				'sandwich',
				'Coder',
				'https://rare-gallery.com/mocahbig/26506-Sandwich-4k-Ultra-HD-Wallpaper.jpg',
				'69F5BC'
			],
			[
				'YOUK',
				'youkdev',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'D1718A'
			],
			['Shiroko', 'shiroko','', 'https://twitter.com/Shiroko_dev', 'FFBEF9'],
			[
				'GenoX',
				'genox',
				'',
				'https://i.pinimg.com/474x/90/23/5c/90235c8967171e76274234c3fd8aac03.jpg',
				'BED7FF'
			],
			['SrPerez', 'penez','', 'https://twitter.com/NewSrPerez/', '465CE1'],
			['Stzr', 'stzr','', 'https://twitter.com/stzr_real', '46E1CC'],
			[
				'ValEnd',
				'elpepe',
				'',
				'estovademasiadodificilhermanosientaselibresdedispararlealapantalla',
				'FFFFFF'
			],
			['PointyyESM', 'pointi','', 'https://twitter.com/PointyyESM', '001BFF'],
			['EsoMarx', 'elchavoballistic','', 'https://youtube.com/@esomarx3074', 'FFCDF9'],
			[
				'Teeth',
				'tetasmasculinasdefurrotesavecesmepreocupascandace',
				'',
				'https://twitter.com/teethlust',
				'00F014'
			],
			['Koi', 'koi','', 'https://twitter.com/_Sir_Koi_', 'F369B8'],
			['Natu', 'natu','', 'https://twitter.com/nataliofag', 'B4E6F3'],
			['LeBasth', 'lebasth','', 'https://twitter.com/Le_Basth', '434EE1'],
			[
				'Maris',
				'maris',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'E9776A'
			],
			[
				'YokuTzen',
				'tzen',
				'',
				'https://pbs.twimg.com/media/FBgr01CWUAInM9Q?format=jpg&name=large',
				'A5FCF4'
			],
			['Fufi', 'fufi','', 'https://mrfoofy.newgrounds.com/', '33BAE6'],
			['TatoxicLG', 'tatoxic','', 'https://twitter.com/tatoxicLg', '725AEB'],
			['Nautical', 'nautical','', 'https://twitter.com/nauticallll', 'EB5A5A'],
			['Valenn', 'valenn','', 'https://twitter.com/oh_pls_jsjss', 'CE3A3A'],
			['Beezy', 'beezy','', 'https://www.twitter.com/BeezyLoove', '423F92'],
			['thixie', 'thixie','', 'https://twitter.com/thixieedy', 'F8B491'],
			['Wach', 'wach','', 'https://twitter.com/Wachine_Machine', '3132C2'],
			['Poncho', 'poncho','', 'https://twitter.com/ElPonchitoPio', 'C23131'],
			['DegoDraws', 'dego','', 'https://twitter.com/DegoDraws', 'C6308A'],
			['KoiM4', 'koichi','', 'https://twitter.com/koim4_', '3088C6'],
			['Andere', 'andere','', 'https://youtube.com/@4ndere', 'FF00F9'],
			[Language.credits.categorys[1]],
			['Vtroy Jerof', 'vtroy','', 'https://youtube.com/@VtroyJerof', '2A91FF'],
			['cristo-ball', 'cristobola','', 'https://twitter.com/Cristob88244965', 'FFFFFF'],
			['Beezy', 'beezy','', 'https://www.twitter.com/BeezyLoove', '423F92'],
			['Shey Pancake', 'panquesito','', 'https://twitter.com/shey_pancake', '9400Ff'],
			[
				'Soga Celeste',
				'hanzo',
				'',
				'https://youtube.com/@SogaCeleste.-HanzoSantiago-',
				'FF2A4C'
			],
			['_j.meta', 'javi','', 'https://www.instagram.com/_j.meta/', '64CCC9'],
			['Suabruh', 'suabruh','', 'https://twitter.com/suabruh', '0040FF'],
			[Language.credits.categorys[2]],
			['Marcelo Nunes', 'marcelonfbarros','', 'https://www.instagram.com/marcelonfbarros/', '0040FF'],
			['zeff111', 'zeff','', 'https://twitter.com/MZeff111', '0040FF'],
			['Oliver As Latias', 'oliver','', 'https://www.youtube.com/@OliverTEENAGER13', '0040FF'],
			[Language.credits.categorys[3]],
			['ShaminBECA', 'nada','', 'https://twitter.com/ShaminBECA', 'FFDD33'],
			['InukoExo', 'nada','', 'https://twitter.com/InukoExo', 'F01E6A'],
			[
				'AndresLoquendero0',
				'nada',
				'',
				'https://www.youtube.com/@AndresELLoquendero0',
				'FFDD33'
			],
			[
				'CompotaHyper',
				'compotito',
				'',
				'https://youtube.com/@compotahyperlol6245',
				'3759FF'
			],
			['Sulayre', 'sul','', 'https://twitter.com/Sulayre', 'E96719'],
			[
				'Miki',
				'miki',
				'',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'591FA2'
			],
			[
				'Riusaki Fujioka',
				'thixie',
				'',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'DF69D0'
			],
			['Neru', 'nada','', 'https://twitter.com/Neru_Sleep', 'FFFFFF'],
			['Tanjiro Taidana', 'nada','', 'https://twitter.com/tanjirotaidana', 'DB43B8'],
			[
				'Kishio',
				'nada',
				'',
				'http://web.archive.org/web/20140214203506/http://www1.bbiq.jp/gdgdgdgd/',
				'FEB600'
			],
			['Matriculaso', 'nada','', 'https://twitter.com/Matriculaso/', '0094FE'],
			[
				'Los Basuros',
				'nada',
				'',
				'https://cdn.discordapp.com/attachments/899372708851249282/990441090333159474/unknown.png',
				'FFDD33'
			],
			['ninjamuffin99', 'nada','', 'https://ninjamuffin99.newgrounds.com/', 'CF2D2D'],
			['PhantomArcade', 'nada','', 'https://phantomarcade.newgrounds.com/', 'FADC45'],
			['kawaisprite', 'nada','', 'https://drugpop.bandcamp.com/', '378FC7'],
			['evilsk8r', 'nada','', 'https://evilsk8r.newgrounds.com/', '5ABD4B']
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
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
					iconArray[19].visible = false;
				Paths.currentModDirectory = '';

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

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
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
		for (item in grpOptions.members)
		{
			if (!item.bold)
			{
				var lerpVal:Float = FlxMath.bound(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	function changeDaWorld()
	{
		isEasterEgg = lock = true;
		iconArray[19].loadGraphic(Paths.image('credits/estovademasiadodificilhermanosientaselibresdedispararlealapantalla'));
		FlxG.sound.play(Paths.sound('easterEgg/goodbye'), 0.7);
		FlxTween.color(bg, 1, bg.color, 0xFF252525, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(iconArray[19], {alpha: 0}, 3.5, {startDelay: 6.5});
				FlxTween.color(bg, 3, bg.color, CoolUtil.colorFromString(creditsStuff[curSelected][4]), {startDelay: 9.5});
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

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
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

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}
}
