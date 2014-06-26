/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.popups.lose {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Counter;

import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;

public class LoseCounterView extends AbstractView {

    private var _counter: Counter;
    public function get counter():Counter {
        return _counter;
    }

    private var _shape: Sprite;

    private var _icon: Image;

    private var _check: Sprite;
    private var _fail: Sprite;
    private var _text: TextField;

    public function LoseCounterView(refs:CommonRefs, counter: Counter) {
        _counter = counter;

        super(refs);
    }

    override protected function initialize():void {
        createFromCommon(_refs.guiConfig.common.counterBig);

        _shape = _links.shape;
        _shape.visible = false;

        _icon = new Image(_refs.game.getTexture(_counter.type+".png"));
        _icon.x = -_icon.width/2;
        _icon.y = -_icon.height/2;
//        _links.icon.scaleX = 1.5;
//        _links.icon.scaleY = 1.5;
        _links.icon.addChild(_icon);

        _check = _links.check;
        _check.visible = false;

        _fail = _links.fail;
        _fail.visible = false;

        _text = _links.amount_tf;

        updateView();
    }

    private function updateView():void {
        _text.fontName = _counter.completed ? "lose_counter_green" : "lose_counter_red";
        _shape.visible = _counter.completed;
        _check.visible = _counter.completed;
        _fail.visible = !_counter.completed;
        _text.text = String(_counter.amount) + "/" + String(_counter.target);
    }

    override public function destroy():void {
        _counter = null;

        _shape = null;
        _icon = null;
        _check = null;
        _fail = null;
        _text = null;

        super.destroy();
    }
}
}
