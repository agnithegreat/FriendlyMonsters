/**
 * Created by agnither on 24.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monstersEditor.model.game.LevelEditor;
import com.orchideus.monstersEditor.model.game.Cell;

import starling.events.Event;

public class FieldConstructorView extends AbstractView {

    private var _editor: LevelEditor;

    public function FieldConstructorView(refs:CommonRefs, game: LevelEditor) {
        _editor = game;

        super(refs);
    }

    override protected function initialize():void {
        _editor.addEventListener(LevelEditor.INIT, handleInit);
    }

    private function handleInit(e: Event):void {
        for (var i:int = 0; i < _editor.field.length; i++) {
            var cell: Cell = _editor.field[i];
            var tile: CellTileView = new CellTileView(_refs, cell);
            addChild(tile);
        }
    }
}
}
