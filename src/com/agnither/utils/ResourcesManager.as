/**
 * Created by agnither on 30.01.14.
 */
package com.agnither.utils {
import flash.filesystem.File;

import starling.events.EventDispatcher;
import starling.utils.AssetManager;

public class ResourcesManager extends EventDispatcher {

    public static const PROGRESS: String = "progress";
    public static const COMPLETE_PHASE: String = "complete_phase";
    public static const COMPLETE: String = "complete";

    private var _info: DeviceResInfo;
    public function get frameRate():int {
        return _info.frameRate;
    }

    private var _preloader: AssetManager;
    public function get preloader():AssetManager {
        return _preloader;
    }

    private var _main: AssetManager;
    public function get main():AssetManager {
        return _main;
    }

    private var _game: AssetManager;
    public function get game():AssetManager {
        return _game;
    }

    private var _gui: AssetManager;
    public function get gui():AssetManager {
        return _gui;
    }

    private var _backs: AssetManager;
    public function get backs():AssetManager {
        return _backs;
    }

    private var _queue: Array = [];
    private var _loaded: int;
    private var _loading: int;

    private var _current: AssetManager;

    public function ResourcesManager(info: DeviceResInfo) {
        _info = info;

        _preloader = new AssetManager(_info.scaleFactor);
        _main = new AssetManager(_info.scaleFactor);
        _game = new AssetManager(_info.scaleFactor);
        _gui = new AssetManager(_info.scaleFactor);
        _backs = new AssetManager(_info.scaleFactor);

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
            "config/gui.json",
            "levels/levels.json"
        );
        _queue.push(_main);
    }

    public function loadLevel(path: String):void {
        _loading++;
        _main.enqueue("levels/"+path);
        _queue.push(_main);
    }

    public function loadGame():void {
        _loading++;

        _game.enqueue(
            "textures/"+_info.art+"/game/game.png",
            "textures/"+_info.art+"/game/game.xml",
            File.applicationDirectory.resolvePath("textures/"+_info.art+"/particles"),
            File.applicationDirectory.resolvePath("animations/")
        );
        _queue.push(_game);

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
            "textures/"+_info.art+"/gui/gui.xml"
        );
        _queue.push(_gui);

    }

    public function loadBacks():void {
        _loading++;

        _backs.enqueue(File.applicationDirectory.resolvePath("textures/"+_info.art+"/backs/"));
        _queue.push(_backs);
    }

    public function reloadBack(name: String):void {
        _backs.purge();
        _backs.dispose();

        _loading++;

        _backs.enqueue("textures/"+_info.art+"/backs/"+name+".png");
        _queue.push(_backs);

        load();
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
