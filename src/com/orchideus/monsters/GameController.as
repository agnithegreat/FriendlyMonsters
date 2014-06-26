/**
 * Created by agnither on 09.04.14.
 */
package com.orchideus.monsters {
import com.agnither.utils.CommonRefs;
import com.agnither.utils.LocalizationManager;
import com.agnither.utils.ResourcesManager;
import com.orchideus.monsters.data.LevelVO;
import com.orchideus.monsters.data.LevelsStorage;
import com.orchideus.monsters.model.game.Cell;
import com.orchideus.monsters.model.game.Game;
import com.orchideus.monsters.model.Player;
import com.orchideus.monsters.view.ui.UI;
import com.orchideus.monsters.view.ui.popups.lose.LosePopup;
import com.orchideus.monsters.view.ui.popups.WinPopup;
import com.orchideus.monsters.view.ui.screens.GameScreen;
import com.orchideus.monsters.view.ui.screens.game.panels.BonusView;

import starling.core.Starling;
import starling.display.Stage;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.EventDispatcher;

public class GameController extends EventDispatcher {

    private var _stage: Stage;
    private var _resources: ResourcesManager;
    private var _refs: CommonRefs;

    private var _levels: LevelsStorage;

    private var _player: Player;
    public function get player():Player {
        return _player;
    }

    private var _game: Game;
    public function get game():Game {
        return _game;
    }

    private var _ui: UI;
    public function get ui():UI {
        return _ui;
    }

    private var _currentLevel: int;
    private var _currentData: Object;

    public function GameController(stage: Stage, resources: ResourcesManager) {
        _stage = stage;
        _resources = resources;
        _refs = new CommonRefs(_resources);
    }

    public function init():void {
        _player = new Player();
        _player.init();

        LocalizationManager.init(_player.language);

        _game = new Game();
        _game.addEventListener(Game.COMPLETED, handleGameCompleted);

        _ui = new UI(_refs, this);
        _ui.addEventListener(GameScreen.SELECT_CELL, handleSelectCell);
        _ui.addEventListener(BonusView.SELECT_BONUS, handleSelectBonus);

        _ui.addEventListener(WinPopup.CONTINUE, handleWinContinue);
        _ui.addEventListener(LosePopup.RETRY, handleLoseRetry);
        _stage.addChild(_ui);
    }

    public function ready():void {
        _levels = new LevelsStorage(_resources);

        _ui.showScreen(GameScreen.ID);
    }

    public function start(id: int):void {
        if (!_game.started) {
            _currentLevel = id;

            _levels.addEventListener(LevelsStorage.LEVEL_LOADED, handleLevelLoaded);
            _levels.load(_currentLevel, true);
        }
    }

    public function playLevel(data: Object):void {
        if (!_game.started) {
            _currentData = data;

            if (!_resources.backs.getTexture(data.background)) {
                _resources.addEventListener(ResourcesManager.COMPLETE, handleReloadBack);
                _resources.reloadBack(data.background);
            } else {
                startLevel();
            }
        }
    }

    private function startLevel():void {
        if (!_game.started) {
            _game.init(_currentData);
            _stage.addEventListener(EnterFrameEvent.ENTER_FRAME, handleEnterFrame);
        }
    }

    public function stopLevel():void {
        if (_game.started) {
            _stage.removeEventListener(EnterFrameEvent.ENTER_FRAME, handleEnterFrame);
            _game.clear();
        }
    }

    private function handleLevelLoaded(e: Event):void {
        _levels.removeEventListener(LevelsStorage.LEVEL_LOADED, handleLevelLoaded);
        var level: LevelVO = e.data as LevelVO;
        if (level) {
            playLevel(level.data);
        }
    }

    private function handleReloadBack(e: Event):void {
        _resources.removeEventListener(ResourcesManager.COMPLETE, handleReloadBack);
        startLevel();
    }

    private function handleEnterFrame(e: EnterFrameEvent):void {
        _game.step(e.passedTime);
    }




    private function handleGameCompleted(e: Event):void {
        var win: Boolean = _game.win;
        var percent: int = _game.progress;
        var stars: int = _game.stars;

        if (win) {
            _ui.showPopup(WinPopup.ID, {"stars": stars, "percent": percent});
        } else {
            _ui.showPopup(LosePopup.ID, _game.counters);
        }

        stopLevel();
    }



    private function handleSelectCell(e: Event):void {
        _game.selectCell(e.data as Cell);
    }

    private function handleSelectBonus(e: Event):void {
        _game.selectBonus(e.data as String);
    }


    private function handleWinContinue(e: Event):void {
        start(_currentLevel+1);
    }

    private function handleLoseRetry(e: Event):void {
        start(_currentLevel);
    }
}
}
