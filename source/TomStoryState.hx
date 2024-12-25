package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.plugin.FlxScrollingText;
import Discord.DiscordClient;
import WeekData;

class TomStoryState extends MusicBeatState {
    var background:FlxSprite;
    var blackOverlay:FlxSprite;
    var tomBody:FlxSprite;
    var tomEyes:FlxSprite;
    var selector:FlxSprite;
    var rightArrow:FlxSprite;
    var leftArrow:FlxSprite;

    var textBackdrop:FlxBackdrop;
    var textBackdrop2:FlxBackdrop;

    var weekGrp:FlxTypedGroup<WeekItem>;
    var weekPaths:Array<String> = [
        'tom',
        'tom2',
        'tom-takeover'
    ];

    var weekNames:Array<String> = [
        'Tom',
        'Tom 2',
        'Tom Takeover'
    ];

    var weekColors:Array<String> = [
        '0x03CE2F',
        '0x911EEE',
        '0x2455DB'
    ];

    var curSelected:Int;
    var usingMouse:Bool = false;

    var weekTracksText:FlxText;

    var selectingWeek:Bool = false;

    public static var readingNote:Bool = false;

    public static var curWeekName:String = '';

    override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
        
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

        selectingWeek = false;
        
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Story Menu", null);
		#end

        background = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		background.color = FlxColor.fromString(weekColors[curSelected]);
        background.setGraphicSize(Std.int(background.width * 1.1));
        background.screenCenter();
        add(background);

        var gridBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('griddy'));
		gridBackdrop.velocity.set(70, 50);
		gridBackdrop.updateHitbox();
		gridBackdrop.alpha = 0.3;
		add(gridBackdrop);

        var real:FlxText = new FlxText(0, 0, 0, 'GULPERS!', 48);
		real.setFormat(Paths.font("tomgles.ttf"), 48, FlxColor.WHITE, CENTER);

        textBackdrop = new FlxBackdrop(null, XY, 5, real.height);
		textBackdrop.velocity.set(100, 0);
        add(textBackdrop);

        textBackdrop2 = new FlxBackdrop(null, XY, 5, real.height);
		textBackdrop2.velocity.set(-100, 0);
        textBackdrop2.y += real.height;
        add(textBackdrop2);
        
        blackOverlay = new FlxSprite().loadGraphic(Paths.image('gorp'));
        blackOverlay.screenCenter();
        add(blackOverlay);

        tomBody = new FlxSprite().loadGraphic(Paths.image('tomson'));
        tomBody.screenCenter(X);
        tomBody.y = FlxG.height - tomBody.height;
        add(tomBody);

        tomEyes = new FlxSprite().loadGraphic(Paths.image('tomson-lookers'));
        tomEyes.screenCenter(X);
        tomEyes.y = FlxG.height - tomBody.height;
        add(tomEyes);

		weekTracksText = new FlxText(0, 10, FlxG.width, "gulp", 28);
		weekTracksText.setFormat(Paths.font("tomgles.ttf"), 28, FlxColor.WHITE, CENTER);
        add(weekTracksText);

        selector = new FlxSprite().loadGraphic(Paths.image('week-selec'));
        selector.screenCenter();
        add(selector);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		rightArrow = new FlxSprite(0, 0);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
        rightArrow.y = FlxG.height - rightArrow.height - 10;
        rightArrow.x = FlxG.width - rightArrow.width - 10;
		add(rightArrow);

        leftArrow = new FlxSprite(0, 0);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', 'arrow left');
		leftArrow.animation.addByPrefix('press', "arrow push left", 24, false);
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
        leftArrow.y = FlxG.height - leftArrow.height - 10;
        leftArrow.x = 10;
		add(leftArrow);

        weekGrp = new FlxTypedGroup<WeekItem>();
        add(weekGrp);
        
        FlxG.mouse.visible = true;

        for (i in 0...weekPaths.length) {
            var weekItem:WeekItem = new WeekItem();
            weekItem.loadGraphic(Paths.image('storymenu/' + weekPaths[i]));
            weekItem.x = FlxG.width * (0.25 * (i+1)) - weekItem.width/2;

            if (i == 1)
                weekItem.y = weekTracksText.y + weekItem.height - 40;
            else
                weekItem.y = weekTracksText.y + weekItem.height + 80;

            if (i == 0)
                weekItem.x -= 10;
            else if (i == 2)
                weekItem.x += 10;

            weekItem.ID = i;
            weekGrp.add(weekItem);
        }
        
        changeSelection();

        selector.x = weekGrp.members[curSelected].x - 80;
        selector.y = weekGrp.members[curSelected].y - 90;

        super.create();

        if (FlxG.save.data.playedBestFriend) {
            openSubState(new NoteForTom());
            readingNote = true;
        }
    }

    override function update(elapsed:Float) {
        if (!selectingWeek && !readingNote) {
            if (controls.BACK) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxG.switchState(() -> new MainMenuState());
                FlxG.mouse.visible = false;
            }

            if (controls.ACCEPT) {
                selectWeek();
            }

            if (controls.UI_LEFT_P)
                changeSelection(-1);
            if (controls.UI_RIGHT_P)
                changeSelection(1);

            if (controls.UI_RIGHT)
                rightArrow.animation.play('press')
            else
                rightArrow.animation.play('idle');

            if (controls.UI_LEFT)
                leftArrow.animation.play('press');
            else
                leftArrow.animation.play('idle');

            if (FlxG.keys.justPressed.ANY)
                usingMouse = false;
            if (FlxG.mouse.justPressed)
                usingMouse = true;
        }

        var curWeek = weekGrp.members[curSelected];

        var bgOffset:Float = 0;
        
        if (usingMouse)
            bgOffset = -FlxG.width/2 + FlxG.mouse.x;
        else
            bgOffset = -FlxG.width/2 + curWeek.x + curWeek.width / 2;

        // tomEyes.x = ((FlxG.width / 2) - tomBody.width / 2) + (bgOffset / 6);
        // background.x = ((FlxG.width / 2) - tomBody.width / 2) + (bgOffset / 10);

        var lerpThing:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
        var lerpThing2:Float = CoolUtil.boundTo(elapsed * 36, 0, 1);
        background.x = FlxMath.lerp(background.x, ((FlxG.width / 2) - background.width / 2) + (bgOffset / 25), lerpThing);
        tomEyes.x = FlxMath.lerp(tomEyes.x, ((FlxG.width / 2) - tomBody.width / 2) + (bgOffset / 6), lerpThing);
        selector.x = FlxMath.lerp(selector.x, curWeek.x - 80, lerpThing2);
        selector.y = FlxMath.lerp(selector.y, curWeek.y - 90, lerpThing2);

        if (!selectingWeek && !readingNote) {
            for (item in weekGrp.members) {
                if (FlxG.mouse.overlaps(item) && !item.isSelected) {
                    changeSelection(item.ID, true);
                    item.isSelected = true;
                    if (!usingMouse) usingMouse = true;
                }

                if (!FlxG.mouse.overlaps(item)) {
                    item.isSelected = false;
                }
            }

            if (FlxG.mouse.overlaps(weekGrp) && FlxG.mouse.justPressed) {
                selectWeek();
            }
        }

        super.update(elapsed);
    }

    function changeSelection(index:Int = 0, ?set:Bool = false) {
        if (!set)
            curSelected += index;
        else
            curSelected = index;

		if (curSelected < 0)
			curSelected = weekGrp.length - 1;
		if (curSelected >= weekGrp.length)
			curSelected = 0;
        
        var weekToPlay:WeekData = WeekData.weeksLoaded.get(weekPaths[curSelected]);
		var stringThing:Array<String> = [];
		for (i in 0...weekToPlay.songs.length) {
			stringThing.push(weekToPlay.songs[i][0]);
		}

        curWeekName = weekToPlay.weekName;

		weekTracksText.text = '';
		for (i in 0...stringThing.length)
		{
			if (i == (stringThing.length - 1))
				weekTracksText.text += stringThing[i];
			else
				weekTracksText.text += stringThing[i] + ' - ';
		}

        var scrollText:FlxText = new FlxText(0, 0, 0, weekNames[curSelected].toUpperCase(), 48);
		scrollText.setFormat(Paths.font("tomgles.ttf"), 48, FlxColor.WHITE, CENTER);

        textBackdrop.loadGraphic(scrollText.framePixels);
        textBackdrop2.loadGraphic(scrollText.framePixels);

		var weekColor:String = weekColors[curSelected];
        FlxTween.cancelTweensOf(background);
		FlxTween.color(background, 0.25, background.color, FlxColor.fromString(weekColor));
        
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }

    function selectWeek() {
        FlxG.sound.play(Paths.sound('confirmMenu'));

        selectingWeek = true;

        var songArray:Array<String> = [];
        var weekToPlay:WeekData = WeekData.weeksLoaded.get(weekPaths[curSelected]);
        for (i in 0...weekToPlay.songs.length) {
            songArray.push(weekToPlay.songs[i][0]);
        }

        var randomString:String = '';
        if (FlxG.random.bool(5))
            randomString = 'Lets-a go!';
        else
            randomString = 'Lets go!';

        weekTracksText.text = randomString;
        var scrollText:FlxText = new FlxText(0, 0, 0, randomString.toUpperCase(), 48);
		scrollText.setFormat(Paths.font("tomgles.ttf"), 48, FlxColor.WHITE, CENTER);

        textBackdrop.loadGraphic(scrollText.framePixels);
        textBackdrop2.loadGraphic(scrollText.framePixels);

        if (ClientPrefs.flashing) {
            FlxG.camera.flash(0xFFFFFF);
            FlxTween.flicker(weekGrp.members[curSelected], 3);
        }

        for (item in weekGrp.members) {
            if (item.ID != curSelected) {
                FlxTween.tween(item, { y: item.y + FlxG.height }, 1, { ease: FlxEase.backInOut });
            }
        }

        FlxG.sound.music.fadeOut(2);

        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            FlxG.camera.fade(FlxColor.BLACK);
        });
        
        PlayState.storyPlaylist = songArray;
        PlayState.isStoryMode = true;
        PlayState.storyDifficulty = 1;
        
        PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
        PlayState.campaignScore = 0;
        PlayState.campaignMisses = 0;
        new FlxTimer().start(3, function(tmr:FlxTimer)
        {
            LoadingState.loadAndSwitchState(() -> new PlayState(), true);
            FreeplayState.destroyFreeplayVocals();
            FlxG.mouse.visible = false;
        });
    }
}

class WeekItem extends FlxSprite {
    public var isSelected:Bool;

    public function new() {
        super();
    }
}