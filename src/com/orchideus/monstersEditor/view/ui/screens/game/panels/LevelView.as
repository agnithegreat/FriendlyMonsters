/**
 * Created by agnither on 22.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.data.LevelVO;

import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

public class LevelView extends AbstractView {

    public static const LEVEL_SELECTED: String = "level_selected_LevelView";

    private var _level: LevelVO;

    private var _text: TextField;

    public function LevelView(refs:CommonRefs, level: LevelVO) {
        _level = level;

        super(refs);
    }

    override protected function initialize():void {
        _text = new TextField(80, 50, _level ? String(_level.id) : "+", "Verdana", 42, 0xFFFFFF);
        addChild(_text);

        addEventListener(TouchEvent.TOUCH, handleTouch);
    }

    public function select(level: LevelVO):void {
        _text.color = _level==level ? 0xFFFF00 : 0xFFFFFF;
        _text.bold = _level==level;
    }

    private function handleTouch(e: TouchEvent):void {
        var touch: Touch = e.getTouch(this, TouchPhase.ENDED);
        if (touch) {
            dispatchEventWith(LEVEL_SELECTED, true, _level);
        }
    }
}
}
