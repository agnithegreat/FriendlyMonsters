/**
 * Created by agnither on 26.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.native {
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.FocusEvent;

import starling.core.Starling;
import starling.events.EventDispatcher;

public class NativeBlock {

    public static const MOVES_CHANGED: String = "moves_changed_NativeBlock";
    public static const FRUITS_CHANGED: String = "fruits_changed_NativeBlock";
    public static const STARS_CHANGED: String = "stars_changed_NativeBlock";
    public static const COUNTERS_CHANGED: String = "counters_changed_NativeBlock";
    public static const INGREDIENTS_CHANGED: String = "ingredients_changed_NativeBlock";
    public static const BLOCKS_CHANGED: String = "blocks_changed_NativeBlock";
    public static const PROBABILITY_CHANGED: String = "probability_changed_NativeBlock";

    private var _dispatcher: EventDispatcher;

    private var _container: Sprite;
    public function set visible(value: Boolean):void {
        _container.visible = value;
    }
    public function get visible():Boolean {
        return _container.visible;
    }

    private var _panel: NativePanel;

    public function get moves():int {
        return int(_panel.moves.text);
    }

    public function get fruits():int {
        return int(_panel.fruits.text);
    }

    public function get stars():Array {
        return [int(_panel.star1.text), int(_panel.star2.text), int(_panel.star3.text)];
    }

    public function get counters():Array {
        var counters: Array = [];
        for (var i:int = 1; i <= 3; i++) {
            var task: MovieClip = _panel.getChildByName("task"+i) as MovieClip;
            var type: int = int(task.type.text);
            var amount: int = int(task.amount.text);
            if (type && amount) {
                counters.push({"id": type, "amount": amount});
            }
        }
        return counters;
    }

    public function get ingredients():Array {
        var ingredients: Array = [];
        for (var i:int = 1; i <= 3; i++) {
            var ingredient: MovieClip = _panel.getChildByName("ingredient"+i) as MovieClip;
            var type: int = int(ingredient.type.text);
            var amount: int = int(ingredient.amount.text);
            if (type && amount) {
                ingredients.push({"id": type, "amount": amount});
            }
        }
        return ingredients;
    }

    public function get blocks():Array {
        var blocks: Array = [];
        for (var i:int = 1; i <= 3; i++) {
            var block: MovieClip = _panel.getChildByName("block"+i) as MovieClip;
            var type: int = int(block.type.text);
            var amount: int = int(block.amount.text);
            if (type && amount) {
                blocks.push({"id": type, "amount": amount});
            }
        }
        return blocks;
    }

    public function get probabilities():Array {
        var probabilities: Array = [];
        for (var i:int = 1; i <= 3; i++) {
            var prob: MovieClip = _panel.getChildByName("probability"+i) as MovieClip;
            probabilities.push(int(prob.value.text));
        }
        return probabilities;
    }

    public function NativeBlock(dispatcher: EventDispatcher) {
        _dispatcher = dispatcher;

        _container = new Sprite();
        Starling.current.nativeOverlay.stage.addChild(_container);

        _panel = new NativePanel();

        _panel.moves.addEventListener(FocusEvent.FOCUS_OUT, handleMovesChanged);
        _panel.fruits.addEventListener(FocusEvent.FOCUS_OUT, handleFruitsChanged);

        _panel.star1.addEventListener(FocusEvent.FOCUS_OUT, handleStarsChanged);
        _panel.star2.addEventListener(FocusEvent.FOCUS_OUT, handleStarsChanged);
        _panel.star3.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);

        _panel.task1.type.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);
        _panel.task2.type.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);
        _panel.task3.type.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);
        _panel.task1.amount.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);
        _panel.task2.amount.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);
        _panel.task3.amount.addEventListener(FocusEvent.FOCUS_OUT, handleCountersChanged);

        _panel.ingredient1.type.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);
        _panel.ingredient2.type.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);
        _panel.ingredient3.type.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);
        _panel.ingredient1.amount.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);
        _panel.ingredient2.amount.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);
        _panel.ingredient3.amount.addEventListener(FocusEvent.FOCUS_OUT, handleIngredientsChanged);

        _panel.block1.type.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);
        _panel.block2.type.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);
        _panel.block3.type.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);
        _panel.block1.amount.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);
        _panel.block2.amount.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);
        _panel.block3.amount.addEventListener(FocusEvent.FOCUS_OUT, handleBlocksChanged);

        _panel.probability1.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);
        _panel.probability2.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);
        _panel.probability3.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);
        _panel.probability4.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);
        _panel.probability5.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);
        _panel.probability6.value.addEventListener(FocusEvent.FOCUS_OUT, handleProbabilityChanged);

        _panel.x = 1024;
        _container.addChild(_panel);
    }

    public function setData(moves: int, fruits: int, stars: Array, counters: Array, ingredients: Array, blocks: Array, probabilities: Array):void {
        _panel.moves.text = String(moves);
        _panel.fruits.text = String(fruits);

        _panel.star1.text = String(stars[0]);
        _panel.star2.text = String(stars[1]);
        _panel.star3.text = String(stars[2]);

        _panel.task1.type.text   = counters.length>0 ? String(counters[0].id)     : "0";
        _panel.task1.amount.text = counters.length>0 ? String(counters[0].amount) : "0";
        _panel.task2.type.text   = counters.length>1 ? String(counters[1].id)     : "0";
        _panel.task2.amount.text = counters.length>1 ? String(counters[1].amount) : "0";
        _panel.task3.type.text   = counters.length>2 ? String(counters[2].id)     : "0";
        _panel.task3.amount.text = counters.length>2 ? String(counters[2].amount) : "0";

        _panel.ingredient1.type.text   = ingredients.length>0 ? String(ingredients[0].id)     : "0";
        _panel.ingredient1.amount.text = ingredients.length>0 ? String(ingredients[0].amount) : "0";
        _panel.ingredient2.type.text   = ingredients.length>1 ? String(ingredients[1].id)     : "0";
        _panel.ingredient2.amount.text = ingredients.length>1 ? String(ingredients[1].amount) : "0";
        _panel.ingredient3.type.text   = ingredients.length>2 ? String(ingredients[2].id)     : "0";
        _panel.ingredient3.amount.text = ingredients.length>2 ? String(ingredients[2].amount) : "0";

        _panel.block1.type.text   = blocks.length>0 ? String(blocks[0].id)     : "0";
        _panel.block1.amount.text = blocks.length>0 ? String(blocks[0].amount) : "0";
        _panel.block2.type.text   = blocks.length>1 ? String(blocks[1].id)     : "0";
        _panel.block2.amount.text = blocks.length>1 ? String(blocks[1].amount) : "0";
        _panel.block3.type.text   = blocks.length>2 ? String(blocks[2].id)     : "0";
        _panel.block3.amount.text = blocks.length>2 ? String(blocks[2].amount) : "0";

        _panel.probability1.caption.text = probabilities[0].type+" probablity:";
        _panel.probability1.value.text   = probabilities[0].probability;
        _panel.probability2.caption.text = probabilities[1].type+" probablity:";
        _panel.probability2.value.text   = probabilities[1].probability;
        _panel.probability3.caption.text = probabilities[2].type+" probablity:";
        _panel.probability3.value.text   = probabilities[2].probability;
        _panel.probability4.caption.text = probabilities[3].type+" probablity:";
        _panel.probability4.value.text   = probabilities[3].probability;
        _panel.probability5.caption.text = probabilities[4].type+" probablity:";
        _panel.probability5.value.text   = probabilities[4].probability;
        _panel.probability6.caption.text = probabilities[5].type+" probablity:";
        _panel.probability6.value.text   = probabilities[5].probability;
    }

    private function handleMovesChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(MOVES_CHANGED, true, moves);
    }

    private function handleFruitsChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(FRUITS_CHANGED, true, fruits);
    }

    private function handleStarsChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(STARS_CHANGED, true, stars);
    }

    private function handleCountersChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(COUNTERS_CHANGED, true, counters);
    }

    private function handleIngredientsChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(INGREDIENTS_CHANGED, true, ingredients);
    }

    private function handleBlocksChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(BLOCKS_CHANGED, true, blocks);
    }

    private function handleProbabilityChanged(e: FocusEvent):void {
        _dispatcher.dispatchEventWith(PROBABILITY_CHANGED, true, probabilities);
    }
}
}
