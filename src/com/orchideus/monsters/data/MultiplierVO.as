/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class MultiplierVO {

    public static var MULTIPLIERS: Dictionary = new Dictionary();

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var multiplier: MultiplierVO = new MultiplierVO();
            multiplier.id = row.id;
            multiplier.amount = row.amount;
            multiplier.multiplier = row.multiplier;
            MULTIPLIERS[multiplier.amount] = multiplier;
        }
    }

    public var id: int;
    public var amount: int;
    public var multiplier: Number;
}
}
