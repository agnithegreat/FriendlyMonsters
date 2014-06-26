/**
 * Created by agnither on 24.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Game;
import com.orchideus.monsters.model.game.Cell;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.filters.BlurFilter;

public class FieldConstructorView extends AbstractView {

    private var _game: Game;

    public function FieldConstructorView(refs:CommonRefs, game: Game) {
        _game = game;

        super(refs);
    }

    override protected function initialize():void {
        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.CLEAR, handleClear);
    }

    private function handleInit(e: Event):void {
        for (var i:int = 0; i < _game.field.length; i++) {
            var cell: Cell = _game.field[i];
            if (cell.graphics && cell.graphics[0]) {
                var image:Image = new Image(_refs.game.getTexture(cell.graphics[0]+".png"));
                image.pivotX = image.width / 2;
                image.pivotY = image.height / 2;
                image.rotation = cell.graphics[1] * Math.PI / 2;
                image.x = (cell.x + 0.5) * CellView.tileWidth;
                image.y = (cell.y + 0.5) * CellView.tileHeight;
                addChild(image);
            }
        }

        filter = BlurFilter.createDropShadow(5, Math.PI/2, 0, 0.6);
        filter.cache();
    }

    private function handleClear(e: Event):void {
        while (numChildren > 0) {
            removeChildAt(0, true);
        }
    }
}
}
