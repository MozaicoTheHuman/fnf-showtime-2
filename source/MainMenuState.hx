package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode','freeplay','options','awards','credits'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var bg:FlxSprite;
	var overlay1:FlxSprite;
	var overlay2:FlxSprite;
	var charshadow:FlxSprite;
	var char:FlxSprite;
	var menu:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/bg'));
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		bg.scale.x = 0.7;
		bg.scale.y = 0.7;
		bg.alpha = 0;
		add(bg);

		overlay1 = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/overlay1'));
		overlay1.screenCenter();
		overlay1.scrollFactor.set(0, 0);
		overlay1.scale.x = 0.7;
		overlay1.scale.y = 0.7;
		overlay1.antialiasing = ClientPrefs.globalAntialiasing;
		overlay1.x = -3000;
		add(overlay1);

		overlay2 = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/overlay2'));
		overlay2.screenCenter();
		overlay2.scrollFactor.set(0, 0);
		overlay2.scale.x = 0.7;
		overlay2.scale.y = 0.7;
		overlay2.antialiasing = ClientPrefs.globalAntialiasing;
		overlay2.x = -3000;
		add(overlay2);

		charshadow = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/charshadow'));
		charshadow.screenCenter();
		charshadow.scrollFactor.set(0, 0);
		charshadow.x += 75;
		charshadow.y += 35;
		charshadow.scale.x = 0.6;
		charshadow.scale.y = 0.6;
		charshadow.antialiasing = ClientPrefs.globalAntialiasing;
		charshadow.x = 1000;
		add(charshadow);

		char = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/char'));
		char.screenCenter();
		char.scrollFactor.set(0, 0);
		char.x += 75;
		char.y += 35;
		char.scale.x = 0.6;
		char.scale.y = 0.6;
		char.antialiasing = ClientPrefs.globalAntialiasing;
		char.x = 1000;
		add(char);

		menu = new FlxSprite(0, 0).loadGraphic(Paths.image('horadeldou-ui/1/menu'));
		menu.screenCenter();
		menu.scrollFactor.set(0, 0);
		menu.scale.x = 0.7;
		menu.scale.y = 0.7;
		menu.antialiasing = ClientPrefs.globalAntialiasing;
		menu.x = -1000;
		menu.y = 1000;
		add(menu);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{

			var offset:Float = 50 - (Math.max(optionShit.length, 4) - 4) * 80;
			var offset2:Float = 140 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite( 250 + (i * - 50)  - offset, 300 + (i * 80)  + offset);
			menuItem.scale.set(0.5,0.5);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');

			//hardcoding the offsets shit, there is no problem
			switch(i){
				case 0:
					menuItem.x -= 35;
				case 1:
					menuItem.x += 5;
				case 2:
					menuItem.x += 10;
				case 3:
					menuItem.x += 35;
				case 4:
					menuItem.x += 35;
			}
			
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.alpha = 0;

			FlxTween.tween(menuItem, {alpha: 1}, 2 , {
				ease: FlxEase.quadOut,
			});
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end
		oncreateAnims();
		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('pageMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('pageMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

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
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(0,0);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;

				//hardcoding again waaaaaa D':
				switch(spr.ID){
					case 0:
						spr.offset.x += 100;
						spr.offset.y += 25;
					case 1:
						spr.offset.x += 75;
						spr.offset.y += 20;
					case 2:
						spr.offset.x += 60;
						spr.offset.y += 20;
					case 3:
						spr.offset.x += 60;
						spr.offset.y += 20;
					case 4:
						spr.offset.x += 60;
						spr.offset.y += 20;
				}


				FlxG.log.add(spr.frameWidth);
			}
		});
	}
	function beatHit()
	function oncreateAnims(){

		FlxTween.tween(bg, {alpha: 1}, 5, {
			ease: FlxEase.quadOut,
		});

		FlxTween.tween(overlay1, {x: -320}, 1, {
			ease: FlxEase.quadOut,
		});
		FlxTween.tween(overlay2, {x: -320}, 1, {
			ease: FlxEase.quadOut,
		});
		FlxTween.tween(char, {x: -245}, 1, {
			ease: FlxEase.quadOut,
		});
		FlxTween.tween(charshadow, {x: -245}, 1, {
			ease: FlxEase.quadOut,
		});
		FlxTween.tween(menu, {x: -320, y: -180}, 0.5 , {
			ease: FlxEase.quadOut,
		});
		

		

	}

}
