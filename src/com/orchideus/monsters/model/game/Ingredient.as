/**
 * Created by agnither on 27.05.14.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.IngredientVO;

public class Ingredient extends Gem {

    private var _ingredient: IngredientVO;
    override public function get type():String {
        return _ingredient.name;
    }

    override public function get points():int {
        return 0;
//        return _ingredient.points;
    }

    override public function get matchable():Boolean {
        return false;
    }

    override public function get allowShuffle():Boolean {
        return false;
    }

    public function Ingredient(id:int) {
        _ingredient = IngredientVO.INGREDIENTS[id];
        super(id, true, true, true);
    }
}
}
