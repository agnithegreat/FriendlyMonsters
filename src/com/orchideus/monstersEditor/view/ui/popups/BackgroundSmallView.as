/**
 * Created by agnither on 28.05.14.
 */
package com.orchideus.monstersEditor.view.ui.popups {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

import starling.display.Button;
import starling.events.Event;

public class BackgroundSmallView extends AbstractView {

    public static const BACKGROUND_SELECTED: String = "background_selected_BackgroundSmallView";

    private var _name: String;

    private var _view: Button;

    public function BackgroundSmallView(refs:CommonRefs, name: String) {
        _name = name;
        super(refs);
    }

    override protected function initialize():void {
        _view = new Button(_refs.backs.getTexture(_name));
        _view.addEventListener(Event.TRIGGERED, handleSelect);
        _view.scaleX = 0.125;
        _view.scaleY = 0.125;
        addChild(_view);
    }

    private function handleSelect(e: Event):void {
        dispatchEventWith(BACKGROUND_SELECTED, true, _name);
    }
}
}
