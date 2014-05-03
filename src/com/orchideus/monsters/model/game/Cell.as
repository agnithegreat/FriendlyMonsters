/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:30
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.model.*;

import flash.geom.Point;

import starling.events.EventDispatcher;

public class Cell extends EventDispatcher {

    public static const UPDATE: String = "update_Slot";
    public static const SELECT: String = "select_Slot";

    private var _position: Point;
    public function get position():Point {
        return _position;
    }

    public function get x():int {
        return _position.x;
    }

    public function get y():int {
        return _position.y;
    }

    private var _gem: Gem;
    public function get gem():Gem {
        return _gem;
    }

    public function get type():String {
        return _gem ? _gem.type : null;
    }

    private var _selected: Boolean;
    public function get selected():Boolean {
        return _selected;
    }

    private var _block: int;
    public function get block():int {
        return _block;
    }

    public function Cell(x: int, y: int) {
        _position = new Point(x, y);
    }

    public function set block(val: int):void {
        _block = val;
    }

    public function setGem(gem: Gem, swap: Boolean = false, silent: Boolean = false):void {
        _gem = gem;
        if (_gem) {
            _gem.place(this, swap, silent);
        }

        update();
    }

    public function select(value: Boolean):void {
        _selected = value;
        dispatchEventWith(SELECT);
    }

    public function swap(cell: Cell, silent: Boolean = false):void {
        var tempGem: Gem = cell.gem;
        cell.setGem(_gem, true, silent);
        setGem(tempGem, true, silent);
    }

    public function clear():void {
        if (_block) {
            _block--;
        } else {
            if (_gem) {
                _gem.place(null);
            }
            _gem = null;
        }

        update();
    }

    public function update():void {
        dispatchEventWith(UPDATE);
    }
}
}
