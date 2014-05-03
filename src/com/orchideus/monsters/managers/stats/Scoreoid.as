/**
 * Created by agnither on 11.03.14.
 */
package com.orchideus.monsters.managers.stats {
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import starling.events.EventDispatcher;

public class Scoreoid extends EventDispatcher {

    public static const RESPONSE: String = "response_Scoreoid";

    public static const CREATE_PLAYER: String = "createPlayer";
    public static const GET_PLAYER: String = "getPlayer";
    public static const EDIT_PLAYER: String = "editPlayer";
    public static const SET_PLAYER_DATA: String = "setPlayerData";
    public static const GET_PLAYER_DATA: String = "getPlayerData";
    public static const SET_PLAYER_REQUEST: String = "setPlayerRequest";
    public static const GET_PLAYER_REQUESTS: String = "getPlayerRequests";

    private static var url: String = "https://api.scoreoid.com/v1/";

    private var _apiKey: String;
    private var _gameId: String;

    private var _loader: URLLoader;

    private var _queue: Vector.<RequestWrapper>;
    private var _current: RequestWrapper;

    public function Scoreoid(apiKey: String, gameId: String) {
        _apiKey = apiKey;
        _gameId = gameId;

        _loader = new URLLoader();
        _loader.dataFormat = URLLoaderDataFormat.TEXT;
        _loader.addEventListener(Event.COMPLETE, handleComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, handleError);

        _queue = new <RequestWrapper>[];
    }

    public function createPlayer(uid: String, firstName: String, lastName: String, money: int):void {
        sendRequest(CREATE_PLAYER, CREATE_PLAYER, {username: uid, first_name: firstName, last_name: lastName, "money": money});
    }

    public function getPlayer(uid: String):void {
        sendRequest(GET_PLAYER, GET_PLAYER, {username: uid});
    }

    public function editPlayer(uid: String, firstName: String, lastName: String, money: int):void {
        sendRequest(EDIT_PLAYER, EDIT_PLAYER, {username: uid, first_name: firstName, last_name: lastName, "money": money});
    }

    public function setPlayerProgress(uid: String, progress: String):void {
        sendRequest(SET_PLAYER_DATA, SET_PLAYER_DATA, {username: uid, key: "progress", value: progress})
    }

    public function getPlayerProgress(uid: String):void {
        sendRequest(GET_PLAYER_DATA, GET_PLAYER_DATA, {username: uid, key: "progress"})
    }

    public function setPlayerRequest(uid: String, request: String, value: Boolean):void {
        sendRequest(SET_PLAYER_REQUEST, SET_PLAYER_DATA, {username: uid, key: "requests."+request, "value": value})
    }

    public function getPlayerRequests(uid: String):void {
        sendRequest(GET_PLAYER_REQUESTS, GET_PLAYER_DATA, {username: uid, key: "requests"})
    }

    private function sendRequest(event:String, method: String, data: Object = null):void {
        var vars: URLVariables = new URLVariables();
        vars.api_key = _apiKey;
        vars.game_id = _gameId;
        vars.response = "JSON";

        if (data) {
            for (var key:* in data) {
                vars[key] = data[key];
            }
        }

        var wrapper: RequestWrapper = new RequestWrapper();
        wrapper.event = event;
        wrapper.method = method;
        wrapper.data = vars;
        _queue.push(wrapper);

        if (!_current) {
            next();
        }
    }

    private function next():void {
        if (_queue.length>0) {
            load(_queue.shift());
        }
    }

    private function load(wrapper: RequestWrapper):void {
        _current = wrapper;

        var request: URLRequest = new URLRequest(url + _current.method);
        request.method = URLRequestMethod.POST;
        request.data = _current.data;
        _loader.load(request);
    }

    private function handleComplete(e: Event):void {
        trace(_current.event, _loader.data);
        var data: Object = {};
        data.event = _current.event;
        data.method = _current.method;
        data.response = JSON.parse(_loader.data);
        dispatchEventWith(RESPONSE, false, data);
        _current = null;

        next();
    }

    private function handleError(e: IOErrorEvent):void {
        trace(e.errorID, e.text);
    }
}
}

import flash.net.URLVariables;
class RequestWrapper {
    public var event: String;
    public var method: String;
    public var data: URLVariables;
}