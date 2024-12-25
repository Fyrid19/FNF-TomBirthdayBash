package;

import Controls.Control;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import openfl.utils.Assets;

class PauseSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var bgGrid:FlxBackdrop;
	var levelInfo:FlxText;
	var blueballedTxt:FlxText;
	var songInfo:FlxText;
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var pauseTom:FlxSprite;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart', 'Modifiers', 'Options', 'Exit'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	public static var wasinsongbeforethenwenttooptions:Bool;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		//if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music('tea-time'), true, true);
		//}  else if (songName != 'None') {
		/*	pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		} */
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		bgGrid = new FlxBackdrop(Paths.image('griddy'));
		bgGrid.setGraphicSize(Std.int(bgGrid.width * 1.6));
		bgGrid.velocity.set(30, 30);
		bgGrid.updateHitbox();
		bgGrid.alpha = 0;
		add(bgGrid);

		pauseTom = new FlxSprite().loadGraphic(Paths.image('pause/beuty'));

		var weekName:String = FreeplayState.weekToLoad != null ? FreeplayState.weekToLoad.weekName : TomStoryState.curWeekName;
		var pauseArtPath:String = 'pause/' + Paths.formatToSongPath(PlayState.SONG.song);
		if (Paths.image(pauseArtPath) != null) {
			pauseTom.loadGraphic(Paths.image(pauseArtPath));
		} else if (Paths.image('pause/' + weekName) != null) {
			pauseTom.loadGraphic(Paths.image('pause/' + weekName));
		}

		pauseTom.setGraphicSize(FlxG.height * 0.9);
		pauseTom.x = FlxG.width + pauseTom.width;
		pauseTom.screenCenter(Y);
		pauseTom.y += 70;
		// add(pauseTom); // no more pause art because ethan is LAZY.

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("tomgles.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		blueballedTxt = new FlxText(20, 15 + 32, 0, "", 32);
		blueballedTxt.text = "Deaths: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('tomgles.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		songInfo = new FlxText(20, 15 + 96, FlxG.width * 0.6, "", 32);
		songInfo.scrollFactor.set();
		songInfo.setFormat(Paths.font('tomgles.ttf'), 32);
		songInfo.updateHitbox();
		add(songInfo);

		var curSong:String = Paths.formatToSongPath(PlayState.SONG.song);
		var songDesc:String = "gulping gulps, gulp, am i gulp?";
		#if MODS_ALLOWED
		if (sys.FileSystem.exists(Paths.mods('data/$curSong/songInfo.txt')))
			songDesc = sys.io.File.getContent(Paths.mods('data/$curSong/songInfo.txt'));
		else #end if (sys.FileSystem.exists(Paths.txt('$curSong/songInfo')))
			songDesc = sys.io.File.getContent(Paths.txt('$curSong/songInfo'));
		songInfo.text = songDesc;

		practiceText = new FlxText(levelInfo.x + levelInfo.width + 20, 15, 0, "(PRACTICE MODE)", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('tomgles.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		// nvm we dont need this, gonna leave it here anyway LOL!
		var chartingTextX:Float = practiceText.visible ? practiceText.x + practiceText.width + 20 : levelInfo.x + levelInfo.width + 20;
		var chartingText:FlxText = new FlxText(20, 15, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('tomgles.ttf'), 32);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelInfo.alpha = 0;
		songInfo.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bgGrid, {alpha: 0.1}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(songInfo, {alpha: 1, y: songInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(pauseTom, {x: FlxG.width - pauseTom.width + 70}, 1, {ease: FlxEase.backOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (!subStateClosing) {
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode) && !subStateClosing)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					closeSubState();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						closeSubState();
					}
				case "End Song":
					closeSubState();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Options':
					wasinsongbeforethenwenttooptions = true;
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					FlxG.switchState(() -> new options.OptionsState());
					FlxG.sound.playMusic(Paths.music('optionsMenu'));
				case 'Modifiers':
					close();
					PlayState.instance.openChangersMenu();
				case "Exit":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						FlxG.switchState(() -> new TomStoryState());
					} else {
						FlxG.switchState(() -> new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			FlxG.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	var subStateClosing:Bool = false;
	override function closeSubState() {
		if (!subStateClosing) {
			for (item in grpMenuShit.members) {
				if (item.targetY != curSelected)
					FlxTween.tween(item, {y: item.y + FlxG.height}, 1, {ease: FlxEase.backIn});
				else
					if (ClientPrefs.flashing)
						FlxTween.flicker(item);
			}

			FlxTween.cancelTweensOf(pauseTom);
			FlxTween.cancelTweensOf(bg);
			FlxTween.cancelTweensOf(bgGrid);
			FlxTween.cancelTweensOf(levelInfo);
			FlxTween.cancelTweensOf(blueballedTxt);
			FlxTween.cancelTweensOf(songInfo);

			FlxTween.tween(pauseTom, {y: pauseTom.y + FlxG.height}, 1, {ease: FlxEase.backIn});
			FlxTween.tween(bg, {alpha: 0}, 1, {ease: FlxEase.backIn});
			FlxTween.tween(bgGrid, {alpha: 0}, 1, {ease: FlxEase.backIn});
			FlxTween.tween(levelInfo, {alpha: 0}, 1, {ease: FlxEase.backIn});
			FlxTween.tween(blueballedTxt, {alpha: 0}, 1, {ease: FlxEase.backIn});
			FlxTween.tween(songInfo, {alpha: 0}, 1, {ease: FlxEase.backIn});
			
			FlxG.sound.play(Paths.sound('confirmMenu'));

			subStateClosing = true;
			
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				close();
			});
		}
	}

	override function close() {
		for (key => video in PlayState.instance.modchartVideos) {
			if (!video.bitmap.isPlaying && !video.stayPaused) {
				video.resume();
			}
		}

		super.close();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.4;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isPauseMenuItem = true;
			item.targetY = i;
			item.x = FlxG.width - item.width - 30;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("tomgles.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
