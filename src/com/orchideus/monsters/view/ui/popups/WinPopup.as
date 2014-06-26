/**
 * Created by agnither on 26.05.14.
 */
package com.orchideus.monsters.view.ui.popups {
import com.agnither.ui.Popup;
import com.agnither.utils.CommonRefs;

import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Button;
import starling.events.Event;

public class WinPopup extends Popup {

    public static const ID: String = "WinPopup";

    public static const CONTINUE: String = "continue_WinPopup";

    private var _back: Scale9Image;

    private var _continue: Button;

    public function WinPopup(refs:CommonRefs) {
        super(refs, true);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.winPopup);

        var texture: Scale9Textures = new Scale9Textures(_refs.gui.getTexture("window_sample.png"), new Rectangle(55, 55, 280, 20));
        _back = new Scale9Image(texture);
        _back.width = _backSize.width;
        _back.height = _backSize.height;
        addChildAt(_back, 0);

        _continue = _links.continue_btn;
        _continue.addEventListener(Event.TRIGGERED, handleContinue);
    }

    override public function open():void {
        y = -height;

        super.open();

        _links.star1.visible = _data.stars>=1;
        _links.star2.visible = _data.stars>=2;
        _links.star3.visible = _data.stars>=3;

        _links.percent_tf.text = String(_data.percent)+"%";

        Starling.juggler.tween(this, 0.5, {y: _defaultPosition.y, transition: Transitions.EASE_OUT});
    }

    override public function close():void {
        super.close();

        Starling.juggler.tween(this, 0.5, {y: -height, transition: Transitions.EASE_IN, onComplete: removeFromParent});
    }

    private function handleContinue(e: Event):void {
        dispatchEventWith(CONTINUE, true);
        dispatchEventWith(CLOSE, true);
    }
}
}
