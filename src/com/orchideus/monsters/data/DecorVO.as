/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class DecorVO {

    public static var DECORS: Dictionary = new Dictionary();

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var decor: DecorVO = new DecorVO();
            decor.id = row.id;
            decor.name = row.name;
            decor.size = row.size.split(",");

            DECORS[decor.name] = decor;
        }
    }

    public var id: int;
    public var name: String;
    public var size: Array;
}
}
