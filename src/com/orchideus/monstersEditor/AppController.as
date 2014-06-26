/**
 * Created by agnither on 23.05.14.
 */
package com.orchideus.monstersEditor {
import com.agnither.utils.ResourcesManager;
import com.orchideus.monsters.GameController;

import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;

public class AppController extends EventDispatcher {

    private var _gameController: GameController;
    private var _editorController: LevelEditorController;

    public function AppController(stage: Stage, resources: ResourcesManager) {
        _gameController = new GameController(stage, resources);
        _editorController = new LevelEditorController(stage, resources);
    }

    public function init():void {
        _gameController.init();
        _editorController.init();
    }

    public function ready():void {
        _editorController.addEventListener(LevelEditorController.PLAY_LEVEL, handlePlayLevel);
        _editorController.addEventListener(LevelEditorController.STOP_LEVEL, handleStopLevel);
        _editorController.ready();

        _gameController.ready();
        _gameController.ui.visible = false;
    }

    private function handlePlayLevel(e: Event):void {
        playLevel(e.data);
    }

    private function handleStopLevel(e: Event):void {
        stopLevel();
    }

    private function playLevel(data: Object):void {
        _gameController.ui.visible = true;
        _gameController.playLevel(data);
    }

    private function stopLevel():void {
        _gameController.ui.visible = false;
        _gameController.stopLevel();
    }
}
}
