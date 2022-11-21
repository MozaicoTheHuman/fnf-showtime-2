package;

#if desktop
import Discord.DiscordClient;
#end
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
import lime.utils.Assets;

using StringTools;

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

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Credits", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			['SHOWTIME TEAM'],
			[
				'Mozaico',
				'mozaico',
				'Director, Main Artist/Animator,\nCoder, Charter, Maavo VA',
				'https://www.youtube.com/c/MaavoTheHuman/',
				'FFDD33'
			],
			[
				'Derker Bluer',
				'derki',
				'Musician',
				'https://www.youtube.com/user/ElRinconAntiEstres',
				'FFDD33'
			],
			['Joan Atlas', 'joancitoatlantis', 'Musician', 'https://twitter.com/joan_atlas', 'FFDD33'],
			['Ejsu Multimedia', 'ejsu', 'Musician', 'https://www.youtube.com/channel/UCIW8uHlBQ8ZOaxuo3PzpTig', 'FFDD33'],
			[
				'Vtroy Jerof',
				'vtroy',
				'Musician',
				'https://www.youtube.com/c/VtroyJerof/',
				'FFDD33'
			],
			[
				'Hanzo Santiago',
				'hanzo',
				'Musician, Artist, Animator, Hanzo VA',
				'https://www.youtube.com/channel/UC6QSZk8SYmTm_VoZAPOW6NQ',
				'FFDD33'
			],
			['Gabriel ML', 'gabo', 'Musician', 'https://www.youtube.com/channel/UCi3ibK4Z7HEXiPQsNTLOaZg', 'FFDD33'],
			['Krimson', 'krimson', 'Musician', 'https://www.youtube.com/channel/UCpcLjVqgiEaYMmgADVbXZVw', 'FFDD33'],
			['Sandwich', 'sandwich', 'Coder', 'https://www.google.com/search?q=sandwich&client=opera-gx&hs=tJN&source=lnms&tbm=isch&sa=X&ved=2ahUKEwih3afKpOT6AhXrLrkGHc9lBfUQ_AUoAnoECAEQBA&biw=1879&bih=939&dpr=1', 'FFDD33'],
			['Beru', 'beru', 'Coder', 'https://twitter.com/art_keny', 'FFDD33'],
			['YOUK', 'youkdev', 'Coder', 'https://twitter.com/YOUKdev', 'FFDD33'],
			['Shiroko', 'shiroko', 'Coder', 'https://twitter.com/Shiroko_dev', 'FFDD33'],
			['GenoX', 'genox', 'Coder and Main Chromatic Scales', 'https://twitter.com/GenoXACT2', 'FFDD33'],
			['SrPerez', 'penez', 'Coder', 'https://twitter.com/NewSrPerez/', 'FFDD33'],
			[
				'Akai',
				'elpepe',
				'Coder Lol (Dont Press Me)',
				'estovademasiadodificilhermanosientaselibresdedispararlealapantalla',
				'FFFFFF'
			],
			[
				'EsoMarx',
				'elchavoballistic',
				'Background Artist',
				'https://www.youtube.com/channel/UCeQKrBu2HeKOw2EnlL4BKNg',
				'FFDD33'
			],
			[
				'Natu',
				'natu',
				'Background Artist',
				'https://twitter.com/nataliofag',
				'FFDD33'
			],
			[
				'LeBasth',
				'lebasth',
				'Storyboard Artist',
				'https://twitter.com/Le_Basth',
				'FFDD33'
			],
			[
				'Maris',
				'maris',
				'Storyboard Artist',
				'https://twitter.com/Marisgameplays',
				'FFDD33'
			],
			[
				'TzenZoule',
				'tzen',
				'Storyboard Artist',
				'https://twitter.com/AbZoule',
				'FFDD33'
			],
			[
				'Shey Pancake',
				'sheicita',
				'Cutscene Artist',
				'https://twitter.com/shey_pancake',
				'FFDD33'
			],
			['Sulayre', 'sul', 'Cutscene Animator', 'https://twitter.com/Sulayre', 'FFDD33'],
			['Cote', 'cote', 'Cutscene Animator', 'https://twitter.com/Sulayre', 'FFDD33'],
			[
				'Nautical',
				'nautical',
				'Menu Artist',
				'https://twitter.com/nauticallll',
				'FFDD33'
			],
			[
				'Valenn',
				'valenn',
				'Artist',
				'https://twitter.com/oh_pls_jsjss',
				'FFDD33'
			],
			[
				'Beezy',
				'beezy',
				'Icon and Menu Artist',
				'https://www.twitter.com/BeezyLoove',
				'FFDD33'
			],
			[
				'Miki',
				'miki',
				'Ivette VA',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'FFDD33'
			],
			[
				'Riusaki',
				'Riusaki',
				'Maritza VA',
				'https://media.discordapp.net/attachments/893307883415023616/967080071619833917/c-mamoe.png',
				'FFDD33'
			],
			[
				'Wach',
				'wach',
				'Animation Assistant',
				'https://twitter.com/Wachine_Machine',
				'FFDD33'
			],
			['Poncho', 'poncho', 'Logo', 'https://twitter.com/mrneedIemouse', 'FFDD33'],
			[
				'DegoDraws',
				'dego',
				'Menu Background Artist',
				'https://twitter.com/DegoDraws',
				'FFDD33'
			],
			[
				'KoichiM4',
				'koichi',
				'Light On chromatic scales',
				'https://twitter.com/Koixis_',
				'FFDD33'
			],
			[
				'Andere',
				'andere',
				'Tokyo Charter',
				'https://www.youtube.com/c/Andere27',
				'FFDD33'
			],
			[
				'AndresLoquendero0',
				'andres',
				'Maavo PDFTA model port',
				'https://www.youtube.com/c/Andere27',
				'FFDD33'
			],	
			[''],
			["SPECIAL THANKS"],
			[
				'CompotaHyper',
				'compotito',
				"For testing the mod's beta on stream",
				'https://www.youtube.com/channel/UCZOBgWVv1Scf_1s5g8gkjQQ/',
				'F73838'
			]
		];

		for (i in pisspoop)
		{
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			optionText.yAdd -= 70;
			optionText.forceX = optionText.x;
			// optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);

				if (curSelected == -1)
					curSelected = i;
			}
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

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
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
					changeSelection(-1 * shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(1 * shiftMult);
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
				{
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
				}
				else
				{
					FlxG.sound.play(Paths.sound('stunsound'), 0.7);
					var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[20][3]);
					iconArray.push(icon);
					iconArray[19] = iconArray[iconArray.length];
				}
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
			if (!item.isBold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
					item.forceX = item.x;
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
					item.forceX = item.x;
				}
			}
		}
		super.update(elapsed);
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

		descText.text = creditsStuff[curSelected][2];
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
