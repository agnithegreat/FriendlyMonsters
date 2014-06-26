/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class MultiplierVO {

    private static var MULTIPLIERS: Dictionary = new Dictionary();
    private static var count: int = 0;

    public static function getMultiplier(value: int):MultiplierVO {
        return value>count ? MULTIPLIERS[count] : MULTIPLIERS[value];
    }

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var multiplier: MultiplierVO = new MultiplierVO();
            multiplier.id = row.id;
            multiplier.amount = row.amount;
            multiplier.multiplier = row.multiplier;
            MULTIPLIERS[multiplier.amount] = multiplier;

            count++;
        }
    }

    public var id: int;
    public var amount: int;
    public var multiplier: Number;
}
}
