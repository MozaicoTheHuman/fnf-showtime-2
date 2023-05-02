package fnf.system;

import flixel.tweens.FlxTween;

class MultiTween
{
	public static function tween(twns:Array<Dynamic>, vals:Dynamic, time:Float, ?option:TweenOptions)
	{
		for (t in 0...twns.length)
		{
			if (vals.alpha == 0)
			{
				option.onComplete = function(twn:FlxTween)
				{
					twns[t].kill();
				};
			}
			FlxTween.tween(twns[t], vals, time, option);
		}
	}

	public static function alpha(twns:Array<Dynamic>, alpha:Float, time:Float, ?option:TweenOptions)
	{
		for (t in 0...twns.length)
		{
			if (alpha == 0)
			{
				option.onComplete = function(twn:FlxTween)
				{
					twns[t].kill();
				};
			}
		}
		tween(twns, {alpha: alpha}, time, option);
	}

	public static function positionX(twns:Array<Dynamic>, X:Array<Float>, time:Float, ?option:TweenOptions)
	{
		for (t in 0...twns.length)
		{
			if (X.length > 1)
			{
				FlxTween.tween(twns[t], {x: X[t]}, time, option);
			}
			FlxTween.tween(twns[t], {x: X[0]}, time, option);
		}
	}
}
