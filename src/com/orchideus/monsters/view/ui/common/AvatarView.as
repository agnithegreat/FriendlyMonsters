/**
 * Created by agnither on 18.03.14.
 */
package com.orchideus.monsters.view.ui.common {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;

import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class AvatarView extends AbstractView {

    private var _photoImage: Image;
    private var _photoTexture: Texture;
    public function set photo(value: Texture):void {
        _photoTexture = value;
        update();
    }

    private var _maskRender: RenderTexture;
    private var _mask: Image;

    private var _photoRender: RenderTexture;
    private var _photo: Image;

    public function AvatarView(refs:CommonRefs, mask: Image) {
        _maskRender = new RenderTexture(mask.width, mask.height);
        _maskRender.draw(new Quad(mask.width, mask.height, 0));
        mask.blendMode = BlendMode.ERASE;
        _maskRender.draw(mask);

        super(refs);
    }

    override protected function initialize():void {
        _mask = new Image(_maskRender);
        _mask.blendMode = BlendMode.ERASE;

        _photoRender = new RenderTexture(_maskRender.width, _maskRender.height);

        _photoImage = new Image(_photoRender);

        _photo = new Image(_photoRender);
        addChild(_photo);

        update();
    }

    private function update():void {
        if (!_photo) {
            return;
        }

        _photo.visible = Boolean(_photoTexture);
        if (_photoTexture) {
            _photoImage.texture = _photoTexture;
            _photoRender.draw(_photoImage);
            _photoRender.draw(_mask);
//            _photo.texture = _photoTexture;
        }
    }

    override public function destroy():void {
        super.destroy();

        _photoTexture = null;

        _photoImage.dispose();
        _photoImage = null;

        _maskRender.dispose();
        _maskRender = null;

        _mask.dispose();
        _mask = null;

        _photoRender.dispose();
        _photoRender = null;

        removeChild(_photo, true);
        _photo = null;
    }
}
}
