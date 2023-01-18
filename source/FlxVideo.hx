#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
import vlc.VLCBitmap;
#end

import flixel.FlxBasic;
import flixel.FlxG;
import lime.app.Application;

class FlxVideo extends FlxBasic {
	#if VIDEOS_ALLOWED
	public var isPlaying:Bool = false;
	public var canSkip:Bool = true;
	public var canUseSound:Bool = true;
	public var canUseAutoResize:Bool = true;
	public var readyCallback:Void->Void = null;	
	public var finishCallback:Void->Void = null;
	public var videoPathName:String;
	public static var realPause:Bool = false;
    public var muted:Bool = false;

	#if desktop
	public static var vlcBitmap:VLCBitmap;
	#end

	var repeats = 0;

	public function new(name:String, ?isChild:Bool = false, ?repito:Int = 0, ?mute:Bool = false) {
		super();

        if (mute == true){
            muted = true;
        }
		#if web
		var player:Video = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		var netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function() {
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
			if(event.info.code == "NetStream.Play.Complete") {
				netStream.dispose();
				if(FlxG.game.contains(player)) FlxG.game.removeChild(player);

				if(finishCallback != null) finishCallback();
			}
		});
		netStream.play(name);
		
		#elseif desktop
		// by Polybius, check out PolyEngine! https://github.com/polybiusproxy/PolyEngine

		vlcBitmap = new VLCBitmap();
		vlcBitmap.height = FlxG.stage.stageHeight;
		vlcBitmap.width = FlxG.stage.stageHeight * (16 / 9);

		vlcBitmap.onEndReached = onVLCComplete;
		

		FlxG.stage.addEventListener(Event.ENTER_FRAME, fixVolume);
	
       	fixVolume(null); 
       
		

		videoPathName = name;

		var child = FlxG.addChildBelowMouse(vlcBitmap);
		if (isChild) child.visible = false;
		vlcBitmap.play(checkFile(name));

		repeats = repito;

		/*
		finishCallback = function() {
            if (repeats > 0) {
                vlcBitmap.play(checkFile(videoPathName));
                repeats -= 1;
            } else if (repeats < 0) {
                trace('cock');
                vlcBitmap.play(checkFile(videoPathName));
            } else return;
        }
		*/
		#end
	}

	#if desktop
	public function checkFile(fileName:String):String
	{
		var pDir = "";
		var normPath = haxe.io.Path.normalize(Sys.getCwd());
		var appDir = "file:///" + normPath + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}
	
	public static function onFocus() {
		if(vlcBitmap != null && !realPause) {
			vlcBitmap.resume();
		}
	}
	
	public static function onFocusLost() {
		if(vlcBitmap != null && !realPause) {
			vlcBitmap.pause();
		}
	}

	public function pauseVideo()
	{
		if(vlcBitmap != null) {
			vlcBitmap.pause();
			realPause = true;
		}
	}
	public function resumeVideo()
	{
		if(vlcBitmap != null) {
			vlcBitmap.resume();
			realPause = false;
		}
	}


	function fixVolume(e:Event)
	{
		// shitty volume fix
		vlcBitmap.volume = 0;
        if (muted == false){
            if(!FlxG.sound.muted && FlxG.sound.volume > 0.01) { //Kind of fixes the volume being too low when you decrease it
                vlcBitmap.volume = Std.int(FlxG.sound.volume * 100);
            }
        }
        
	}

	public function onVLCComplete()
	{
		vlcBitmap.stop();

		// Clean player, just in case!
		vlcBitmap.dispose();

		if (FlxG.game.contains(vlcBitmap))
		{
	
			FlxG.game.removeChild(vlcBitmap);
		}

		if (finishCallback != null)
		{
			finishCallback();
		}
	}

	
	function onVLCError()
		{
			trace("oe q wea no me carga el video xd");
			if (finishCallback != null) {
				finishCallback();
			}
		}
	#end
	#end
}
