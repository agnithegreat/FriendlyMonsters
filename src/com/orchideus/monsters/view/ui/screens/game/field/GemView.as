/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.catalystapps.gaf.display.GAFMovieClip;
import com.catalystapps.gaf.event.SequenceEvent;
import com.orchideus.monsters.data.TimingVO;
import com.orchideus.monsters.model.game.Gem;
import com.orchideus.monsters.view.ui.Animations;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.events.Event;

public class GemView extends AbstractView {

    public static const KILL: String = "kill_GemView";

    protected var _gem: Gem;
    public function get gem():Gem {
        return _gem;
    }

    protected var _animation: GAFMovieClip;

    private var _falling: int;

    public function GemView(refs:CommonRefs, gem: Gem) {
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
        _falling = 0;

        if (_gem.fall) {
            clipRect = new Rectangle(0, 0, CellView.tileWidth, CellView.tileHeight);
            innerFall();
        }

        _gem.addEventListener(Gem.MOVE, handleMove);
        _gem.addEventListener(Gem.HINT, handleHint);
        _gem.addEventListener(Gem.IDLE, handleIdle);
        _gem.addEventListener(Gem.KILL, handleKill);
    }

    private function playState(state: String, listen: Boolean = true):void {
        if (listen) {
            _animation.addEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);
        }
        _animation.setSequence(state);
    }

    private function handleSequenceEnd(e: Event):void {
        _animation.removeEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);
        playState("Stop", false);
    }

    private function innerFall():void {
        _animation.y -= CellView.tileHeight;
        _falling++;
        Starling.juggler.tween(_animation, TimingVO.fall, {y: _animation.y+CellView.tileHeight, onComplete: handleFall});
    }

    private function handleMove(e: Event = null):void {
        var newX: int = _gem.cell.x * CellView.tileWidth;
        var newY: int = _gem.cell.y * CellView.tileHeight;
        if (e) {
            if (e.data) {
                parent.addChild(this);
                Starling.juggler.tween(this, TimingVO.swap, {x: newX, y: newY});
            } else if (newY > y) {
//                if (_falling==0 && _animation) {
//                    playState("Fall");
//                }
                _falling++;
                Starling.juggler.tween(this, TimingVO.fall+0.01, {x: newX, y: newY, onComplete: handleFall});
            }
        }
    }

    private function handleFall():void {
        if (clipRect) {
            clipRect = null;
        }

        _falling--;
        if (_falling == 0 && _animation) {
            playState("Land");
        }
    }

    private function handleHint(e: Event):void {
        if (_animation) {
            parent.addChild(this);
            playState("Jump");
        }
    }

    private function handleIdle(e: Event):void {
        parent.addChild(this);
        playState("Idle_"+int(e.data));
    }

    private function handleKill(e: Event):void {
        dispatchEventWith(KILL, false, _gem);

        if (_gem.collect) {
            destroy();
        } else if (_animation) {
//            _animation.setSequence("Vanish");
//            Starling.juggler.delayCall(destroy, 0.3);
            Starling.juggler.tween(_animation, TimingVO.kill, {scaleX: 0, scaleY: 0, onComplete: destroy});
        }
    }

    override public function destroy():void {
        Starling.juggler.removeTweens(_animation);

        removeEventListeners(KILL);

        if (_gem) {
            _gem.removeEventListener(Gem.MOVE, handleMove);
            _gem.removeEventListener(Gem.HINT, handleHint);
            _gem.removeEventListener(Gem.IDLE, handleIdle);
            _gem.removeEventListener(Gem.KILL, handleKill);
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
