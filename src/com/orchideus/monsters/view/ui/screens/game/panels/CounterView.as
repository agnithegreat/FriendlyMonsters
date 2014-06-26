/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Counter;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;

public class CounterView extends AbstractView {

    private var _counter: Counter;
    public function get counter():Counter {
        return _counter;
    }

    private var _icon: Image;
    public function get icon():Image {
        return _icon;
    }

    private var _check: Sprite;
    private var _text: TextField;

    private var _amount: int;
    public function get amount():int {
        return _amount;
    }
    public function set amount(value: int):void {
        _amount = value;
        updateView();
    }

    public function CounterView(refs:CommonRefs, counter: Counter) {
        _counter = counter;

        super(refs);
    }

    override protected function initialize():void {
        createFromCommon(_refs.guiConfig.common.counter);

        _icon = new Image(_refs.game.getTexture(_counter.type+".png"));
        _icon.x = -_icon.width/2;
        _icon.y = -_icon.height/2;
        _links.icon.addChild(_icon);

        _check = _links.check;
        _check.visible = false;

        _text = _links.amount_tf;

        update(0, false);
    }

    public function delayedUpdate(delay: Number):void {
        Starling.juggler.delayCall(update, delay, _counter.amount);
    }

    private function update(value: int, animate: Boolean = true):void {
        if (animate) {
            Starling.juggler.tween(this, 0.5, {"amount": value});
        } else {
            amount = value;
        }
    }

    private function updateView():void {
        if (!_counter) {
            return;
        }

        if (_amount>=_counter.target) {
            _check.visible = true;
        }
        _text.text = String(_amount) + "/" + String(_counter.target);
    }

    override public function destroy():void {
        Starling.juggler.removeTweens(this);

        _counter = null;

        _icon = null;
        _check = null;
        _text = null;

        super.destroy();
    }
}
}
