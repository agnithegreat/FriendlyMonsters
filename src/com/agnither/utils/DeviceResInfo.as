/**
 * Created by agnither on 29.01.14.
 */
package com.agnither.utils {
import flash.display.Stage;

public class DeviceResInfo {

    public static function getInfo(stage: Stage):DeviceResInfo {
        var info: DeviceResInfo = new DeviceResInfo();
        if (stage.stageWidth==2048) {
            info.art = 2048;
            info.scaleFactor = 2;
            info.font = 2048;
    //        info.frameRate = 60;
        } else if (stage.stageWidth==1024) {
            info.art = 1024;
            info.scaleFactor = 1;
            info.font = 1024;
            info.frameRate = 60;
        }
        return info;
    }

    public var art: int = 1024;
    public var scaleFactor: Number = 1;
    public var font: int = 1024;
    public var frameRate: int = 60;
}
}
