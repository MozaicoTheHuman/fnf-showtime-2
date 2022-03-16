package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas("show/MaritzaWait",'shared');
		animation.addByIndices('danceLeft', 'MaritzaWait', [2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
		animation.addByIndices('danceRight', 'MaritzaWait', [12, 13, 14, 15, 16, 16, 17, 18, 0, 1], "", 24, false);
		animation.play('danceLeft');
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
