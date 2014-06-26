/**
 * Created by agnither on 22.05.14.
 */
package com.orchideus.monstersEditor.view.ui.common {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.utils.HAlign;

public class CheckBox extends AbstractView {

    public static const CHANGED: String = "changed_CheckBox";

    private var _box: Quad;

    private var _check: Quad;
    public function get check():Boolean {
        return _check.visible;
    }
    public function set check(value: Boolean):void {
        if (_check.visible != value) {
            _check.visible = value;
            dispatchEventWith(CHANGED);
        }
    }

    private var _label: TextField;
    public function set text(value: String):void {
        _label.text = value;
    }

    public function set enabled(value: Boolean):void {
        alpha = value ? 1 : 0.5;
        touchable = value;
    }

    public function CheckBox(refs: CommonRefs) {
        super(refs);
    }

    override protected function initialize():void {
        _box = new Quad(20, 20, 0xFFFFFF);
        addChild(_box);

        _check = new Quad(14, 14, 0);
        _check.x = 3;
        _check.y = 3;
        addChild(_check);

        _label = new TextField(100, 20, "");
        _label.hAlign = HAlign.LEFT;
        _label.x = 30;
        addChild(_label);

        addEventListener(TouchEvent.TOUCH, handleTouch);
    }

    private function handleTouch(e: TouchEvent):void {
        var touch: Touch = e.getTouch(this, TouchPhase.ENDED);
        if (touch) {
            check = !check;
        }
    }
}
}
