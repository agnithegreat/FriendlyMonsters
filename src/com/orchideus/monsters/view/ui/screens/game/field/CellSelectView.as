/**
 * Created by agnither on 27.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

import starling.core.Starling;
import starling.display.Image;

public class CellSelectView extends AbstractView {

    private static var delay: Number = 0.5;
    private static var innerGap: int = 3;
    private static var outerGap: int = 0;

    private var _lu: Image;
    private var _ru: Image;
    private var _rd: Image;
    private var _ld: Image;

    private var _showId: int = 0;

    public function CellSelectView(refs:CommonRefs) {
        super(refs);
    }

    override protected function initialize():void {
        touchable = false;

        _lu = new Image(_refs.game.getTexture("cell_corner.png"));
        addChild(_lu);

        _ru = new Image(_refs.game.getTexture("cell_corner.png"));
        _ru.scaleX = -1;
        addChild(_ru);

        _rd = new Image(_refs.game.getTexture("cell_corner.png"));
        _rd.scaleX = -1;
        _rd.scaleY = -1;
        addChild(_rd);

        _ld = new Image(_refs.game.getTexture("cell_corner.png"));
        _ld.scaleY = -1;
        addChild(_ld);
    }

    public function show():void {
        if (visible) {
            return;
        }
        _showId++;
        visible = true;
        zoomIn(_showId);
    }

    private function zoomIn(showId: int):void {
        if (!visible || showId!=_showId) {
            return;
        }

        _lu.x = outerGap;
        _lu.y = outerGap;
        Starling.juggler.tween(_lu, delay, {x: innerGap, y: innerGap});

        _ru.x = CellView.tileWidth-outerGap;
        _ru.y = outerGap;
        Starling.juggler.tween(_ru, delay, {x: CellView.tileWidth-innerGap, y: innerGap});

        _rd.x = CellView.tileWidth-outerGap;
        _rd.y = CellView.tileHeight-outerGap;
        Starling.juggler.tween(_rd, delay, {x: CellView.tileWidth-innerGap, y: CellView.tileHeight-innerGap});

        _ld.x = outerGap;
        _ld.y = CellView.tileHeight-outerGap;
        Starling.juggler.tween(_ld, delay, {x: innerGap, y: CellView.tileHeight-innerGap});

        Starling.juggler.delayCall(zoomOut, delay, _showId);
    }

    private function zoomOut(showId: int):void {
        if (!visible || showId!=_showId) {
            return;
        }

        Starling.juggler.tween(_lu, delay, {x: outerGap, y: outerGap});
        Starling.juggler.tween(_ru, delay, {x: CellView.tileWidth-outerGap, y: outerGap});
        Starling.juggler.tween(_rd, delay, {x: CellView.tileWidth-outerGap, y: CellView.tileHeight-outerGap});
        Starling.juggler.tween(_ld, delay, {x: outerGap, y: CellView.tileHeight-outerGap});

        Starling.juggler.delayCall(zoomIn, delay, _showId);
    }
}
}
