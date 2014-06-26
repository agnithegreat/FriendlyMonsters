/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.model.game {
import starling.events.EventDispatcher;

public class IngredientsList extends EventDispatcher {

    private var _ingredients: Vector.<IngredientCounter>;
    public function get ingredients():Vector.<IngredientCounter> {
        return _ingredients;
    }

    private var _targetFruits: int;
    private var _fruits: int;

    public function IngredientsList() {
        _ingredients = new <IngredientCounter>[];
    }

    public function init(fruits: int):void {
        _targetFruits = fruits;
        _fruits = 0;
    }

    public function add(data: Object):void {
        _ingredients.push(new IngredientCounter(data));
    }

    public function addFruits(value: int):void {
        _fruits += value;
    }

    public function releaseIngredient():Ingredient {
        if (_targetFruits>0 && _fruits >= _targetFruits) {
            for (var i:int = 0; i < _ingredients.length; i++) {
                var ingredient:Ingredient = _ingredients[i].release();
                if (ingredient) {
                    _fruits = 0;
                    return ingredient;
                }
            }
        }
        return null;
    }

    public function clear():void {
        _ingredients.length = 0;
    }
}
}
