/**
 * Created by agnither on 26.05.14.
 */
package com.orchideus.monsters.view.ui.popups.lose {
import com.agnither.ui.Popup;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.CountersList;

import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Button;
import starling.events.Event;

public class LosePopup extends Popup {

    public static const ID: String = "LosePopup";

    public static const RETRY: String = "retry_LosePopup";

    private var _back: Scale9Image;

    private var _list: Vector.<LoseCounterView>;

    private var _retry: Button;

    public function LosePopup(refs:CommonRefs) {
        super(refs, true);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.losePopup);

        var texture: Scale9Textures = new Scale9Textures(_refs.gui.getTexture("window_sample.png"), new Rectangle(55, 55, 280, 20));
        _back = new Scale9Image(texture);
        _back.width = _backSize.width;
        _back.height = _backSize.height;
        addChildAt(_back, 0);

        _list = new <LoseCounterView>[];

        _links.counter1.visible = false;
        _links.counter2.visible = false;
        _links.counter3.visible = false;

        _retry = _links.retry_btn;
        _retry.addEventListener(Event.TRIGGERED, handleRetry);
    }

    override public function open():void {
        y = stage.stageHeight;

        super.open();

        var counters: CountersList = _data as CountersList;
        var l: int = counters.counters.length;
        for (var i:int = 0; i < l; i++) {
            var cv: LoseCounterView = new LoseCounterView(_refs, counters.counters[i]);
            cv.x = _links["counter"+(i+1)].x;
            cv.y = _links["counter"+(i+1)].y;
            addChild(cv);
            _list.push(cv);
        }

        Starling.juggler.tween(this, 0.5, {y: _defaultPosition.y, transition: Transitions.EASE_OUT});
    }

    override public function close():void {
        super.close();

        Starling.juggler.tween(this, 0.5, {y: stage.stageHeight, transition: Transitions.EASE_IN, onComplete: removeList});
    }

    private function removeList():void {
        while (_list.length>0) {
            var counter: LoseCounterView = _list.shift();
            counter.destroy();
            removeChild(counter, true);
        }

        removeFromParent();
    }

    private function handleRetry(e: Event):void {
        dispatchEventWith(RETRY, true);
        dispatchEventWith(CLOSE, true);
    }
}
}
