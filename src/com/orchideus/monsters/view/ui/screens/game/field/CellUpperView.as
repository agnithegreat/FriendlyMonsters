/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Cell;

import starling.display.Image;
import starling.events.Event;

public class CellUpperView extends AbstractView {

    private var _cell: Cell;
    public function get cell():Cell {
        return _cell;
    }

    private var _block: Image;

    public function CellUpperView(refs:CommonRefs, cell: Cell) {
        _cell = cell;

        super(refs);
    }

    override protected function initialize():void {
        _block = new Image(_refs.gui.getTexture("ice3.png"));
        _block.touchable = false;
        _block.x = int(CellView.tileWidth/2);
        _block.y = int(CellView.tileHeight);
        addChild(_block);

        _cell.addEventListener(Cell.UPDATE, handleUpdate);
        handleUpdate(null);

        x = int(_cell.x * CellView.tileWidth);
        y = int(_cell.y * CellView.tileHeight);
    }

    private function handleUpdate(e: Event):void {
        _block.visible = _cell.block>0;
        if (_cell.block) {
            _block.texture = _refs.gui.getTexture("ice"+_cell.block+".png");
            _block.readjustSize();
            _block.pivotX = int(_block.width/2);
            _block.pivotY = int(_block.height);
        }
    }
}
}
