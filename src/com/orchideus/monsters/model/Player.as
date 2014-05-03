/**
 * Created by agnither on 10.04.14.
 */
package com.orchideus.monsters.model {
import com.adobe.crypto.MD5;

import com.agnither.utils.LocalizationManager;

import flash.net.SharedObject;
import flash.system.Capabilities;

import starling.events.EventDispatcher;

public class Player extends EventDispatcher {

    public static const UPDATE: String = "update_Player";

    public static var version: int = 1;
    public static var code: String = "new1";

    private var _data: SharedObject;

    public function get uid():String {
        return _data.data.uid ? _data.data.uid : _data.data.deviceId;
    }

    public function get language():String {
        return _data.data.language;
    }

    public function get firstName():String {
        return _data.data.firstName;
    }

    public function get lastName():String {
        return _data.data.lastName;
    }

    public function Player() {
    }

    public function init():void {
        _data = SharedObject.getLocal("player");
        if (!_data.data.version || _data.data.code != code) {
            createProgress();
        }
    }

    public function login(uid: String = null, firstName: String = null, lastName: String = null):void {
        _data.data.uid = uid;
        _data.data.firstName = firstName;
        _data.data.lastName = lastName;
    }

    private function createProgress():void {
        _data.data.uid = null;
        _data.data.deviceId = MD5.hash(String(Math.random()));
        _data.data.language = (Capabilities.language in LocalizationManager.localesAvailable) ? Capabilities.language : "en";

        _data.data.version = version;
        _data.data.code = code;
    }

    public function getProgress():Object {
        var data: Object = {};
        data.uid = uid;
        return data;
    }

    public function setProgress(data: Object):void {
        save();
    }

    private function update():void {
        save();
        dispatchEventWith(UPDATE);
    }

    private function save():void {
        _data.flush();
    }
}
}
