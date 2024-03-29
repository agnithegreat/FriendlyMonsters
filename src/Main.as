package {
import com.orchideus.monsters.App;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import starling.core.Starling;

[SWF(frameRate="60", width="1024", height="768", backgroundColor="0")]
public class Main extends Sprite {

    private var _starling: Starling;

    public function Main() {
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    private function handleAddedToStage(event: Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);

        var ios: Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
        var android: Boolean = Capabilities.manufacturer.indexOf("Android") != -1;
        var mobile: Boolean = ios || android;
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = !ios;

        _starling = new Starling(App, stage, null, null, "auto", "auto");
        _starling.antiAliasing = 0;
        _starling.showStats = true;
        _starling.simulateMultitouch = false;
        _starling.enableErrorChecking = Capabilities.isDebugger;
        _starling.start();

        NativeApplication.nativeApplication.addEventListener(
            Event.ACTIVATE, function (e:*):void {
            }
        );

        NativeApplication.nativeApplication.addEventListener(
            Event.DEACTIVATE, function (e:*):void {
            }
        );
    }
}
}
