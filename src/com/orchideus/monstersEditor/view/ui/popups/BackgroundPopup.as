/**
 * Created by agnither on 28.05.14.
 */
package com.orchideus.monstersEditor.view.ui.popups {
import com.agnither.ui.Popup;
import com.agnither.utils.CommonRefs;

import feathers.display.Scale9Image;
import feathers.textures.Scale9Textures;

import flash.geom.Rectangle;

public class BackgroundPopup extends Popup {

    public static const ID: String = "BackgroundPopup";

    private var _back: Scale9Image;

    private var _list: Vector.<BackgroundSmallView>;

    public function BackgroundPopup(refs:CommonRefs) {
        super(refs, true);
    }

    override protected function initialize():void {
        var texture: Scale9Textures = new Scale9Textures(_refs.gui.getTexture("window_sample.png"), new Rectangle(55, 55, 280, 20));
        _back = new Scale9Image(texture);
        _back.width = 700;
        _back.height = 600;
        addChild(_back);

        _list = new <BackgroundSmallView>[];
    }

    override public function open():void {
        super.open();

        var backs: Vector.<String> = _refs.backs.getTextureNames();
        for (var i:int = 0; i < backs.length; i++) {
            var back: BackgroundSmallView = new BackgroundSmallView(_refs, backs[i]);
            back.x = 10 + (i % 5) * 138;
            back.y = 50 + int(i/5) * 106;
            addChild(back);
            _list.push(back);
        }
    }

    override public function close():void {
        super.close();

        removeFromParent();

        while (_list.length>0) {
            var back: BackgroundSmallView = _list.shift();
            back.destroy();
            removeChild(back);
        }
    }
}
}
