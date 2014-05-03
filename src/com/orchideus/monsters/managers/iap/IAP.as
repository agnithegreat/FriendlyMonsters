/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.iap {
import starling.events.EventDispatcher;

public class IAP extends EventDispatcher {

    public static const SUCCESS: String = "success_IAP";
    public static const FAIL: String = "fail_IAP";

    public static function getIAP():IAP {
        BUILD::mobile {
            return new MobileIAP();
        }
        return new IAP();
    }

    public function IAP() {
    }

    public function getProducts(ids: Array):void {

    }

    public function purchase(id: String):void {
        success({purchaseId: id});
    }

    public function complete(id: String, receipt: String):void {

    }

    protected function success(data: Object):void {
        dispatchEventWith(SUCCESS, false, data);
    }

    protected function fail():void {
        dispatchEventWith(FAIL);
    }
}
}
