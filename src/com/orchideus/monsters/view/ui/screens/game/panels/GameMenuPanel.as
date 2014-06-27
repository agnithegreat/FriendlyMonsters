/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Game;

import starling.core.Starling;
import starling.display.Button;
import starling.events.Event;

public class GameMenuPanel extends AbstractView {

    public static const MENU: String = "menu_GameMenuPanel";

    private var _game: Game;

    private var _menu: Button;

    public function GameMenuPanel(refs:CommonRefs, game: Game) {
        _game = game;

        super(refs);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.gameMenuPanel);

        _menu = _links.menu_btn;
        _menu.addEventListener(Event.TRIGGERED, handleTriggered);

        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.CLEAR, handleClear);

        x = stage.stageWidth;
        y = stage.stageHeight;

        visible = false;
    }

    private function handleTriggered(e: Event):void {
        dispatchEventWith(MENU, true);
    }

    private function handleInit(e: Event):void {
        Starling.juggler.removeTweens(this);
        visible = true;
    }

    private function handleClear(e: Event):void {
        Starling.juggler.removeTweens(this);
        hide();
    }

    override public function destroy():void {
        _game.removeEventListener(Game.INIT, handleInit);
        _game.removeEventListener(Game.CLEAR, handleClear);
        _game = null;

        super.destroy();
    }
}
}
