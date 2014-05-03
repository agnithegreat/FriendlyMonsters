/**
 * Created with IntelliJ IDEA.
 * User: agnithegreat
 * Date: 12.06.13
 * Time: 1:34
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.managers.social {
import starling.events.EventDispatcher;

public class Social extends EventDispatcher {

    public static function getSocial():Social {
        BUILD::mobile {
            return new MobileSocial();
        }
        BUILD::web {
            return new WebSocial();
        }
        return new Social();
    }

    public static const LOGGED_IN: String = "logged_in_Social";
    public static const GET_ME: String = "get_me_Social";
    public static const GET_FRIENDS: String = "get_friends_Social";
    public static const GET_REQUEST: String = "get_request_Social";
    public static const POST: String = "post_Social";
    public static const ASK: String = "ask_Social";
    public static const SEND: String = "send_Social";

    public static var appID: String = "547878445307531";
    public static var readPermissions: Array = ["basic_info", "user_about_me", "read_friendlists"];
    public static var writePermissions: Array = ["publish_actions", "publish_stream"];

    public function get isSupported():Boolean {
        return false;
    }
    public function get isInitiated():Boolean {
        return false;
    }

    private var _isLogged: Boolean;
    public function get isLogged():Boolean {
        return _isLogged;
    }

    protected var _me: Object;
    public function get me():Object {
        return _me;
    }

    public function get uid():String {
        return _me.id;
    }

    public function get firstName():String {
        return _me.first_name;
    }

    public function get lastName():String {
        return _me.last_name;
    }

    protected var _friends: Array;
    public function get friends():Array {
        return _friends;
    }

    public function init():void {
    }

    public function login():void {
        _isLogged = true;
        handleOpenSession(true, false);
    }

    public function getMe():void {
        handleGetMe({id: "100000013942889", first_name: "Кирилл", last_name: "Вирич", installed: true});
    }

    public function getFriends():void {
        handleGetFriends({data: []});
    }

    public function invite(message: String, uid: String = null):void {
    }

    public function ask(message: String):void {
    }

    public function send(message: String, users: String):void {
    }

    public function getRequest(id: String):void {

    }

    public function deleteRequest(id: String):void {

    }

    public function post(url: String, name: String, caption: String, description: String, to: String = null):void {
    }

    public function alert(text: String):void {

    }

    protected function handleOpenSession(success: Boolean, userCancelled: Boolean, error: String = null):void {
        if (success) {
            dispatchEventWith(LOGGED_IN);
        }
    }

    protected function handleGetMe(data: Object, fail: Object = null):void {
        _me = data;
        _me.installed = true;
        dispatchEventWith(GET_ME);
    }

    protected function handleGetFriends(data: Object, fail: Object = null):void {
        _friends = data.data as Array;
        dispatchEventWith(GET_FRIENDS);
    }

    protected function handleAsk(data: Object, fail: Object = null):void {
        dispatchEventWith(ASK, false, data);
    }

    protected function handleSend(data: Object, fail: Object = null):void {
        dispatchEventWith(SEND, false, data);
    }

    protected function handleGetRequest(data: Object, fail: Object = null):void {
        dispatchEventWith(GET_REQUEST, false, data);
    }

    protected function handlePost(data: Object, fail: Object = null):void {
        dispatchEventWith(POST, false, data);
    }
}
}
