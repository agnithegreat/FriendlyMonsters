/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.data.LevelVO;
import com.orchideus.monsters.data.LevelsStorage;

import flash.geom.Rectangle;

import starling.display.Button;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

public class GameLeftPanel extends AbstractView {

    private static var amount: int = 10;

    private var _levels: LevelsStorage;

    private var _list: Array;
    public function get pages():int {
        return Math.ceil(_list.length/amount);
    }

    private var _plus: LevelView;

    private var _container: Sprite;
    private var _containerInner: Sprite;
    private var _page: int;

    private var _up: Button;
    private var _down: Button;

    public function GameLeftPanel(refs:CommonRefs, levels: LevelsStorage) {
        _levels = levels;
        _levels.addEventListener(LevelsStorage.LEVEL_ADDED, handleLevelAdded);
        _levels.addEventListener(LevelsStorage.LEVEL_SELECTED, handleLevelSelected);

        super(refs);
    }

    override protected function initialize():void {
        _list = [];

        _container = new Sprite();
        _container.clipRect = new Rectangle(0,0,80,amount*50);
        _container.y = 100;
        addChild(_container);

        _containerInner = new Sprite();
        _container.addChild(_containerInner);

        for (var i:int = 0; i <= _levels.length; i++) {
            var level: LevelView = new LevelView(_refs, _levels.levels[i+1]);
            level.y = 50 * i;
            _containerInner.addChild(level);
            _list.push(level);
        }
        _plus = level;

        _up = new Button(Texture.fromColor(50, 50, 0xFF999999), "^");
        _up.addEventListener(Event.TRIGGERED, handleUp);
        _up.x = 15;
        _up.y = 50;
        addChild(_up);

        _down = new Button(Texture.fromColor(50, 50, 0xFF999999), "v");
        _down.addEventListener(Event.TRIGGERED, handleDown);
        _down.x = 15;
        _down.y = 600;
        addChild(_down);

        _page = 0;
    }

    private function handleLevelAdded(e: Event):void {
        var level: LevelView = new LevelView(_refs, e.data as LevelVO);
        level.y = _plus.y;
        _containerInner.addChild(level);

        _list.pop();
        _list.push(level);
        _list.push(_plus);

        _plus.y += 50;
    }

    private function handleLevelSelected(e: Event):void {
        var l: int = _list.length;
        for (var i:int = 0; i < l; i++) {
            _list[i].select(e.data as LevelVO);
        }
    }

    private function handleUp(e: Event):void {
        _page = Math.max(0, _page-1);
        _containerInner.pivotY = _page * amount*50;
    }

    private function handleDown(e: Event):void {
        _page = Math.min(pages-1, _page+1);
        _containerInner.pivotY = _page * amount*50;
    }
}
}
