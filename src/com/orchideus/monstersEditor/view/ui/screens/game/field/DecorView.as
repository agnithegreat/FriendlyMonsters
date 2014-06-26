/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.data.DecorVO;
import com.orchideus.monstersEditor.model.game.Decor;

import starling.display.Image;
import starling.events.Event;

public class DecorView extends AbstractView {

    private var _decor: Decor;

    private var _view: Image;

    public function DecorView(refs:CommonRefs, decor: Decor) {
        _decor = decor;

        super(refs);
    }

    override protected function initialize():void {
        _view = new Image(_refs.game.getTexture(_decor.type+".png"));
        _view.touchable = false;
        _view.x = int(CellView.tileWidth/2 * _decor.decor.size[0]);
        _view.y = int(CellView.tileHeight/2 * _decor.decor.size[1]);
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        addChild(_view);

        x = _decor.position.x * CellView.tileWidth;
        y = _decor.position.y * CellView.tileHeight;

        _decor.addEventListener(Decor.DESTROY, handleDestroy);
    }

    private function handleDestroy(e: Event):void {
        destroy();
    }

    override public function destroy():void {
        _decor = null;

        removeChild(_view, true);
        _view = null;

        removeFromParent(true);

        super.destroy();
    }
}
}
