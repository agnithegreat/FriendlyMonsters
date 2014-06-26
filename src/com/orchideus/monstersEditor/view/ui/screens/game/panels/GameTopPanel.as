/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

import starling.display.Button;
import starling.events.Event;
import starling.textures.Texture;

public class GameTopPanel extends AbstractView {

    public static const PLAY: String = "play_GameTopPanel";
    public static const STOP: String = "stop_GameTopPanel";
    public static const BACKGROUND: String = "background_GameTopPanel";

    private var _play: Button;
    private var _stop: Button;
    private var _backs: Button;

    public function GameTopPanel(refs:CommonRefs) {
        super(refs);
    }

    override protected function initialize():void {
        _play = new Button(Texture.fromColor(100, 30, 0xFF999999), "PLAY");
        _play.addEventListener(Event.TRIGGERED, handlePlay);
        _play.y = 30;
        addChild(_play);

        _stop = new Button(Texture.fromColor(100, 30, 0xFF999999), "STOP");
        _stop.addEventListener(Event.TRIGGERED, handleStop);
        _stop.x = 110;
        _stop.y = 30;
        addChild(_stop);

        _backs = new Button(Texture.fromColor(100, 30, 0xFF999999), "BACKGROUND");
        _backs.addEventListener(Event.TRIGGERED, handleBackground);
        _backs.x = 220;
        _backs.y = 30;
        addChild(_backs);
    }

    private function handlePlay(e: Event):void {
        dispatchEventWith(PLAY, true);
    }

    private function handleStop(e: Event):void {
        dispatchEventWith(STOP, true);
    }

    private function handleBackground(e: Event):void {
        dispatchEventWith(BACKGROUND, true);
    }
}
}
