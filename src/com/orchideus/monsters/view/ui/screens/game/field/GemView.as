/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.catalystapps.gaf.display.GAFMovieClip;
import com.orchideus.monsters.model.game.Gem;
import com.orchideus.monsters.view.ui.Animations;

import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class GemView extends AbstractView {

    public static const REMOVE: String = "remove_GemView";

    private var _gem: Gem;

    private var _hint: Image;
//    private var _view: Image;

    private var _view: GAFMovieClip;

    public function GemView(refs:CommonRefs, gem: Gem) {
        _gem = gem;

        super(refs);
    }

    override protected function initialize():void {
        _hint = new Image(_refs.gui.getTexture(_gem.type+".png"));
        _hint.touchable = false;
        _hint.pivotX = int(_hint.width/2);
        _hint.pivotY = int(_hint.height/2);
        _hint.x = int(CellView.tileWidth/2);
        _hint.y = int(CellView.tileHeight/2);
        _hint.scaleX = 1.1;
        _hint.scaleY = 1.1;
        addChild(_hint);

//        _view = new Image(_refs.gui.getTexture(_gem.type+".png"));
//        _view.touchable = false;
//        _view.pivotX = int(_view.width/2);
//        _view.pivotY = int(_view.height/2);
//        _view.x = int(CellView.tileWidth/2);
//        _view.y = int(CellView.tileHeight/2);
//        addChild(_view);

        _view = new GAFMovieClip(Animations.asset);
        _view.touchable = false;
        _view.x = int(CellView.tileWidth/2);
        _view.y = int(CellView.tileHeight/2);
        _view.scaleX = 0.7;
        _view.scaleY = 0.7;
//        _view.play();
//        _view.gotoAndPlay("Idle_1");
        _view.setSequence("Idle_1", true);
//        _view.setSequence("Idle_1", false);
        _view.loop = false;
//        _view.play();
        addChild(_view);

        x = int(_gem.cell.x * CellView.tileWidth);
        y = _gem.fall ? (_gem.cell.y-1) * CellView.tileHeight : int(_gem.cell.y * CellView.tileHeight);

        _gem.addEventListener(Gem.UPDATE, handleUpdate);
        _gem.addEventListener(Gem.LIGHT, handleLight);
        _gem.addEventListener(Gem.KILL, handleKill);

        handleLight(null);
    }

    private function handleUpdate(e: Event = null):void {
        var newX: int = _gem.cell.x * CellView.tileWidth;
        var newY: int = _gem.cell.y * CellView.tileHeight;
        if (e && e.data) {
            Starling.juggler.tween(this, Gem.SWAP_TIME, {x: newX, y: newY});
        } else {
            x = newX;
            y = newY;
        }
    }

    private function handleLight(e: Event):void {
        _hint.visible = _gem.light;
    }

    private function handleKill(e: Event):void {
        remove();
    }

    private function remove():void {
        dispatchEventWith(REMOVE, true);
    }

    override public function destroy():void {
        _gem.removeEventListener(Gem.UPDATE, handleUpdate);
        _gem.removeEventListener(Gem.LIGHT, handleLight);
        _gem.removeEventListener(Gem.KILL, handleKill);
        _gem = null;

        removeChild(_view, true);
        _view = null;

        removeFromParent(true);

        super.destroy();
    }
}
}
