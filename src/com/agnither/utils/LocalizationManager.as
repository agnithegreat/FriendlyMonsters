/**
 * Created with IntelliJ IDEA.
 * User: agnithegreat
 * Date: 12.06.13
 * Time: 9:50
 * To change this template use File | Settings | File Templates.
 */
package com.agnither.utils {
import flash.utils.Dictionary;

public class LocalizationManager {

    public static var localesAvailable: Array = ["ru", "en"];

    private static var _locale: String;

    private static var _strings: Dictionary = new Dictionary();

    public static function init(locale: String):void {
        _locale = locale;
    }

    public static function parse(data: Object):void {
        for (var key:String in data) {
            var l: int = data[key].length;
            for (var i:int = 0; i < l; i++) {
                var row: Object = data[key][i];
                _strings[row.id] = row;
            }
        }
    }

    public static function getString(id: String, replace: Object = null):String {
        var str: String = _strings[id] ? _strings[id][_locale] : "";

        if (replace) {
            for (var repl: String in replace) {
                str = str.replace("["+repl+"]", replace[repl]);
            }
        }

        return str;
    }
}
}
