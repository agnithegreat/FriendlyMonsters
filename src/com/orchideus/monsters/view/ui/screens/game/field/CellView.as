/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Cell;

import starling.display.Image;

public class CellView extends AbstractView {

    public static var tileWidth: Number = 74;
    public static var tileHeight: Number = 74;

    private var _cell: Cell;
    public function get cell():Cell {
        return _cell;
    }

    private var _view: Image;

    public function CellView(refs:CommonRefs, cell: Cell) {
        _cell = cell;

        super(refs);
    }

    override protected function initialize():void {
        var type: String = (_cell.x+_cell.y) % 2 ? "light" : "dark";
        _view = new Image(_refs.game.getTexture("cell_"+type+".png"));
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        _view.x = int(tileWidth/2);
        _view.y = int(tileHeight/2);
        addChild(_view);

        x = int(_cell.x * tileWidth);
        y = int(_cell.y * tileHeight);
    }
}
}
