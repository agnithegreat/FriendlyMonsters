/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class IngredientVO {

    public static var INGREDIENTS: Dictionary = new Dictionary();

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var ingredient: IngredientVO = new IngredientVO();
            ingredient.id = row.id;
            ingredient.name = row.name;

            INGREDIENTS[ingredient.id] = ingredient;
            INGREDIENTS[ingredient.name] = ingredient;
        }
    }

    public var id: int;
    public var name: String;
}
}
