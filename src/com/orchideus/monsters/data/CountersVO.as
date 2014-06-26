/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {

public class CountersVO {

    public static var remove_5: int;
    public static var remove_corner: int;
    public static var remove_4: int;
    public static var remove_3_move: int;
    public static var remove_3: int;

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            CountersVO[row.name] = row.counter;
        }
    }
}
}
