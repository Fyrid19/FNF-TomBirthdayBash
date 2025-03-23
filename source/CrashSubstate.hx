package;

import flixel.FlxSprite;
import flixel.text.FlxText;

class CrashSubstate extends MusicBeatSubstate {
    var bg:FlxSprite;
    var crashText:FlxText;

    public function new(crashLog:String) {
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        
        var youCrashText:FlxText = new FlxText(0, 0, FlxG.width, 'Game Crashed!', 56);
		youCrashText.setFormat(Paths.font("tomgles.ttf"), 56, FlxColor.WHITE, RIGHT);
        add(youCrashText);

        crashText = new FlxText(0, 0, FlxG.width, '', 24);
		crashText.setFormat(Paths.font("tomgles.ttf"), 24, FlxColor.WHITE, RIGHT);
        crashText.y += youCrashText.height + 50;

        super();
    }

    public function update(elapsed:Float) {
        if (controls.ACCEPT) {
            FlxG.resetGame();
            closeSubState();
        }

        super.elapsed(elapsed);
    }
}