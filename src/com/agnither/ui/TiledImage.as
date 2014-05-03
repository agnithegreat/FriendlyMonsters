/**
 * Created by agnither on 27.02.14.
 */
package com.agnither.ui {
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

public class TiledImage extends Sprite {

    public function TiledImage(texture: Texture, tileX: int = 1, tileY: int = 1) {
        for (var i:int = 0; i < tileX; i++) {
            for (var j:int = 0; j < tileY; j++) {
                var tile: Image = new Image(texture);
                tile.x = texture.width * i;
                tile.y = texture.height * j;
                addChild(tile);
            }
        }
    }

    public function destroy():void {
        while (numChildren>0) {
            removeChildAt(0, true);
        }
    }
}
}
