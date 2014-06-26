/**
 * Created by agnither on 27.02.14.
 */
package com.orchideus.monsters.view.ui {
import com.agnither.ui.Popup;
import com.agnither.ui.Screen;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.GameController;
import com.orchideus.monsters.view.ui.popups.lose.LosePopup;
import com.orchideus.monsters.view.ui.popups.WinPopup;
import com.orchideus.monsters.view.ui.screens.GameScreen;
import com.orchideus.monsters.view.ui.screens.MainScreen;

import flash.utils.Dictionary;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class UI extends Screen {

    public static var SCREENS: Dictionary = new Dictionary();
    public static var POPUPS: Dictionary = new Dictionary();

    private var _controller: GameController;

    private var _currentScreen: Screen;
    private var _currentPopup: Popup;
    public function get currentPopup():Popup {
        return _currentPopup;
    }

    private var _container: Sprite;

    private var _darkness: Quad;

    public function UI(refs:CommonRefs, controller: GameController) {
        _controller = controller;

        super(refs);
    }

    override protected function initialize():void {
        SCREENS[MainScreen.ID] = new MainScreen(_refs, _controller);
        SCREENS[GameScreen.ID] = new GameScreen(_refs, _controller.game);

        POPUPS[WinPopup.ID] = new WinPopup(_refs);
        POPUPS[LosePopup.ID] = new LosePopup(_refs);

        _container = new Sprite();
        addChild(_container);

        _darkness = new Quad(stage.stageWidth, stage.stageHeight, 0, false);
        _darkness.alpha = 0.8;
    }

    public function showScreen(id: String):void {
        if (_currentScreen == SCREENS[id]) {
            return;
        }

        _currentScreen = SCREENS[id];
        if (_currentScreen) {
            _container.addChild(_currentScreen);
        }
    }
    public function hideScreen():void {
        if (_currentScreen) {
            _container.removeChild(_currentScreen);
            _currentScreen = null;
        }
    }

    public function showPopup(id: String, data: Object = null):void {
        if (_currentPopup == POPUPS[id]) {
            return;
        }

        hidePopup();

        _currentPopup = POPUPS[id];
        if (_currentPopup) {
            _currentPopup.data = data;
            if (_currentPopup.darkened) {
                _container.addChild(_darkness);
            }
            _currentPopup.addEventListener(Popup.CLOSE, hidePopup);
            _container.addChild(_currentPopup);
        }
    }
    public function hidePopup(e: Event = null):void {
        if (_currentPopup) {
            if (_currentPopup.darkened) {
                _container.removeChild(_darkness);
            }
            _currentPopup.removeEventListener(Popup.CLOSE, hidePopup);
            _currentPopup.close();
            _currentPopup = null;
        }
    }

    override public function destroy():void {
        super.destroy();

        _controller = null;

        hideScreen();

        for (var index: String in SCREENS) {
            var s: Screen = SCREENS[index];
            s.destroy();
            s.removeFromParent(true);
            delete SCREENS[index];
        }
    }
}
}
