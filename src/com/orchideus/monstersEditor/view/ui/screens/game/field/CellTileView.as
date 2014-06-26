/**
 * Created by agnither on 24.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monstersEditor.model.game.Cell;

import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;

public class CellTileView extends AbstractView {

    private var _cell: Cell;
    public function get texture():Texture {
        return _refs.game.getTexture(_cell.graphics[0]+".png");
    }

    private var _tile: Image;

    public function CellTileView(refs:CommonRefs, cell: Cell) {
        _cell = cell;

        super(refs);
    }

    override protected function initialize():void {
        _tile = new Image(texture);
        _tile.pivotX = _tile.width / 2;
        _tile.pivotY = _tile.height / 2;
        addChild(_tile);

        x = (_cell.x + 0.5) * CellView.tileWidth;
        y = (_cell.y + 0.5) * CellView.tileHeight;

        _cell.addEventListener(Cell.UPDATE, handleUpdate);
        handleUpdate(null);
    }

    private function handleUpdate(e: Event):void {
        _tile.visible = _cell.graphics[0];
        if (_cell.graphics[0]) {
            _tile.texture = texture;
            _tile.rotation = _cell.graphics[1] * Math.PI / 2;
        }
    }
}
}
