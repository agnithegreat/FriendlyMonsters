/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.CountersList;
import com.orchideus.monsters.model.game.Game;

import flash.geom.Matrix;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;

public class GameCountersPanel extends AbstractView {

    private var _game: Game;
    private var _counters: CountersList;

    private var _list: Vector.<CounterView>;
    public function getCounterPosition(type: String, relative: DisplayObject):Matrix {
        for (var i:int = 0; i < _list.length; i++) {
            if (_list[i].counter.type == type) {
                return _list[i].icon.getTransformationMatrix(relative);
            }
        }
        return null;
    }

    public function GameCountersPanel(refs:CommonRefs, game: Game) {
        _game = game;
        _counters = _game.counters;

        super(refs);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.gameCountersPanel);

        _links.counter1.visible = false;
        _links.counter2.visible = false;
        _links.counter3.visible = false;
        _links.counter4.visible = false;

        _list = new <CounterView>[];

        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.CLEAR, handleClear);

        visible = false;
    }

    public function delayedUpdate(delay: Number):void {
        for (var i:int = 0; i < _list.length; i++) {
            _list[i].delayedUpdate(delay);
        }
    }

    private function handleInit(e: Event):void {
        var l: int = _counters.counters.length;
        for (var i:int = 0; i < l; i++) {
            var cv: CounterView = new CounterView(_refs, _counters.counters[i]);
            cv.x = _links["counter"+(i+1)].x;
            cv.y = _links["counter"+(i+1)].y;
            addChild(cv);
            _list.push(cv);
        }

        Starling.juggler.removeTweens(this);
        visible = true;
    }

    private function handleClear(e: Event):void {
        while (_list.length>0) {
            var counter: CounterView = _list.shift();
            counter.destroy();
            removeChild(counter, true);
        }

        Starling.juggler.removeTweens(this);
        hide();
    }
}
}
