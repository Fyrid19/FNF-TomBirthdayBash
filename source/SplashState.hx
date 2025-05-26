package;

import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;

#if sys
import sys.FileSystem;
#end

#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
#end

// plays joeseph splash screen then goes to menu (unless videos arent allowed)
// also acts as an initial state thing or whatever
class SplashState extends MusicBeatState {
	var canSkip:Bool = false;
	var splashVideo:FlxVideoSprite;
    var splashVideoName:String = 'BIRTHDAY-BASH-WEEKLY';
    var skipText:FlxText;

    override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		init();

        splashVideo = new FlxVideoSprite(0, 0);
		splashVideo.antialiasing = ClientPrefs.globalAntialiasing;
		splashVideo.bitmap.onFormatSetup.add(function():Void 
		{
			if (splashVideo.bitmap != null && splashVideo.bitmap.bitmapData != null) 
			{
				var width:Float = splashVideo.bitmap.bitmapData.width;
				var height:Float = splashVideo.bitmap.bitmapData.height;
				final scale:Float = Math.min(FlxG.width / width, FlxG.height / height);
	
				splashVideo.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
				splashVideo.updateHitbox();
				splashVideo.screenCenter();
			}
		});
		splashVideo.bitmap.onEndReached.add(splashVideo.destroy);
		add(splashVideo);

        skipText = new FlxText(10, 0, FlxG.width, "Press ENTER to skip", 32);
		skipText.setFormat(Paths.font("tomgles.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.y = FlxG.height - skipText.height - 10;
		skipText.alpha = 0;
		add(skipText);

		new FlxTimer().start(1, function(t) {
			FlxTween.tween(skipText, {alpha: 1}, 1);
			canSkip = true;
		});

		// #if VIDEOS_ALLOWED
		// if (!ClientPrefs.skipIntro) {
		// 	playSplashVideo(splashVideoName);
		// } else {
		// 	FlxG.switchState(() -> new TitleState());
		// }
		// #else
		FlxG.switchState(() -> new TitleState()); // cuz no videos allowed!!
		// #end

        super.create();
    }

	override function update(elapsed:Float) {
		if (controls.ACCEPT && canSkip) skipSplashVideo();
		super.update(elapsed);
	}

	function init() {
		PlayerSettings.init();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();
	}

    function playSplashVideo(videoname) {
        var filepath:String = Paths.video(videoname);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + videoname + '.mp4');
            trace('Couldnt find video file: ' + videoname + '.mp4');
			FlxG.switchState(() -> new TitleState());
			return;
		}

		if (splashVideo.load(filepath)) 
			splashVideo.play();
    }

	function skipSplashVideo() {
		splashVideo.destroy();
		trace('Video Skipped!');
		FlxG.switchState(() -> new TitleState());
	}
}