/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.catalystapps.gaf.display.GAFMovieClip;
import com.catalystapps.gaf.event.SequenceEvent;
import com.orchideus.monsters.model.game.Gem;
import com.orchideus.monsters.view.ui.Animations;

import starling.core.Starling;
import starling.events.Event;

public class BlockView extends AbstractView {

    protected var _gem: Gem;
    public function get gem():Gem {
        return _gem;
    }

    private var _animation: GAFMovieClip;

    private var _currentRank: int;

    public function BlockView(refs:CommonRefs, gem: Gem) {
        _gem = gem;

        super(refs);
    }

    override protected function initialize():void {
        _animation = new GAFMovieClip(Animations.getAsset("monsters", _gem.type));
        _animation.fps = 24;
        _animation.touchable = false;
        _animation.x = int(CellView.tileWidth / 2);
        _animation.y = int(CellView.tileHeight / 2);
        _animation.pivotX = int(_animation.width / 2);
        _animation.pivotY = int(_animation.height / 2);
        addChild(_animation);
        Starling.juggler.add(_animation);

        x = int(_gem.cell.x * CellView.tileWidth);
        y = int(_gem.cell.y * CellView.tileHeight);

        _gem.addEventListener(Gem.UPDATE, handleUpdate);
        _gem.addEventListener(Gem.IDLE, handleIdle);

        handleUpdate(null);
    }

    private function playState(state: String, listen: Boolean = true):void {
        if (listen) {
            _animation.addEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);
        }
        _animation.setSequence(state);
    }

    private function handleSequenceEnd(e: Event):void {
        _animation.removeEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);

        if (_gem.blocked) {
            playState("L" + (4 - _gem.blockRank) + "_Stop", false);
        } else {
            destroy();
        }
    }

    private function handleUpdate(e: Event):void {
        if (_currentRank) {
            if (_currentRank != _gem.blockRank) {
                if (_gem.blockRank==0 && _gem.collect) {
                    dispatchEventWith(GemView.KILL, false, _gem);
                    visible = false;
                } else {
                    playState("L"+(4-_currentRank)+"_Transformation");
                }
            }
        } else if (_gem.blockRank) {
            handleSequenceEnd(null);
        }
        _currentRank = _gem.blockRank;
    }

    private function handleIdle(e: Event):void {
        parent.addChild(this);
        playState("L"+(4-_currentRank)+"_Idle_1");
    }

    override public function destroy():void {
        Starling.juggler.removeTweens(_animation);

        removeEventListeners(GemView.KILL);

        if (_gem) {
            _gem.removeEventListener(Gem.UPDATE, handleUpdate);
            _gem.removeEventListener(Gem.IDLE, handleIdle);
            _gem = null;
        }

        if (_animation) {
            Starling.juggler.remove(_animation);
            removeChild(_animation, true);
            _animation = null;
        }

        removeFromParent(true);

        super.destroy();
    }
}
}
