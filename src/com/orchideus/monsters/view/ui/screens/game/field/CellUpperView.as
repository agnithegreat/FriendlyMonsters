/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.catalystapps.gaf.display.GAFMovieClip;
import com.catalystapps.gaf.event.SequenceEvent;
import com.orchideus.monsters.model.game.Cell;
import com.orchideus.monsters.view.ui.Animations;

import starling.core.Starling;
import starling.events.Event;

public class CellUpperView extends AbstractView {

    public static const REMOVE_BLOCK: String = "remove_block_CellUpperView";

    private var _cell: Cell;
    public function get cell():Cell {
        return _cell;
    }

    private var _animation: GAFMovieClip;

    private var _currentRank: int;

    private var _select: CellSelectView;

    public function CellUpperView(refs:CommonRefs, cell: Cell) {
        _cell = cell;

        super(refs);
    }

    override protected function initialize():void {
        if (_cell.blockType) {
            _animation = new GAFMovieClip(Animations.getAsset("monsters", _cell.blockType));
            _animation.fps = 24;
            _animation.touchable = false;
            _animation.x = int(CellView.tileWidth / 2);
            _animation.y = int(CellView.tileHeight / 2);
            _animation.pivotX = int(_animation.width / 2);
            _animation.pivotY = int(_animation.height / 2);
            addChild(_animation);
            Starling.juggler.add(_animation);
        }

        _cell.addEventListener(Cell.SELECT, handleSelect);
        _cell.addEventListener(Cell.IDLE, handleIdle);
        _cell.addEventListener(Cell.UPDATE, handleUpdate);
        handleUpdate(null);

        _select = new CellSelectView(_refs);
        _select.visible = false;
        addChild(_select);

        x = int(_cell.x * CellView.tileWidth);
        y = int(_cell.y * CellView.tileHeight);
    }

    private function playState(state: String, listen: Boolean = true):void {
        if (listen) {
            _animation.addEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);
        }
        _animation.setSequence(state);
    }

    private function handleSequenceEnd(e: Event):void {
        _animation.removeEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleSequenceEnd);
        _animation.visible = _cell.block > 0;
        var id: String = "L"+(4-_cell.block)+"_";
        playState(id+"Stop", false);

        if (_cell.block==0) {
            dispatchEventWith(REMOVE_BLOCK);
        }
    }

    private function handleSelect(e: Event):void {
        if (_cell.selected) {
            _select.show();
        } else {
            _select.visible = false;
        }
    }

    private function handleIdle(e: Event):void {
        if (_animation) {
            var id: String = "L"+(4-_currentRank)+"_";
            playState(id+"Idle_1");
        }
    }

    private function handleUpdate(e: Event):void {
        if (_animation) {
            if (_currentRank) {
                if (_currentRank != _cell.block) {
                    var id: String = "L"+(4-_currentRank)+"_";
                    playState(id+"Transformation");
                }
            } else if (_cell.block) {
                handleSequenceEnd(null);
            }
            _currentRank = _cell.block;
        }
    }

    override public function destroy():void {
        removeEventListeners(REMOVE_BLOCK);

        _cell.removeEventListener(Cell.SELECT, handleSelect);
        _cell.removeEventListener(Cell.IDLE, handleIdle);
        _cell.removeEventListener(Cell.UPDATE, handleUpdate);

        super.destroy();
    }
}
}
