/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.notifications {
public class Notifications {

    public static function getNotifications():Notifications {
        BUILD::mobile {
            return new MobileNotifications();
        }
        return new Notifications();
    }

    public function Notifications() {
    }

    public function send(id: String, title: String, text: String, date: Date = null):void {
    }

    public function cancel(id: String):void {
    }
}
}
