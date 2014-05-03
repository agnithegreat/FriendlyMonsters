/**
 * Created by agnither on 16.04.14.
 */
package com.orchideus.monsters.view.ui.common {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

public class CommonImage extends AbstractView {

    private var _link: Object;

    public function CommonImage(refs:CommonRefs, link: Object) {
        _link = link;
        super(refs);
    }

    override protected function initialize():void {
        createFromCommon(_link);
    }

    override public function destroy():void {
        _link = null;
        super.destroy();
    }
}
}
