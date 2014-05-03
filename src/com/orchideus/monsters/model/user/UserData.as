/**
 * Created by agnither on 18.03.14.
 */
package com.orchideus.monsters.model.user {
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.utils.Dictionary;

import starling.events.EventDispatcher;
import starling.textures.Texture;

public class UserData extends EventDispatcher {

    public static const UPDATE: String = "update_UserData";
    public static const PHOTO_LOADED: String = "photo_loaded_UserData";

    private static var _users: Dictionary = new Dictionary();
    public static function getUser(uid: String):UserData {
        return _users[uid] ? _users[uid] : new UserData();
    }

    private static var _bot: MockUserData;
    public static function createBot(texture: Texture):void {
        _bot = new MockUserData(texture);
    }

    private static var _install: Dictionary = new Dictionary();
    private static var _overall: Dictionary = new Dictionary();
    public static function getOverall():Array {
        var overall: Array = [];
        overall.push(_bot);
        for (var key:* in _install) {
            if (_install[key].firstName) {
                overall.push(_install[key]);
            }
        }
        overall.sortOn("level", Array.NUMERIC+Array.DESCENDING);
        return overall;
    }

    public static function get uids():Array {
        var u: Array = [];
        for (var key: * in _install) {
            u.push(_install[key].uid);
        }
        return u;
    }

    public static function parseSocial(users: Array):void {
        var l: int = users.length;
        for (var i:int = 0; i < l; i++) {
            var user: UserData = getUser(users[i].id)
            user.parseSocialData(users[i]);
            _users[user.uid] = user;

            if (user.installed) {
                _install[user.uid] = user;
            }
        }
    }

    public static function parseGame(users: Array):void {
        var l: int = users.length;
        for (var i:int = 0; i < l; i++) {
            var user: UserData = getUser(users[i].uid);
            user.parseGameData(users[i]);
            _overall[user.uid] = user;
        }
    }

    protected var _uid: String;
    public function get uid():String {
        return _uid;
    }

    protected var _firstName: String;
    public function get firstName():String {
        return _firstName;
    }

    protected var _lastName: String;
    public function get lastName():String {
        return _lastName;
    }

    public function get fullName():String {
        return firstName + " " + lastName;
    }

    protected var _installed: Boolean;
    public function get installed():Boolean {
        return _installed;
    }

    protected var _photoLoading: Boolean;
    protected var _photoUrl: String;
    protected var _photo: Texture;
    public function get photo():Texture {
        return _photo;
    }

    protected var _level: int;
    public function get level():int {
        return _level;
    }

    public function UserData() {
    }

    public function parseSocialData(data: Object):void {
        _uid = data.id;
        _firstName = data.first_name;
        _lastName = data.last_name;
        _installed = data.installed;
        _photoUrl = "http://graph.facebook.com/"+_uid+"/picture?width=160&height=160";
    }

    public function parseGameData(data: Object):void {
        _level = data.level;

        dispatchEventWith(UPDATE);
    }

    public function load():void {
        if (!_photoUrl || _photo || _photoLoading) {
            return;
        }
        loadPhoto();
    }

    private var _loader: Loader;
    private function loadPhoto():void {
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlePhotoLoaded);
        _loader.load(new URLRequest(_photoUrl));
        _photoLoading = true;
    }

    private function handlePhotoLoaded(e: Event):void {
        _photo = Texture.fromBitmap(Bitmap(_loader.content));
        _loader.unloadAndStop();
        _loader = null;

        dispatchEventWith(PHOTO_LOADED);
    }
}
}
