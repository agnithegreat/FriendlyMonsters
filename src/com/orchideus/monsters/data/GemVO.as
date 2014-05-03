/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class GemVO {

    public static var GEMS: Dictionary = new Dictionary();
    public static var amount: int = 0;

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var gem: GemVO = new GemVO();
            gem.id = row.id;
            gem.type = row.type;
            gem.points = row.points;
            GEMS[gem.id] = gem;
            GEMS[gem.type] = gem;
            amount++;
        }
    }

    public var id: int;
    public var type: String;
    public var points: int;
}
}
