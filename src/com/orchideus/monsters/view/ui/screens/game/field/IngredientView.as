/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.data.TimingVO;
import com.orchideus.monsters.model.game.Gem;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class IngredientView extends GemView {

    private var _view: Image;

    public function IngredientView(refs:CommonRefs, gem: Gem) {
        super(refs, gem);
    }

    override protected function initialize():void {
        _view = new Image(_refs.game.getTexture(_gem.type+".png"));
        _view.touchable = false;
        _view.x = int(CellView.tileWidth/2);
        _view.y = int(CellView.tileHeight/2);
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        addChild(_view);

        x = int(_gem.cell.x * CellView.tileWidth);
        y = int(_gem.cell.y * CellView.tileHeight);

        if (_gem.fall) {
            clipRect = new Rectangle(0, 0, CellView.tileWidth, CellView.tileHeight);
            innerFall();
        }

        _gem.addEventListener(Gem.UPDATE, handleUpdate);
        _gem.addEventListener(Gem.KILL, handleKill);
    }

    private function innerFall():void {
        _view.y -= CellView.tileHeight;
        Starling.juggler.tween(_view, TimingVO.fall, {y: _view.y+CellView.tileHeight, onComplete: handleFall});
    }

    private function handleUpdate(e: Event = null):void {
        var newX: int = _gem.cell.x * CellView.tileWidth;
        var newY: int = _gem.cell.y * CellView.tileHeight;
        if (e) {
            if (e.data) {
                Starling.juggler.tween(this, TimingVO.swap, {x: newX, y: newY});
            } else if (newY > y) {
                Starling.juggler.tween(this, TimingVO.fall+0.01, {x: newX, y: newY, onComplete: handleFall});
            }
        }
    }

    private function handleFall():void {
        if (clipRect) {
            clipRect = null;
        }
    }

    private function handleKill(e: Event):void {
        dispatchEventWith(KILL);

        if (_gem) {
            if (_gem.collect) {
                destroy();
            } else {
                Starling.juggler.tween(_view, TimingVO.kill, {scaleX: 0, scaleY: 0, onComplete: destroy});
            }
        }
    }

    override public function destroy():void {
        if (_view) {
            removeChild(_view, true);
            _view = null;
        }

        super.destroy();
    }
}
}
