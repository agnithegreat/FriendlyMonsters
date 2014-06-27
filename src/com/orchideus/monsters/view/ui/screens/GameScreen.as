/**
 * Created by agnither on 09.04.14.
 */
package com.orchideus.monsters.view.ui.screens {
import com.agnither.ui.AbstractView;
import com.agnither.ui.Screen;
import com.agnither.utils.CommonRefs;
import com.catalystapps.gaf.display.GAFMovieClip;
import com.catalystapps.gaf.event.SequenceEvent;
import com.orchideus.monsters.data.EffectVO;
import com.orchideus.monsters.data.TimingVO;
import com.orchideus.monsters.model.game.Block;
import com.orchideus.monsters.model.game.Cell;
import com.orchideus.monsters.model.game.Game;
import com.orchideus.monsters.model.game.Gem;
import com.orchideus.monsters.model.game.Ingredient;
import com.orchideus.monsters.view.ui.Animations;
import com.orchideus.monsters.view.ui.screens.game.field.BlockView;
import com.orchideus.monsters.view.ui.screens.game.field.CellUpperView;
import com.orchideus.monsters.view.ui.screens.game.field.CellView;
import com.orchideus.monsters.view.ui.screens.game.field.DecorView;
import com.orchideus.monsters.view.ui.screens.game.field.FieldConstructorView;
import com.orchideus.monsters.view.ui.screens.game.field.GemCounterView;
import com.orchideus.monsters.view.ui.screens.game.field.GemPhantomView;
import com.orchideus.monsters.view.ui.screens.game.field.GemView;
import com.orchideus.monsters.view.ui.screens.game.field.IceView;
import com.orchideus.monsters.view.ui.screens.game.field.IngredientView;
import com.orchideus.monsters.view.ui.screens.game.field.LeafView;
import com.orchideus.monsters.view.ui.screens.game.panels.GameCountersPanel;
import com.orchideus.monsters.view.ui.screens.game.panels.GameBonusesPanel;
import com.orchideus.monsters.view.ui.screens.game.panels.GameMenuPanel;
import com.orchideus.monsters.view.ui.screens.game.panels.GameMovesPanel;

import extensions.PDParticleSystem;

import flash.geom.Matrix;
import flash.geom.Point;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class GameScreen extends Screen {

    public static const ID: String = "GameScreen";

    public static const SELECT_CELL: String = "SELECT_CELL_GameScreen";

    private var _game: Game;

    private var _back: Sprite;

    private var _fieldContainer: Sprite;

    private var _fieldConstructor: FieldConstructorView;

    private var _cells: Sprite;
    private var _gems: Sprite;
    private var _counters: Sprite;
    private var _cellsUpper: Sprite;

    private var _effects: Sprite;

    private var _rollOver: CellView;

    private var _movesPanel: GameMovesPanel;
    private var _countersPanel: GameCountersPanel;
    private var _bonusesPanel: GameBonusesPanel;
    private var _menuPanel: GameMenuPanel;

    private var _animations: Sprite;

    public function GameScreen(refs:CommonRefs, game: Game) {
        _game = game;

        super(refs);
    }

    override protected function initialize():void {
        createFromConfig(_refs.guiConfig.game);

        _back = _links.back;

        _fieldContainer = _links.field;

        _fieldConstructor = new FieldConstructorView(_refs, _game);
        _fieldContainer.addChild(_fieldConstructor);

        _cells = new Sprite();
        _cells.addEventListener(TouchEvent.TOUCH, handleTouch);
        _fieldContainer.addChild(_cells);

        _gems = new Sprite();
        _fieldContainer.addChild(_gems);

        _counters = new Sprite();
        _fieldContainer.addChild(_counters);

        _cellsUpper = new Sprite();
        _fieldContainer.addChild(_cellsUpper);

        _effects = new Sprite();
        _fieldContainer.addChild(_effects);

        _movesPanel = new GameMovesPanel(_refs, _game);
        addChild(_movesPanel);

        _countersPanel = new GameCountersPanel(_refs, _game);
        addChild(_countersPanel);

        _bonusesPanel = new GameBonusesPanel(_refs, _game);
        addChild(_bonusesPanel);

        _menuPanel = new GameMenuPanel(_refs, _game);
        addChild(_menuPanel);

        _animations = new Sprite();
        addChild(_animations);

        _game.addEventListener(Game.INIT, handleInit);
        _game.addEventListener(Game.UPDATE, handleUpdate);
        _game.addEventListener(Game.EFFECT, handleEffect);
        _game.addEventListener(Game.CLEAR, handleClear);
    }

    private function handleInit(e: Event):void {
        _game.addEventListener(Game.NEW_GEM, handleNewGem);

        _back.addChild(new Image(_refs.backs.getTexture(_game.background)));

        for (var i:int = 0; i < _game.field.length; i++) {
            var cell: Cell = _game.field[i];
            if (cell.available) {
                var c:CellView = new CellView(_refs, cell);
                _cells.addChild(c);

                var cu: CellUpperView = new CellUpperView(_refs, cell);
                _cellsUpper.addChild(cu);
            }

            if (cell.gem) {
                var gem:AbstractView;

                if (cell.gem is Block) {
                    gem = new BlockView(_refs, cell.gem);
                    gem.addEventListener(GemView.KILL, handleGemKill);
                    _gems.addChild(gem);
                } else {
                    gem = new GemView(_refs, cell.gem);
                    gem.addEventListener(GemView.KILL, handleGemKill);
                    _gems.addChild(gem);

                    if (cell.gem.blocked) {
                        var ice: IceView = new IceView(_refs, cell.gem);
                        ice.addEventListener(GemView.KILL, handleGemKill);
                        _gems.addChild(ice);
                    }

                    var gc:GemCounterView = new GemCounterView(_refs, cell.gem);
                    gc.addEventListener(GemCounterView.COUNTER, handleGemCounter);
                    _counters.addChild(gc);
                }
            }
        }

        var l: int = _game.decors.length;
        for (i = 0; i < l; i++) {
            var decor: DecorView = new DecorView(_refs, _game.decors[i]);
            _cellsUpper.addChild(decor);
        }
    }

    private function handleUpdate(e: Event):void {

    }

    private function handleNewGem(e: Event):void {
        var gem:AbstractView;

        if (e.data is Ingredient) {
            gem = new IngredientView(_refs, e.data as Gem);
            gem.addEventListener(GemView.KILL, handleGemKill);
            _gems.addChild(gem);
        } else {
            gem = new GemView(_refs, e.data as Gem);
            gem.addEventListener(GemView.KILL, handleGemKill);
            _gems.addChild(gem);

            var gemCounter:GemCounterView = new GemCounterView(_refs, e.data as Gem);
            gemCounter.addEventListener(GemCounterView.COUNTER, handleGemCounter);
            _counters.addChild(gemCounter);
        }
    }

    private function handleGemKill(e: Event):void {
        var target: AbstractView = e.currentTarget as AbstractView;
        var gem: Gem = e.data as Gem;

        if (gem.collect) {
            var pos: Matrix = target.getTransformationMatrix(this);

            var phantom:GemPhantomView = new GemPhantomView(_refs, gem);
            _animations.addChild(phantom);
            phantom.x = pos.tx;
            phantom.y = pos.ty;

            var aim:Matrix = _countersPanel.getCounterPosition(gem.type, this);

            Starling.juggler.tween(phantom, 0.5, {x: aim.tx, y: aim.ty, onComplete: phantom.destroy});
            updatePanels(0.5);
        }
    }

    private function updatePanels(delay: Number):void {
        _countersPanel.delayedUpdate(delay);
        _movesPanel.delayedUpdate(delay);
    }

    private function handleEffect(e: Event):void {
        var effect: EffectVO = e.data.effect;
        var target: Object = e.data.target;

        var pos: Point = new Point();
        if (target is Cell) {
            var cell: Cell = target as Cell;
            pos.x = (cell.x+0.5) * CellView.tileWidth;
            pos.y = (cell.y+0.5) * CellView.tileHeight;
        } else {

        }

        if (effect.type == "particle") {
            var particle: PDParticleSystem = new PDParticleSystem(_refs.game.getXml(effect.path.replace(".pex", "")), _refs.game.getTexture(effect.name+".png"));
            particle.emitterX = pos.x;
            particle.emitterY = pos.y;
            particle.addEventListener(Event.COMPLETE, handleRemoveParticle);
            Starling.juggler.add(particle);
            _effects.addChild(particle);
            particle.start();
        } else if (effect.type == "animation") {
            var animation: GAFMovieClip = new GAFMovieClip(Animations.getAsset(effect.name, effect.name));
            animation.addEventListener(SequenceEvent.TYPE_SEQUENCE_END, handleRemoveAnimation);
            animation.touchable = false;
            animation.x = pos.x;
            animation.y = pos.y;
            animation.pivotX = int(animation.width/2);
            animation.pivotY = int(animation.height/2);
            animation.loop = false;
            animation.play();
            _effects.addChild(animation);
        }
    }
    private function handleRemoveParticle(e: Event):void {
        var particle: PDParticleSystem = e.currentTarget as PDParticleSystem;
        Starling.juggler.remove(particle);
        _effects.removeChild(particle, true);
    }
    private function handleRemoveAnimation(e: SequenceEvent):void {
        var animation: GAFMovieClip = e.currentTarget as GAFMovieClip;
        _effects.removeChild(animation, true);
    }

    private function handleGemCounter(e: Event):void {
        var cell: Cell = e.data as Cell;
        var dx: int = (cell.x+0.5) * CellView.tileWidth;
        var dy: int = (cell.y+0.5) * CellView.tileHeight;

        var target: GemCounterView = e.currentTarget as GemCounterView;
        var pos: Point = new Point(_fieldContainer.x+target.x+CellView.tileWidth/2, _fieldContainer.y+target.y+CellView.tileHeight/2);

        var animation: LeafView = new LeafView(_refs);
        _animations.addChild(animation);
        animation.x = _fieldContainer.x + dx;
        animation.y = _fieldContainer.y + dy;
        animation.rotation = Math.atan2(pos.y-animation.y, pos.x-animation.x);

        Starling.juggler.tween(animation, TimingVO.counter-0.1, {x: pos.x, y: pos.y});
        Starling.juggler.delayCall(animation.destroy, TimingVO.counter);
        Starling.juggler.delayCall(target.updateCounter, TimingVO.counter);
    }

    private function handleTouch(e: TouchEvent):void {
        var touch: Touch = e.getTouch(_cells);
        if (touch) {
            var test: DisplayObject = _cells.hitTest(touch.getLocation(_cells));
            if (test) {
                var cell: CellView = test.parent as CellView;
                if (cell) {
                    if (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED && _rollOver && _rollOver != cell) {
                        _rollOver = cell;
                        dispatchEventWith(SELECT_CELL, true, _rollOver.cell);

                        if (touch.phase != TouchPhase.BEGAN) {
                            _rollOver = null;
                        }
                    } else if (touch.phase == TouchPhase.ENDED) {
                        _rollOver = null;
                    }
                }
            }
        }
    }

    private function handleClear(e: Event):void {
        _game.removeEventListener(Game.NEW_GEM, handleNewGem);

        while (_back.numChildren>0) {
            _back.removeChildAt(0, true);
        }

        while (_cells.numChildren>0) {
            var cell: CellView = _cells.removeChildAt(0) as CellView;
            cell.destroy();
        }

        while (_cellsUpper.numChildren>0) {
            var cellUpper: AbstractView = _cellsUpper.removeChildAt(0) as AbstractView;
            cellUpper.destroy();
        }

        while (_gems.numChildren>0) {
            var gem: AbstractView = _gems.getChildAt(0) as AbstractView;
            gem.destroy();
        }

        while (_counters.numChildren>0) {
            var gemCounter: GemCounterView = _counters.getChildAt(0) as GemCounterView;
            gemCounter.destroy();
        }

        _rollOver = null;
    }
}
}
