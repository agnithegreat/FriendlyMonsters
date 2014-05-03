/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.CountersList;

import starling.display.Image;

public class GameLeftPanel extends AbstractView {

    private var _counters: CountersList;

    private var _back: Image;

    private var _list: Vector.<CounterView>;

    public function GameLeftPanel(refs:CommonRefs, counters: CountersList) {
        _counters = counters;

        super(refs);
    }

    override protected function initialize():void {
        _back = new Image(_refs.gui.getTexture("game_left_panel.png"));
        addChild(_back);

        _list = new <CounterView>[];
        var l: int = _counters.counters.length;
        for (var i:int = 0; i < l; i++) {
            var cv: CounterView = new CounterView(_refs, _counters.counters[i]);
            cv.x = 3;
            cv.y = 20 + i * 115;
            addChild(cv);
            _list.push(cv);
        }

        // TODO: motions
        x = 0;
        y = 193;
    }
}
}
