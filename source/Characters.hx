import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class Characters
{
	public static var charactersData:Array<Dynamic> = [
		// Character Name, Character InGame Name, DescripcionEpic, Unlocked by Default?
		["BoyFriend", 'bf', "el pipopi",true],
		["Maavo", 'maavo', "Conche tu madre es el que hizo el mod de Derker Azul",false]
	];
	public static var charactersMap:Map<String, Bool> = new Map<String, Bool>();

	public static function unlockCharacter(name:String):Void
	{
		FlxG.log.add('Unlocked Character "' + name + '"');
		charactersMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isCharacterUnlocked(name:String)
	{
		if (charactersMap.exists(name) && charactersMap.get(name))
		{
			return true;
		}
		return false;
	}

	public static function getCharacterIndex(name:String)
	{
		for (i in 0...charactersData.length)
		{
			if (charactersData[i][1] == name)
			{
				return i;
			}
		}
		return -1;
	}

	public static function loadCharacters():Void
	{
		if (FlxG.save.data != null)
		{
			if (FlxG.save.data.charactersMap != null)
			{
				//charactersMap = FlxG.save.data.charactersMap;
			}
			if (FlxG.save.data.charUnlocked != null)
			{
				FlxG.log.add("Tratando de cargar laas weas");
				var savedStuff:Array<String> = FlxG.save.data.charUnlocked;
				for (i in 0...savedStuff.length)
				{
					charactersMap.set(savedStuff[i], true);
				}
			}
		}
	}
}

class CharacterUnlocker extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	public var publicId:Int;

	public var bg:FlxSprite;
	public var charIcon:HealthIcon;
	public var charName:FlxText;

	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		var id:Int = Characters.getCharacterIndex(name);

		publicId = id;

		bg = new FlxSprite(1280, 167.5).loadGraphic(Paths.image('characterUnlocked'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		charIcon = new HealthIcon(Characters.charactersData[id][1], true);
		charIcon.alpha = 0;
		charIcon.x = 565;
		charIcon.y = 265;
		charIcon.scrollFactor.set();
		charIcon.updateHitbox();
		charIcon.antialiasing = ClientPrefs.globalAntialiasing;

		charName = new FlxText(0 , charIcon.y + 150, 0, Characters.charactersData[id][0], 48);
		charName.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		charName.alpha = 0;
		charName.scrollFactor.set();
		charName.borderSize = 1.45;
		charName.screenCenter(X);
		charName.updateHitbox();
		charName.antialiasing = ClientPrefs.globalAntialiasing;

		add(bg);
		add(charName);
		add(charIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}
		bg.cameras = cam;
		charName.cameras = cam;
		charIcon.cameras = cam;
		ultraTween();
	}

	public function ultraTween()
	{
		FlxTween.tween(bg, {x: 0}, 0.3, {onComplete: function(twn:FlxTween){
				FlxTween.tween(charIcon, {alpha: 1}, 0.2, {onComplete: function(twn:FlxTween){
					FlxTween.tween(this, {alpha: 0}, 0.5, {startDelay: 2.5,onComplete: function(twn:FlxTween){if (onFinish != null) onFinish();}});
					FlxTween.tween(charName, {alpha: 0}, 0.5, {startDelay: 2.5});
					FlxTween.tween(bg, {alpha: 0}, 0.5, {startDelay: 2.5});
				}});
				FlxTween.tween(charIcon, {y: 285}, 0.2);

				FlxTween.tween(charName, {y: charName.y + 20}, 0.2, {startDelay: 0.2});
				FlxTween.tween(charName, {alpha: 1}, 0.2, {startDelay: 0.2});
		}});
	}
}
