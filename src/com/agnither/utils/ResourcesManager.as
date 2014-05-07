/**
 * Created by agnither on 30.01.14.
 */
package com.agnither.utils {
import starling.events.EventDispatcher;
import starling.utils.AssetManager;

public class ResourcesManager extends EventDispatcher {

    public static const PROGRESS: String = "progress";
    public static const COMPLETE_PHASE: String = "complete_phase";
    public static const COMPLETE: String = "complete";

    private var _info: DeviceResInfo;

    private var _preloader: AssetManager;
    public function get preloader():AssetManager {
        return _preloader;
    }

    private var _main: AssetManager;
    public function get main():AssetManager {
        return _main;
    }

    private var _gui: AssetManager;
    public function get gui():AssetManager {
        return _gui;
    }

    private var _queue: Array = [];
    private var _loaded: int;
    private var _loading: int;

    private var _current: AssetManager;

    public function ResourcesManager(info: DeviceResInfo) {
        _info = info;

        _preloader = new AssetManager(_info.scaleFactor);
        _main = new AssetManager(_info.scaleFactor);
        _gui = new AssetManager(_info.scaleFactor);

        _loaded = 0;
        _loading = 0;
    }

    public function loadPreloader():void {
        _loading++;

        _preloader.enqueue(
            "textures/"+_info.art+"/preloader/preloader.png",
            "textures/"+_info.art+"/preloader/preloader.xml"
        );
        _queue.push(_preloader);
    }

    public function removePreloader():void {
        _preloader.purge();
        _preloader.dispose();
    }

    public function loadMain():void {
        _loading++;

        _main.enqueue(
            "config/config.json",
            "levels/1.json"
        );
        _queue.push(_main);
    }

    public function loadGUI():void {
        _loading++;

        for (var i:int = 0; i < Fonts.fonts.length; i++) {
            _gui.enqueue(
                "textures/"+_info.font+"/fonts/"+Fonts.fonts[i]+".png",
                "textures/"+_info.font+"/fonts/"+Fonts.fonts[i]+".xml"
            );
        }
        _gui.enqueue(
            "textures/"+_info.art+"/gui/gui.png",
            "textures/"+_info.art+"/gui/gui.xml",
            "animations/Charry3.zip"
        );
        _queue.push(_gui);

    }

    public function load():void {
        if (_current) {
            return;
        }

        _current = _queue.shift();
        if (_current) {
            _current.loadQueue(handleProgress);
        } else {
            dispatchEventWith(COMPLETE_PHASE);
            dispatchEventWith(COMPLETE);
        }
    }

    private function handleProgress(value: Number):void {
        dispatchEventWith(PROGRESS, false, (_loaded+value)/_loading);

        if (value == 1) {
            _loaded++;
            _current = null;
            dispatchEventWith(COMPLETE_PHASE);

            if (_queue.length>0) {
                load();
            } else {
                _loaded = 0;
                _loading = 0;
                dispatchEventWith(COMPLETE);
            }
        }
    }
}
}
