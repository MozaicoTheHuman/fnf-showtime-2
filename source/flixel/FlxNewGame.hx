package flixel;

import flixel.FlxGame;
import openfl.MemoryManagement;

class FlxNewGame extends FlxGame
{
	var skipNextTickUpdate:Bool = false;

	public override function switchState()
	{
		super.switchState();
		// draw once to put all images in gpu then put the last update time to now to prevent lag spikes or whatever
		draw();
		_total = ticks = getTicks();
		skipNextTickUpdate = true;
	}

	public override function onEnterFrame(t)
	{
		if (skipNextTickUpdate != (skipNextTickUpdate = false))
			_total = ticks = getTicks();
		super.onEnterFrame(t);
	}

	public override function draw()
	{
		MemoryManagement.askDisable();
		super.draw();
		MemoryManagement.askEnable();
	}

	public override function update()
	{
		MemoryManagement.askDisable();
		super.update();
		MemoryManagement.askEnable();
	}
}
