/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Cell;

import starling.events.Event;

public class CellUpperView extends AbstractView {

    private var _cell: Cell;
    public function get cell():Cell {
        return _cell;
    }

    private var _select: CellSelectView;

    public function CellUpperView(refs:CommonRefs, cell: Cell) {
        _cell = cell;

        super(refs);
    }

    override protected function initialize():void {
        _cell.addEventListener(Cell.SELECT, handleSelect);

        _select = new CellSelectView(_refs);
        _select.visible = false;
        addChild(_select);

        x = int(_cell.x * CellView.tileWidth);
        y = int(_cell.y * CellView.tileHeight);
    }

    private function handleSelect(e: Event):void {
        if (_cell.selected) {
            _select.show();
        } else {
            _select.visible = false;
        }
    }

    override public function destroy():void {
        _cell.removeEventListener(Cell.SELECT, handleSelect);

        super.destroy();
    }
}
}
