/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Counter;

import starling.display.Image;
import starling.events.Event;
import starling.text.TextField;

public class CounterView extends AbstractView {

    private var _counter: Counter;

    private var _shape: Image;
    private var _icon: Image;
    private var _check: Image;
    private var _text: TextField;

    public function CounterView(refs:CommonRefs, counter: Counter) {
        _counter = counter;

        super(refs);
    }

    override protected function initialize():void {
        _shape = new Image(_refs.gui.getTexture("counter_shape.png"));
        _shape.visible = false;
        addChild(_shape);

        _icon = new Image(_refs.gui.getTexture(_counter.type+".png"));
        _icon.pivotX = int(_icon.width/2);
        _icon.pivotY = int(_icon.height/2);
        _icon.x = int(_shape.width/2);
        _icon.y = int(_shape.height/2);
        addChild(_icon);

        _check = new Image(_refs.gui.getTexture("counter_check.png"));
        _check.visible = false;
        _check.x = 44;
        _check.y = 45;
        addChild(_check);

        _text = new TextField(_shape.width+20, 28, "", "game_counter_panel", -1, 0xFFFFFF);
        _text.hAlign = "center";
        _text.x = -10;
        _text.y = 71;
        addChild(_text);

        _counter.addEventListener(Counter.UPDATE, handleUpdate);
        handleUpdate(null);
    }

    private function handleUpdate(e: Event):void {
        if (_counter.completed) {
            if (_text.fontName != "game_counter_panel_light") {
                _text.fontName = "game_counter_panel_light";
            }

            _shape.visible = true;
            _check.visible = true;
        }

        _text.text = String(_counter.amount) + "/" + String(_counter.target);
    }
}
}
