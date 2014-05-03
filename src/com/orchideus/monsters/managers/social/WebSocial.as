/**
 * Created with IntelliJ IDEA.
 * User: agnithegreat
 * Date: 12.06.13
 * Time: 1:34
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.managers.social {
import com.facebook.graph.Facebook;
import com.facebook.graph.data.FacebookAuthResponse;

import flash.system.Security;

import starling.core.Starling;

public class WebSocial extends Social {

    private var _apiSecuredPath:String = "https://graph.facebook.com";
    private var _apiUnsecuredPath:String = "http://graph.facebook.com";

    private var _session: FacebookAuthResponse;
    override public function get isSupported():Boolean {
        return true;
    }
    override public function get isInitiated():Boolean {
        return true;
    }
    override public function get isLogged():Boolean {
        return isInitiated && Boolean(_session);
    }

    override public function init():void {
        Security.loadPolicyFile(_apiSecuredPath + "/crossdomain.xml");
        Security.loadPolicyFile(_apiUnsecuredPath + "/crossdomain.xml");
        Security.loadPolicyFile("https://fbcdn-profile-a.akamaihd.net/crossdomain.xml");
        Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");

        login();

        if (isLogged) {
            dispatchEventWith(LOGGED_IN);
        }
    }

    override public function login():void {
        if (isInitiated && !_session) {
            Facebook.init(appID, handleInit, {cookie: true, "appId":appID,
                perms: readPermissions.concat(writePermissions).toString()});
        }
    }

    override public function getMe():void {
        if (isLogged) {
            Facebook.api("/me", handleGetMe, {fields: "first_name,last_name,birthday,gender,locale,friends,currency"}, "GET");
        }
    }

    override public function getFriends():void {
        if (isLogged) {
            Facebook.api("/me/friends", handleGetFriends, {fields: "first_name,last_name,installed"}, "GET");
        }
    }

    override public function invite(message: String, uid: String = null):void {
        if (isLogged) {
            if (uid) {
                Facebook.ui("apprequests", {"message": message, "to": uid});
            } else {
                Facebook.ui("apprequests", {"message": message});
            }
        }
    }

    override public function ask(message: String):void {
        if (isLogged) {
            Facebook.ui("apprequests", {"message": message, data: "ask", action_type: "askfor", object_id: "718966191500573", frictionlessRequests : true}, handleAsk);
        }
    }

    override public function getRequest(id: String):void {
        if (isLogged) {
            Facebook.api("/"+id, handleGetRequest, null, "GET");
        }
    }

    override public function deleteRequest(id: String):void {
//        if (isLogged) {
//            Facebook.api("/"+id, null, null, "DELETE");
//        }
    }

    override public function send(message: String, user: String):void {
        if (isLogged) {
            Facebook.ui("apprequests", {"message": message, to: user, data: "send", action_type: "send", object_id: "718966191500573", frictionlessRequests : true}, handleSend);
        }
    }

    override public function post(url: String, name: String, caption: String, description: String, to: String = null):void {
        if (isLogged) {
            Facebook.ui("feed", {"to": to, "picture": url, "name": name, "caption": caption, "description": description}, handlePost);
        }
    }

    private function handleInit(success: Object, fail: Object):void {
        if (success || isLogged) {
            handleLogin(success, fail);
        } else {
            Facebook.login(handleLogin, {scope: readPermissions.concat(writePermissions).toString()});
        }
    }

    private function handleLogin(success: Object, fail: Object):void {
        if (success) {
            _session = success as FacebookAuthResponse;
            dispatchEventWith(LOGGED_IN);
        } else {
            Starling.juggler.delayCall(login, 1);
        }
    }
}
}
