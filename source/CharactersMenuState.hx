package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;

using StringTools;

class CharactersMenuState extends MusicBeatState
{
	var alreadySelected:Bool = false;

  var charsShit:Array<String> = ["bf"];
	private var menuItems:FlxTypedGroup<FlxSprite>;
	private static var curSelected:Int = 0;
	private var charactersIndex:Array<Int> = [];
	private static var selectedChar:String;

	var bg:FlxBackdrop = new FlxBackdrop(Paths.image('menuDesat'), 0.2, 0.2, true, true);
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Characters Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

    bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scrollFactor.set(0.4, 0);
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

    Characters.loadCharacters();
		for (i in 0...Characters.charactersData.length) {
			if(Characters.charactersMap.exists(Characters.charactersData[i][1])) {
				charsShit.push(Characters.charactersData[i][1]);
				charactersIndex.push(i);
			}
		}

		for (i in 0...charsShit.length)
			{
				var offset:Float = 108 - (Math.max(charsShit.length, 4) - 4) * 80;
				var character:FlxSprite = new FlxSprite((i * 1280)  + offset, 0);
				character.frames = Paths.getSparrowAtlas('charactersmenu/' + charsShit[i]);
				character.animation.addByPrefix('idle', "idle", 24);
				character.animation.play('idle');
				character.ID = i;
				character.screenCenter(Y);
				character.scrollFactor.set(1, 0);
				character.antialiasing = ClientPrefs.globalAntialiasing;
				character.updateHitbox();
				menuItems.add(character);
			}

		FlxG.camera.follow(camFollow, null, 0.68);

		leftArrow = new FlxSprite(320, 0);
    leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.screenCenter(Y);
		leftArrow.animation.play('idle');
		leftArrow.scrollFactor.set(0,0);
		add(leftArrow);

		rightArrow = new FlxSprite(960, 0);
    rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.screenCenter(Y);
		rightArrow.animation.play('idle');
		rightArrow.scrollFactor.set(0,0);
		add(rightArrow);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (!alreadySelected)
		{
			if (controls.UI_LEFT_P)
				{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
				}
			if (controls.UI_RIGHT_P)
				{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
				}

			if (controls.ACCEPT)
				{
					alreadySelected = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					selectedChar = charsShit[curSelected];

					menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker){
									MusicBeatState.switchState(new FreeplayState());
								});
							}
						});
				}

				if (controls.BACK)
				{
					MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
		}

		if (controls.UI_RIGHT)
			rightArrow.animation.play('press')
		else
			rightArrow.animation.play('idle');

		if (controls.UI_LEFT)
			leftArrow.animation.play('press');
		else
			leftArrow.animation.play('idle');

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(Y);
		});
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;

    if (curSelected < 0)
      curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		menuItems.forEach(function(character:FlxSprite)
			{
				character.animation.play('idle');
				character.updateHitbox();

				if (character.ID == curSelected)
				{
					camFollow.setPosition(character.getGraphicMidpoint().x, character.getGraphicMidpoint().y);
					character.centerOffsets();
				}
		});
	}
}
