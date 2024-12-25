package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class NoteForTom extends MusicBeatSubstate {
    var bg:FlxSprite;
    var theNote:FlxSprite;
    var confirmTxt:FlxText;
    
    var canProceed:Bool = false;

    public function new() {
        super();

        trace('we up');

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.alpha = 0;
        add(bg);

        theNote = new FlxSprite().loadGraphic(Paths.image('note_for_tom'));
        theNote.scrollFactor.set();
        theNote.setGraphicSize(theNote.width * 0.7);
        theNote.updateHitbox();
        theNote.y = -theNote.height;
        theNote.x = FlxG.width/2 - theNote.width/2;
        add(theNote);

        confirmTxt = new FlxText(20, 0, 0, 'Press ACCEPT to proceed', 56);
        confirmTxt.scrollFactor.set();
		confirmTxt.setFormat(Paths.font("tomgles.ttf"), 56);
        confirmTxt.updateHitbox();
        confirmTxt.y = FlxG.height - confirmTxt.height - 10;
        add(confirmTxt);

        theNote.alpha = 0;
        confirmTxt.alpha = 0;

        var randomAngle:Float = FlxG.random.float(-10, 10);
        FlxTween.tween(bg, {alpha: 0.4}, 1, {ease: FlxEase.sineInOut});
        FlxTween.tween(theNote, {alpha: 1, y: FlxG.height/2 - theNote.height/2, angle: randomAngle}, 1, {ease: FlxEase.quadOut});
        FlxTween.tween(confirmTxt, {alpha: 1}, 1, {ease: FlxEase.sineOut, startDelay: 3});

        new FlxTimer().start(3, function(tmr:FlxTimer) {
            canProceed = true;
            trace('you can proceed');
        });

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) {
        if (controls.ACCEPT && canProceed) {
            closeSubState();
        }

        super.update(elapsed);
    }

    override function closeSubState() {
        FlxTween.tween(bg, {alpha: 0}, 1, {ease: FlxEase.sineIn});
        FlxTween.tween(theNote, {alpha: 0, y: theNote.y + 20}, 1, {ease: FlxEase.sineIn});
        FlxTween.tween(confirmTxt, {alpha: 0}, 1, {ease: FlxEase.sineIn});

        new FlxTimer().start(1, function(tmr:FlxTimer) {
            TomStoryState.readingNote = false;
            close();
        });
    }
}