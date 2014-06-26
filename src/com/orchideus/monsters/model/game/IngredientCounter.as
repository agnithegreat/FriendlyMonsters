/**
 * Created by agnither on 27.05.14.
 */
package com.orchideus.monsters.model.game {
public class IngredientCounter {

    private var _id: int;

    private var _amount: int;

    public function IngredientCounter(data: Object) {
        _id = data.id;
        _amount = data.amount;
    }

    public function release():Ingredient {
        if (_amount>0) {
            _amount--;
            return new Ingredient(_id);
        }
        return null;
    }
}
}
