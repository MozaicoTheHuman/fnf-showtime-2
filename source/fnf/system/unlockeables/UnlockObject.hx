package fnf.system.unlockeables;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;

using StringTools;

class UnlockObject extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	public var bg:FlxSprite;
	public var songIcon:FlxSprite;
	public var songName:FlxSprite;

	public function new(name:String, ?camera:FlxCamera = null)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		bg = new FlxSprite(1280, 167.5).loadGraphic(Paths.image('songUnlocked'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;

		songIcon = new FlxSprite(20, 20).loadGraphic(Paths.image('songunlock/albums/$name'));
		songIcon.scale.set(0.9, 0.9);
		songIcon.alpha = 0;
		songIcon.antialiasing = ClientPrefs.globalAntialiasing;

		songName = new FlxSprite(-20, 200).loadGraphic(Paths.image('songunlock/names/${name}-${Language.getLAN()}'));
		songName.alpha = 0;
		songName.antialiasing = ClientPrefs.globalAntialiasing;

		add(bg);
		add(songName);
		add(songIcon);

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if (camera != null)
		{
			cam = [camera];
		}
		bg.cameras = cam;
		songName.cameras = cam;
		songIcon.cameras = cam;
		ultraTween();
	}

	public function ultraTween()
	{
		FlxTween.tween(bg, {x: 0}, 0.3, {
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(songIcon, {alpha: 1, y: 70}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(this, {alpha: 0}, 0.5, {
							startDelay: 2.5,
							onComplete: function(twn:FlxTween)
							{
								if (onFinish != null)
									onFinish();
							}
						});
					}
				});
				FlxTween.tween(songName, {y: 280, alpha: 1}, 0.2, {startDelay: 0.2});
			}
		});
	}
}
