/**
 * Created by agnither on 22.05.14.
 */
package com.orchideus.monsters.data {
import com.agnither.utils.ResourcesManager;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.Dictionary;

import starling.events.Event;
import starling.events.EventDispatcher;

public class LevelsStorage extends EventDispatcher {

    public static const LEVEL_ADDED: String = "level_added_LevelsStorage";
    public static const LEVEL_LOADED: String = "level_loaded_LevelsStorage";
    public static const LEVEL_SELECTED: String = "level_selected_LevelsStorage";

    private var _resources: ResourcesManager;

    private var _list: Object;
    public function get list():Object {
        return _list;
    }

    private var _levels: Dictionary;
    public function get levels():Dictionary {
        return _levels;
    }

    private var _length: int;
    public function get length():int {
        return _length;
    }

    private var _currentLevel: int;
    public function get currentLevel():int {
        return _currentLevel;
    }

    public function LevelsStorage(resources: ResourcesManager) {
        _resources = resources;

        _levels = new Dictionary();

        _length = 0;
        _list = _resources.main.getObject("levels");

        if (!_list) {
            _list = {};
        }

        for (var key: * in _list) {
            _levels[key] = new LevelVO(key);
            _length++;
        }
    }

    public function create(id: int):void {
        var level:LevelVO = new LevelVO(id);
        _currentLevel = level.id;
        _levels[id] = level;
        _length++;
        dispatchEventWith(LEVEL_ADDED, false, level);
        dispatchEventWith(LEVEL_SELECTED, false, level);
    }

    public function save(data: Object):void {
        if (!_currentLevel) {
            return;
        }

        var level: LevelVO = _levels[_currentLevel];
        level.data = data;
        _list[_currentLevel] = {filename: level.filename};

        var file: File = new File(File.applicationDirectory.resolvePath("levels/"+level.filename).nativePath);
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeUTFBytes(JSON.stringify(level.data));
        fileStream.close();

        file = new File(File.applicationDirectory.resolvePath("levels/levels.json").nativePath);
        fileStream = new FileStream();
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeUTFBytes(JSON.stringify(_list));
        fileStream.close();
    }

    public function load(id: int, force: Boolean = false):void {
        _currentLevel = id;

        var level: LevelVO = _levels[_currentLevel];
        if (level) {
            if (level.data && !force) {
                dispatchEventWith(LEVEL_LOADED, false, level);
            } else {
                _resources.addEventListener(ResourcesManager.COMPLETE, handleLoadLevel);
                _resources.loadLevel(_list[_currentLevel].filename);
                _resources.load();
            }

            dispatchEventWith(LEVEL_SELECTED, false, level);
        }
    }

    private function handleLoadLevel(e: Event):void {
        var level: LevelVO = _levels[_currentLevel];
        level.data = _resources.main.getObject("level"+_currentLevel);
        dispatchEventWith(LEVEL_LOADED, false, level);
    }
}
}
