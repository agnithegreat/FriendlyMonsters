/**
 * Created with IntelliJ IDEA.
 * User: agnithegreat
 * Date: 12.06.13
 * Time: 1:34
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.managers.social {
import com.freshplanet.ane.AirFacebook.Facebook;

public class MobileSocial extends Social {

    private var _facebook: Facebook;
    override public function get isSupported():Boolean {
        return Facebook.isSupported;
    }
    override public function get isInitiated():Boolean {
        return Boolean(_facebook);
    }
    override public function get isLogged():Boolean {
        return isInitiated && _facebook.isSessionOpen;
    }

    override public function init():void {
        _facebook = Facebook.getInstance();
        _facebook.init(appID);

        if (isLogged) {
            dispatchEventWith(LOGGED_IN);
        }
    }

    override public function login():void {
        if (isInitiated && !_facebook.isSessionOpen) {
            // TODO: share permissions
            _facebook.openSessionWithPermissions(readPermissions.concat(writePermissions), handleOpenSession);
        }
    }

    override public function getMe():void {
        if (isLogged) {
            _facebook.requestWithGraphPath("/me", null, "GET", handleGetMe);
        }
    }

    override public function getFriends():void {
        if (isLogged) {
            _facebook.requestWithGraphPath("/me/friends", {fields: "id,first_name,last_name,installed"}, "GET", handleGetFriends);
        }
    }

    override public function invite(message: String, uid: String = null):void {
        if (isLogged) {
            _facebook.dialog("apprequests", {"message": message, frictionlessRequests : true, to: uid});
        } else {
            login();
        }
    }

    override public function ask(message: String):void {
        if (isLogged) {
            _facebook.dialog("apprequests", {"message": message, data: "ask", action_type: "askfor", object_id: "718966191500573", frictionlessRequests : true}, handleAsk);
        } else {
            login();
        }
    }

    override public function getRequest(id: String):void {
        if (isLogged) {
            _facebook.requestWithGraphPath("/"+id, null, "GET", handleGetRequest);
        }
    }

    override public function deleteRequest(id: String):void {
        if (isLogged) {
            _facebook.requestWithGraphPath("/"+id, null, "DELETE");
        }
    }

    override public function send(message: String, user: String):void {
        if (isLogged) {
            _facebook.dialog("apprequests", {"message": message, to: user, data: "send", action_type: "send", object_id: "718966191500573", frictionlessRequests : true}, handleSend);
        } else {
            login();
        }
    }

    override public function post(url: String, name: String, caption: String, description: String, to: String = null):void {
        if (isLogged) {
            _facebook.dialog("feed", {"to": to, "picture": url, "name": name, "caption": caption, "description": description}, handlePost);
        }
    }

    override public function alert(text: String):void {
//        AirAlert.getInstance().showAlert("Facebook", text);
    }
}
}
