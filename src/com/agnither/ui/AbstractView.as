/**
 * Created with IntelliJ IDEA.
 * User: virich
 * Date: 05.06.13
 * Time: 14:46
 * To change this template use File | Settings | File Templates.
 */
package com.agnither.ui {
import com.agnither.utils.CommonRefs;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.Button;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.HAlign;

public class AbstractView extends Sprite {

    protected var _refs: CommonRefs;

    protected var _data: Object;
    public function set data(val: Object):void {
        _data = val;
    }

    protected var _links: Dictionary = new Dictionary();

    protected var _defaultPosition: Point;

    public function AbstractView(refs: CommonRefs) {
        _refs = refs;

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    public function createFromConfig(config: Object, container: Sprite = null):void {
        if (!container) {
            container = this;
            _defaultPosition = new Point(config.x, config.y);
        }

        container.x = config.x;
        container.y = config.y;

        var l: int = config.structure.length;
        for (var i:int = 0; i < l; i++) {
            var frames: Array = config.structure[i];
            var frL: int = frames.length;
            for (var j:int = 0; j < frL; j++) {
                var item: Object = frames[j];

                var view: DisplayObject;
                if (item.type == "bitmap") {
                    var texture: Texture = _refs.gui.getTexture(item.image);
                    view = texture ? new Image(texture) : null;
                    if (view) {
                        view.touchable = false;
                    }
                } else if (item.type == "button") {
                    var images: Array = item.images;
                    view = new Button(_refs.gui.getTexture(images[0]), "", images.length>=2 ? _refs.gui.getTexture(images[2]) : null);
                } else if (item.type == "text") {
                    view = new TextField(item.width, item.height, item.text, item.fontName, -1, item.fontColor);
                    view.touchable = false;
                    (view as TextField).hAlign = item.align;
    //                (view as TextField).vAlign = "top";
                } else if (item.type == "movie clip") {
                    view = new Sprite();
                    createFromConfig(item, view as Sprite);
                }
                if (view) {
                    view.x = item.x;
                    view.y = item.y;
                    container.addChild(view);
                    if (item.name) {
                        view.name = item.name;
                        _links[item.name] = view;
                    }
                }

            }
        }
    }

    public function createFromCommon(config: Object):void {
        var l: int = config.structure.length;
        for (var i:int = 0; i < l; i++) {
            var frames: Array = config.structure[i];
            var frL: int = frames.length;
            for (var j:int = 0; j < frL; j++) {
                var item: Object = frames[j];

                var view: DisplayObject;
                if (item.type == "bitmap") {
                    var texture: Texture = _refs.gui.getTexture(item.image);
                    view = texture ? new Image(texture) : null;
                    if (view) {
                        view.touchable = false;
                    }
                } else if (item.type == "text") {
                    view = new TextField(item.width, item.height, item.text, item.fontName, -1, item.fontColor);
                    view.touchable = false;
                    (view as TextField).hAlign = item.align;
//                    (view as TextField).vAlign = "top";
                } else if (item.type == "button") {
                    var images: Array = item.images;
                    view = new Button(_refs.gui.getTexture(images[0]), "", images.length>=2 ? _refs.gui.getTexture(images[2]) : null);
                } else if (item.type == "movie clip") {
                    view = new Sprite();
                    createFromConfig(item, view as Sprite);
                }
                if (view) {
                    view.x = item.x;
                    view.y = item.y;
                    addChild(view);
                    if (item.name) {
                        _links[item.name] = view;
                    }
                }
            }
        }
    }

    protected function initialize():void {
    }

    protected function addToContainer(texture: Texture, container: Sprite, x: int, y: int, scaleX: Number = 1, scaleY: Number = 1):void {
        var image: Image = new Image(texture);
        image.x = x;
        image.y = y;
        image.scaleX = scaleX;
        image.scaleY = scaleY;
        container.addChild(image);
    }

    public function open():void {
    }

    public function close():void {
    }

    protected function hide():void {
        visible = false;
    }

    private function handleAddedToStage(event: Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);

        initialize();
    }

    private function handleAdded(event: Event):void {
        removeEventListener(Event.ADDED_TO_STAGE, handleAdded);
        open();
    }

    private function handleRemoved(event: Event):void {
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
//        close();
    }

    private function destroyContainer(container: Sprite):void {
        while (container.numChildren>0) {
            var child: DisplayObject = container.getChildAt(0);
            if (child is Sprite) {
                destroyContainer(child as Sprite);
            }
            container.removeChild(child, true);
        }
    }

    public function destroy():void {
        destroyContainer(this);

        _refs = null;
    }
}
}