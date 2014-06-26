/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.panels {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.model.game.Game;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class GameMovesPanel extends AbstractView {

    private var _game: Game;

    private var _progress: Sprite;
    private var _progressWidth: int;
    private var _progressValue: Number;

    private var _star1: Image;
    private var _star2: Image;
    private var _star3: Image;

    private var _movesSmall: TextField;
    private var _moves: TextField;

    private var _stars: int;

    private var _score: TextField;

    public function GameMovesPanel(refs:CommonRefs, game: Game) {
        _game = game;

        super(refs);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.gameMovesPanel);

        _progress = _links.progress;
        _progressWidth = _progress.width;
        _progress.clipRect = _progress.getBounds(_progress);

        _star1 = _links.star1.getChildAt(0) as Image;
        _star2 = _links.star2.getChildAt(0) as Image;
        _star3 = _links.star3.getChildAt(0) as Image;

        _moves = _links.moves_tf;

        _movesSmall = _links.moves_small_tf;

        _score = _links.score_tf;
        _score.text = "";

        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.UPDATE, handleUpdate);
        _game.addEventListener(Game.CLEAR, handleClear);

        Starling.juggler.removeTweens(this);
        visible = false;
    }

    private function handleInit(e: Event):void {
        _stars = _game.stars;

        _star1.alpha = 0;
        _star2.alpha = 0;
        _star3.alpha = 0;

        progressValue = 0;

        _score.text = "0";

        visible = true;
    }

    private function handleUpdate(e: Event):void {
        _moves.text = String(_game.moves);
        _score.text = String(_game.score);
    }

    public function delayedUpdate(delay: Number):void {
        Starling.juggler.delayCall(update, delay, _game.progress);
    }

    private function update(progress: int):void {
        var conditions: Array = _game.conditions;

        var percent: Number;
        if (progress <= conditions[0]) {
            percent = 0.25 * progress/conditions[0];
        } else if (progress <= conditions[1]) {
            percent = 0.25 + 0.25 * (progress - conditions[0]) / (conditions[1] - conditions[0]);
        } else if (progress <= conditions[2]) {
            percent = 0.5 + 0.25 * (progress - conditions[1]) / (conditions[2] - conditions[1]);
        } else {
            percent = 0.75 + 0.25 * (progress - conditions[2]) / (conditions[2] - conditions[1]);
        }
        Starling.juggler.tween(this, 0.2, {"progressValue": percent});
    }

    public function set progressValue(value: Number):void {
        _progressValue = value;
        _progress.clipRect.width = _progressValue * _progressWidth;
        updateStars(_progressValue * 4);
    }

    public function get progressValue():Number {
        return _progressValue;
    }

    private function updateStars(stars: int):void {
        if (_stars<1 && stars>=1) {
            Starling.juggler.tween(_star1, 0.2, {"alpha": 1});
        }
        if (_stars<2 && stars>=2) {
            Starling.juggler.tween(_star2, 0.2, {"alpha": 1});
        }
        if (_stars<3 && stars>=3) {
            Starling.juggler.tween(_star3, 0.2, {"alpha": 1});
        }
        _stars = stars;
    }

    private function handleClear(e: Event):void {
        _score.text = "";

        Starling.juggler.removeTweens(this);
        hide();
    }

    override public function destroy():void {
        _game.removeEventListener(Game.INIT, handleInit);
        _game.removeEventListener(Game.UPDATE, handleUpdate);
        _game.removeEventListener(Game.CLEAR, handleClear);
        _game = null;

        super.destroy();
    }
}
}
