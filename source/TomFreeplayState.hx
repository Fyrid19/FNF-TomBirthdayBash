package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.display.FlxBackdrop;

class TomFreeplayState extends MusicBeatState
{
	var bg:FlxSprite;

	var curSel:Int;
	var curSelAlt:Int; // 4 up n down
	var usingMouse:Bool = false;

	// hi ethan
	public static var curCat:String;

	var catGrp:FlxTypedGroup<CatItem>;
	var cats:Array<Array<String>> = [['tom', 'tom2', 'tom-takeover'], ['extra']];

	var selecting:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		selecting = false;

		FlxG.mouse.visible = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordRPC.changePresence({details: "Freeplay Select Menu"});
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.setGraphicSize(bg.width * 1.1);
		bg.screenCenter();
		bg.color = 0x00FF00;
		add(bg);

		var gridBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('griddy'));
		gridBackdrop.velocity.set(100, 70);
		gridBackdrop.updateHitbox();
		gridBackdrop.alpha = 0.3;
		add(gridBackdrop);

		var barOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bararar'));
		barOverlay.screenCenter();
		add(barOverlay);

		var selectTxt:FlxText = new FlxText(0, 5, FlxG.width, 'Select a category!', 42);
		selectTxt.setFormat(Paths.font("tomgles.ttf"), 42, FlxColor.WHITE, CENTER);
		add(selectTxt);

		catGrp = new FlxTypedGroup<CatItem>();
		add(catGrp);

		var extraCat:CatItem = new CatItem();
		extraCat.loadGraphic(Paths.image('freeplay/extra'));
		extraCat.screenCenter(X);
		extraCat.y = FlxG.height - extraCat.height - 75;
		extraCat.itemID = 0;
		extraCat.itemID2 = 1;

		for (i in 0...cats[0].length)
		{
			var cat:CatItem = new CatItem();
			cat.loadGraphic(Paths.image('freeplay/' + cats[0][i]));
			cat.screenCenter(X);
			cat.y = extraCat.y - cat.height - 10;
			cat.itemID = i;
			cat.itemID2 = 0;

			if (i == 0)
				cat.x -= cat.width + 10;
			else if (i == 2)
				cat.x += cat.width + 10;

			catGrp.add(cat);
		}

		catGrp.add(extraCat);

		super.create();
	}

	var canSelect:Bool = true;

	var realSel:Int;

	override function update(elapsed:Float)
	{
		if (!selecting)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				selectCat();
			}

			if (controls.UI_LEFT_P)
				changeSelection(-1);
			if (controls.UI_RIGHT_P)
				changeSelection(1);

			if (controls.UI_UP_P)
				changeSelectionAlt(-1);
			if (controls.UI_DOWN_P)
				changeSelectionAlt(1);
		}

		if (curSel > cats[curSelAlt].length - 1)
			realSel = 0;
		else
			realSel = curSel;

		for (item in catGrp.members)
		{
			if (checkSelect(item))
			{
				item.color = 0xFFFFFF;
			}
			else
			{
				item.color = 0x888888;
			}
		}
		
		curCat = cats[curSelAlt][realSel];

		super.update(elapsed);
	}

	public function changeSelection(index:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'));
        
		curSel += index;
	
		if (curSel < 0)
			curSel = cats[curSelAlt].length - 1;
		if (curSel >= cats[curSelAlt].length)
			curSel = 0;
	}

	public function changeSelectionAlt(index:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelAlt += index;
	
		if (curSelAlt < 0)
			curSelAlt = cats.length - 1;
		if (curSelAlt >= cats.length)
			curSelAlt = 0;
	}

	function selectCat()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		selecting = true;

		trace(curCat);

		for (item in catGrp.members)
		{
			if (checkSelect(item))
			{
				FlxTween.tween(item, {x: FlxG.width / 2 - item.width / 2, y: FlxG.height / 2 - item.height / 2}, 0.5, {ease: FlxEase.backOut});
				if (ClientPrefs.flashing)
					FlxTween.flicker(item, 1);
			}
			else
			{
				FlxTween.tween(item, {y: item.y + FlxG.height}, 0.5, {ease: FlxEase.backOut});
			}
		}

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.switchState(() -> new FreeplayState(curCat));
		});
	}

	function checkSelect(item:CatItem):Bool
		return item.itemID == realSel && item.itemID2 == curSelAlt;
}

class CatItem extends FlxSprite
{
	public var itemID:Int;
	public var itemID2:Int;

	public function new()
	{
		super();
	}
}
