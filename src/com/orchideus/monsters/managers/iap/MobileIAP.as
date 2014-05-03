/**
 * Created by agnither on 23.04.14.
 */
package com.orchideus.monsters.managers.iap {
import com.freshplanet.ane.AirInAppPurchase.InAppPurchase;
import com.freshplanet.ane.AirInAppPurchase.InAppPurchaseEvent;

public class MobileIAP extends IAP {

    private var _inAppPurchase: InAppPurchase;

    public function MobileIAP() {
        _inAppPurchase = new InAppPurchase();
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PRODUCT_INFO_RECEIVED, handleProductSuccess);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PRODUCT_INFO_ERROR, handleProductFail);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_SUCCESSFULL, handleSuccess);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_ERROR, handleFail);
        _inAppPurchase.init("", true);
    }

    override public function getProducts(ids: Array):void {
        _inAppPurchase.getProductsInfo(ids, []);
    }

    override public function purchase(id: String):void {
        _inAppPurchase.makePurchase(id);
    }

    override public function complete(id: String, receipt: String):void {
        _inAppPurchase.removePurchaseFromQueue(id, receipt);
    }

    private function handleProductSuccess(e: InAppPurchaseEvent):void {
//        success(JSON.parse(e.data));
    }

    private function handleProductFail(e: InAppPurchaseEvent):void {
//        fail();
    }

    private function handleSuccess(e: InAppPurchaseEvent):void {
        success(JSON.parse(e.data));
    }

    private function handleFail(e: InAppPurchaseEvent):void {
        fail();
    }
}
}
