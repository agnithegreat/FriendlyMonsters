/**
 * Created by agnither on 11.04.14.
 */
package com.agnither.utils {
public class FormatUtils {

    public static function convertToHHMMSS($seconds:Number):String {
        var s:Number = $seconds % 60;
        var m:Number = Math.floor(($seconds % 3600 ) / 60);
        var h:Number = Math.floor($seconds / (60 * 60));

        var hourStr:String = (h == 0) ? "" : doubleDigitFormat(h) + ":";
        var minuteStr:String = doubleDigitFormat(m) + ":";
        var secondsStr:String = doubleDigitFormat(s);

        return hourStr + minuteStr + secondsStr;
    }

    private static function doubleDigitFormat($num:uint):String {
        if ($num < 10) {
            return ("0" + $num);
        }
        return String($num);
    }
}
}
