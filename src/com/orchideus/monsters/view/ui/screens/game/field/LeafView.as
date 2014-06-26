/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Gem;

import starling.display.Image;

public class LeafView extends AbstractView {

    private var _view: Image;

    public function LeafView(refs:CommonRefs) {
        super(refs);
    }

    override protected function initialize():void {
        _view = new Image(_refs.game.getTexture("leaf.png"));
        _view.rotation = Math.PI/3;
        _view.touchable = false;
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        addChild(_view);

    }

    override public function destroy():void {
        removeChild(_view, true);
        _view = null;

        removeFromParent(true);

        super.destroy();
    }
}
}
