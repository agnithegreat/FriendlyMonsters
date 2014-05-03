/**
 * Created by agnither on 09.04.14.
 */
package com.orchideus.monsters {
import com.agnither.utils.CommonRefs;
import com.agnither.utils.LocalizationManager;
import com.agnither.utils.ResourcesManager;
import com.orchideus.monsters.model.game.Cell;
import com.orchideus.monsters.model.game.Game;
import com.orchideus.monsters.model.Player;
import com.orchideus.monsters.view.ui.UI;
import com.orchideus.monsters.view.ui.screens.GameScreen;

import starling.display.Stage;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.EventDispatcher;

public class GameController extends EventDispatcher {

    private var _stage: Stage;
    private var _resources: ResourcesManager;
    private var _refs: CommonRefs;

    private var _player: Player;
    public function get player():Player {
        return _player;
    }

    private var _game: Game;
    public function get game():Game {
        return _game;
    }

    private var _ui: UI;

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

        _ui = new UI(_refs, this);
        _ui.addEventListener(GameScreen.SELECT_CELL, handleSelectCell);
        _stage.addChild(_ui);
    }

    public function ready():void {
        _ui.showScreen(GameScreen.ID);

        _stage.addEventListener(EnterFrameEvent.ENTER_FRAME, handleEnterFrame);

        start();
    }

    public function start():void {
        _game.init(8, 8);
    }

    private function handleEnterFrame(e: EnterFrameEvent):void {
        _game.step(e.passedTime);
    }





    private function handleSelectCell(e: Event):void {
        _game.selectCell(e.data as Cell);
    }
}
}
