/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Gem;

import starling.display.Image;

public class GemPhantomView extends AbstractView {

    private var _gem: Gem;

    private var _view: Image;

    public function GemPhantomView(refs:CommonRefs, gem: Gem) {
        _gem = gem;

        super(refs);
    }

    override protected function initialize():void {
        _view = new Image(_refs.game.getTexture(_gem.type+".png"));
        _view.touchable = false;
        _view.x = int(CellView.tileWidth/2);
        _view.y = int(CellView.tileHeight/2);
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        addChild(_view);
    }

    override public function destroy():void {
        _gem = null;

        removeChild(_view, true);
        _view = null;

        removeFromParent(true);

        super.destroy();
    }
}
}
