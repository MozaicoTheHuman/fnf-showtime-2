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
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
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

	var isEasterEgg:Bool = false;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits Menu", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			[Language.credits_categorys[0]],
			[
				'Mozaico',
				'mozaico',
				'Director, Main Artist/Animator,\nCoder, Charter, Maavo VA,\nMaavo PDFMM+ Model Import',
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
			['Ejsu Multimedia', 'ejsu', 'Musician', 'https://www.youtube.com/@EjsuMultimedia/', 'FFDD33'],
			[
				'Vtroy Jerof',
				'vtroy',
				'Musician',
				'https://www.youtube.com/c/VtroyJerof/',
				'FFDD33'
			],
			[
				'Soga Celeste',
				'hanzo',
				'Musician, Animator, Hanzo VA',
				'https://www.youtube.com/@HanzoSantiagoGharbanzo/',
				'FFDD33'
			],
			['FlameMind', 'flamemind', 'Musician', 'https://twitter.com/flamemind10', 'FFDD33'],			
			['Gabriel ML', 'gabo', 'Musician', 'https://www.youtube.com/channel/UCi3ibK4Z7HEXiPQsNTLOaZg', 'FFDD33'],
			['Krimson', 'krimson', 'Musician', 'https://www.youtube.com/@krimson7430', 'FFDD33'],
			['Vzer', 'vzer', 'Musician', 'https://www.youtube.com/@TheVzer', 'FFDD33'],		
			['NaxoAtWork', 'naxo', 'Musician', 'https://www.youtube.com/@NaxoAtWork', 'FFDD33'],	
			['DIA', 'dia', 'UTAU Voicebanks', 'https://twitter.com/YanKitiCats', 'FFDD33'],									
			['Sandwich', 'sandwich', 'Coder', 'https://www.google.com/search?q=sandwich&client=opera-gx&hs=tJN&source=lnms&tbm=isch&sa=X&ved=2ahUKEwih3afKpOT6AhXrLrkGHc9lBfUQ_AUoAnoECAEQBA&biw=1879&bih=939&dpr=1', 'FFDD33'],
			['Beru', 'beru', 'Coder', 'https://twitter.com/art_keny', 'FFDD33'],
			['YOUK', 'youkdev', 'Coder', 'https://twitter.com/YOUKdev', 'FFDD33'],
			['Shiroko', 'shiroko', 'Coder', 'https://twitter.com/Shiroko_dev', 'FFDD33'],
			['GenoX', 'genox', 'Coder and Main Chromatic Scales', 'https://twitter.com/GenoXACT2', 'FFDD33'],
			['SrPerez', 'penez', 'Coder', 'https://twitter.com/NewSrPerez/', 'FFDD33'],
			['Stzr', 'stzr', 'Coder', 'https://twitter.com/stzr_real', 'FFDD33'],			
			[
				'Akai',
				'elpepe',
				'Coder Lol',
				'estovademasiadodificilhermanosientaselibresdedispararlealapantalla',
				'FFFFFF'
			],
			[
				'EsoMarx',
				'elchavoballistic',
				'Background Artist',
				'https://www.youtube.com/@esomarx3074/',
				'FFDD33'
			],
			[
				'Teeth',
				'tetasmasculinasdefurrotes avecesmepreocupascandace',
				'Background Artist',
				'https://twitter.com/teethlust',
				'FFDD33'
			],
			[
				'Koi',
				'koi',
				'Background Artist',
				'https://twitter.com/_Sir_Koi_',
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
				'Storyboard and Cover Artist',
				'https://twitter.com/AbZoule',
				'FFDD33'
			],
			[
				'Shey Pancake',
				'sheicita',
				'Cutscene Artist, Icon Artist, and Ivette VA',
				'https://twitter.com/shey_pancake',
				'FFDD33'
			],
			['Cote', 'cote', 'Cutscene Animator', 'https://cdn.discordapp.com/attachments/893308970213720065/1062570173489483786/maZmDeNx_400x400.jpg', 'FFDD33'],
			['TatoxicLG', 'tatoxic', 'Cutscene Animator', 'https://twitter.com/tatoxicLg', 'FFDD33'],
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
				'thixie',
				'thixie',
				'Maritza VA',
				'https://twitter.com/thixieedy',
				'FFDD33'
			],
			[
				'Wach',
				'wach',
				'Animation Assistant, Maavo 3D model',
				'https://twitter.com/Wachine_Machine',
				'FFDD33'
			],
			['Poncho', 'poncho', 'Logo', 'https://twitter.com/ElPonchitoPio', 'FFDD33'],
			[
				'DegoDraws',
				'dego',
				'Menu Background Artist',
				'https://twitter.com/DegoDraws',
				'FFDD33'
			],
			[
				'KoiM4',
				'koichi',
				'Light On chromatic scales',
				'https://twitter.com/koim4_',
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
				'Maavo PDMM+ Model Import help',
				'https://www.youtube.com/@AndresELLoquendero0',
				'FFDD33'
			],	
			[''],
			[Language.credits_categorys[1]],
			[
				'ShaminBECA',
				'nada',
				'Tokyo Teddy Bear album cover',
				'https://twitter.com/ShaminBECA',
				'FFDD33'
			],
			[
				'InukoExo',
				'nada',
				'kfm.mid album cover',
				'https://twitter.com/InukoExo',
				'FFDD33'
			],								
			[
				'CompotaHyper',
				'compotito',
				"For testing the mod's beta on stream",
				'https://www.youtube.com/@compotahyperlol6245/',
				'F73838'
			],
			[
				'Sulayre',
				'sul',
				'For bringing Chilean modders together\nto make the best mod ever <3 ',
				'https://twitter.com/Sulayre',
				'FFDD33'
			],
			[
				'Miki',
				'miki',
				'For voicing Ivette on past projects,\nand providing the samples for the FNF chromatic',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'FFDD33'
			],
			[
				'Riusaki Fujioka',
				'nada',
				'For voicing Maritza on past projects,\nand providing the samples for the FNF chromatic',
				'https://cdn.discordapp.com/attachments/885208632533348433/887917996977299476/miki.gif',
				'FFDD33'
			],									
			[
				'Neru',
				'nada',
				'Original Tokyo Teddy Bear composer',
				'https://twitter.com/Neru_Sleep',
				'FFDD33'
			],	
			[
				'Tanjiro Taidana',
				'nada',
				'Original Tokyo Teddy Bear UST file',
				'https://twitter.com/tanjirotaidana',
				'FFDD33'
			],
			[
				'Kishio',
				'nada',
				'Original creator of MUGEN Ronald McDonald',
				'http://web.archive.org/web/20140214203506/http://www1.bbiq.jp/gdgdgdgd/',
				'FFDD33'
			],							
			[
				'PointyyESM',
				'nada',
				'For introducing me to FNF modding',
				'https://twitter.com/PointyyESM',
				'FFDD33'
			],	
			[
				'Los Basuros',
				'nada',
				'For being the best friend group ever <3',
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
				if(creditsStuff[i][1] != 'nada'){
					var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
					icon.xAdd = optionText.width + 10;
					icon.sprTracker = optionText;
					icon.copyAlpha = creditsStuff[i][1] != 'elpepe';
					iconArray.push(icon);
					add(icon);
				}

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
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
		if (FlxG.sound.music.volume < 0.7 && !isEasterEgg)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.sound.music.volume > 0 && isEasterEgg)
			FlxG.sound.music.volume -= 0.7 * FlxG.elapsed;


		if (!quitting && !isEasterEgg)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

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

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT)
			{
				if (curSelected == 20 && iconArray[19].alpha == 1){
					changeDaWorld();
				}
				else if (curSelected != 20){
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
				}
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
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

	//0, 2, 4.5, 7.5, 10.5
	function changeDaWorld(){
		isEasterEgg = true;

		iconArray[19].loadGraphic(Paths.image('credits/' + creditsStuff[20][3]));
		FlxG.sound.play(Paths.sound('goodbye'), 0.7);
		FlxTween.color(bg, 1, bg.color, 0xFF000000, {onComplete: function(twn:FlxTween){
			FlxTween.tween(iconArray[19], {alpha: 0}, 3.5, {startDelay: 6.5});
			FlxTween.color(bg, 3, bg.color, getCurrentBGColor(), {startDelay: 9.5, onComplete: function(twn:FlxTween){
				isEasterEgg = false;
			}});
		}});

		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				if(item.targetY != 0)
				{
					FlxTween.tween(item, {alpha: 0}, 1);
					FlxTween.tween(item, {alpha: 1}, 3, {startDelay: 10.5});
				}
				else
				{
					FlxTween.tween(item, {alpha: 0}, 0.5, {onComplete: function(twn:FlxTween){
						item.bold = true;
						FlxTween.tween(item, {alpha: 1}, 0.5);
					}});
				}
			}
		}
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = Language.credits_descriptions[curSelected];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
