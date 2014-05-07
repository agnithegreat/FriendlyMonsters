/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Gem;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.text.TextField;

public class GemCounterView extends AbstractView {

    public static const REMOVE: String = "remove_GemCounterView";

    private var _gem: Gem;

    private var _counter: TextField;

    public function GemCounterView(refs:CommonRefs, gem: Gem) {
        _gem = gem;

        super(refs);
    }

    override protected function initialize():void {
        _counter = new TextField(CellView.tileWidth-15, 31, "", "game_counter", -1, 0xFFFFFF);
        _counter.touchable = false;
        _counter.hAlign = "right";
        _counter.y = 42;
        addChild(_counter);

        x = int(_gem.cell.x * CellView.tileWidth);
        y = _gem.fall ? (_gem.cell.y-1) * CellView.tileHeight : int(_gem.cell.y * CellView.tileHeight);

        _gem.addEventListener(Gem.UPDATE, handleUpdate);
        _gem.addEventListener(Gem.COUNTER, handleCounter);
        _gem.addEventListener(Gem.KILL, handleKill);
    }

    private function handleUpdate(e: Event = null):void {
        var newX: int = _gem.cell.x * CellView.tileWidth;
        var newY: int = _gem.cell.y * CellView.tileHeight;
        if (e && e.data) {
            Starling.juggler.tween(this, Gem.SWAP_TIME, {x: newX, y: newY});
        } else {
            x = newX;
            y = newY;
        }
    }

    private function handleCounter(e: Event):void {
        _counter.text = _gem.counter>0 ? "+"+_gem.counter : "";
    }

    private function handleKill(e: Event):void {
        remove();
    }

    private function remove():void {
        dispatchEventWith(REMOVE, true);
    }

    override public function destroy():void {
        _gem.removeEventListener(Gem.UPDATE, handleUpdate);
        _gem.removeEventListener(Gem.COUNTER, handleCounter);
        _gem.removeEventListener(Gem.KILL, handleKill);
        _gem = null;

        removeChild(_counter, true);
        _counter = null;

        removeFromParent(true);

        super.destroy();
    }
}
}
