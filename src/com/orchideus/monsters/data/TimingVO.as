/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {

public class TimingVO {

    public static var feedback: Number;
    public static var end_game: Number;
    public static var fall: Number;
    public static var swap: Number;
    public static var counter: Number;
    public static var kill: Number;
    public static var hint: Number;
    public static var idle_min: Number;
    public static var idle_max: Number;

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            TimingVO[row.name] = row.time;
        }
    }
}
}
