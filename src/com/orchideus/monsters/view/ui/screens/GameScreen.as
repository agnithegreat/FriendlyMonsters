/**
 * Created by agnither on 09.04.14.
 */
package com.orchideus.monsters.view.ui.screens {
import com.agnither.ui.Screen;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Game;
import com.orchideus.monsters.model.game.Gem;
import com.orchideus.monsters.view.ui.screens.game.field.CellUpperView;
import com.orchideus.monsters.view.ui.screens.game.field.CellView;
import com.orchideus.monsters.view.ui.screens.game.field.GemCounterView;
import com.orchideus.monsters.view.ui.screens.game.field.GemView;
import com.orchideus.monsters.view.ui.screens.game.panels.GameLeftPanel;
import com.orchideus.monsters.view.ui.screens.game.panels.GameRightPanel;

import flash.geom.Rectangle;

import starling.animation.Transitions;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

public class GameScreen extends Screen {

    public static const ID: String = "GameScreen";

    public static const SELECT_CELL: String = "SELECT_CELL_GameScreen";

    private var _game: Game;

    private var _back: Image;
    private var _field: Image;

    private var _fieldContainer: Sprite;
    private var _cells: Sprite;
    private var _gems: Sprite;
    private var _cellsUpper: Sprite;
    private var _counters: Sprite;

    private var _rollOver: CellView;

    private var _score: TextField;

    private var _leftPanel: GameLeftPanel;
    private var _rightPanel: GameRightPanel;

    public function GameScreen(refs:CommonRefs, game: Game) {
        _game = game;

        super(refs);
    }

    override protected function initialize():void {
        _back = new Image(_refs.gui.getTexture("back.png"));
        addChild(_back);

        _field = new Image(_refs.gui.getTexture("field.png"));
        _field.x = 243;
        _field.y = 84;
        addChild(_field);

        _fieldContainer = new Sprite();
        _fieldContainer.clipRect = new Rectangle(0, 0, 586, 586);
        _fieldContainer.x = 252;
        _fieldContainer.y = 91;
        addChild(_fieldContainer);

        _cells = new Sprite();
        _cells.addEventListener(TouchEvent.TOUCH, handleTouch);
        _fieldContainer.addChild(_cells);

        _gems = new Sprite();
        _gems.addEventListener(GemView.REMOVE, handleGemRemove);
        _fieldContainer.addChild(_gems);

        _counters = new Sprite();
        _counters.addEventListener(GemCounterView.REMOVE, handleCounterRemove);
        _fieldContainer.addChild(_counters);

        _cellsUpper = new Sprite();
        _fieldContainer.addChild(_cellsUpper);

        _score = new TextField(_field.width, 96, "", "game_score", -1, 0xFFFFFF);
        _score.x = _field.x;
//        _score.y = -4;
        addChild(_score);

        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.UPDATE, handleUpdate);
        _game.addEventListener(Game.CLEAR, handleClear);
    }

    private function handleInit(e: Event):void {
        _game.addEventListener(Game.NEW_GEM, handleNewGem);

        for (var i:int = 0; i < _game.field.length; i++) {
            if (_game.field[i].available) {
                var c: CellView = new CellView(_refs, _game.field[i]);
                _cells.addChild(c);

                var cu: CellUpperView = new CellUpperView(_refs, _game.field[i]);
                _cellsUpper.addChild(cu);
            }

            if (_game.field[i].gem) {
                var g: GemView = new GemView(_refs, _game.field[i].gem);
                _gems.addChild(g);

                var gc: GemCounterView = new GemCounterView(_refs, _game.field[i].gem);
                _counters.addChild(gc);
            }
        }

        _leftPanel = new GameLeftPanel(_refs, _game.counters);
        addChild(_leftPanel);

        _rightPanel = new GameRightPanel(_refs, _game.bonuses);
        addChild(_rightPanel);
    }

    private function handleUpdate(e: Event):void {
        _score.text = String(_game.score);
    }

    private function handleNewGem(e: Event):void {
        var gem: GemView = new GemView(_refs, e.data as Gem);
        _gems.addChild(gem);

        var gemCounter: GemCounterView = new GemCounterView(_refs, e.data as Gem);
        _counters.addChild(gemCounter);
    }

    private function handleGemRemove(e: Event):void {
        var gem: GemView = e.target as GemView;
        _gems.addChild(gem);
        Starling.juggler.tween(gem, Gem.FALL_TIME*8, {y: gem.y+CellView.tileHeight*8, alpha: 0, transition: Transitions.EASE_IN, onComplete: gem.destroy});
    }

    private function handleCounterRemove(e: Event):void {
        var counter: GemCounterView = e.target as GemCounterView;
        counter.destroy();
        _gems.removeChild(counter, true);
    }

    private function handleTouch(e: TouchEvent):void {
        var touch: Touch = e.getTouch(_cells);
        if (touch) {
            var test: DisplayObject = _cells.hitTest(touch.getLocation(_cells));
            if (test) {
                var cell: CellView = test.parent as CellView;
                if (cell) {
                    if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED && _rollOver && _rollOver != cell) {
                        _rollOver = cell;
                        dispatchEventWith(SELECT_CELL, true, _rollOver.cell);

                        if (touch.phase != TouchPhase.BEGAN) {
                            _rollOver = null;
                        }
                    } else if (touch.phase == TouchPhase.ENDED) {
                        _rollOver = null;
                    }
                }
            }
        }
    }

    private function handleClear(e: Event):void {
        _game.removeEventListener(Game.NEW_GEM, handleNewGem);

        while (_cells.numChildren>0) {
            var cell: CellView = _cells.removeChildAt(0) as CellView;
            cell.destroy();
        }

        while (_gems.numChildren>0) {
            var gem: GemView = _gems.getChildAt(0) as GemView;
            gem.destroy();
        }

        _rollOver = null;
    }
}
}
