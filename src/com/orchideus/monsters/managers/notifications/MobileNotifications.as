/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.notifications {
import com.juankpro.ane.localnotif.Notification;
import com.juankpro.ane.localnotif.NotificationIconType;
import com.juankpro.ane.localnotif.NotificationManager;

public class MobileNotifications extends Notifications {

    private var _notifications: NotificationManager;

    public function MobileNotifications() {
        if (NotificationManager.isSupported) {
            _notifications = new NotificationManager();
        }
    }

    override public function send(id: String, title: String, text: String, date: Date = null):void {
        if (_notifications) {
            var note: Notification = new Notification();
            if (date) {
                note.fireDate = date;
            }
            note.iconType = NotificationIconType.MESSAGE;
            note.playSound = true;
            note.vibrate = true;
            note.cancelOnSelect = true;
            note.repeatAlertUntilAcknowledged = true;
            note.title = title;
            note.body = text;
            _notifications.notifyUser(id, note);
        }
    }

    override public function cancel(id: String):void {
        if (_notifications) {
            _notifications.cancel(id);
        }
    }
}
}
