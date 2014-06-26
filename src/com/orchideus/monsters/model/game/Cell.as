/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:30
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.BlockVO;
import com.orchideus.monsters.data.TimingVO;

import flash.geom.Point;

import starling.events.EventDispatcher;

public class Cell extends EventDispatcher {

    public static const UPDATE: String = "update_Cell";
    public static const IDLE: String = "idle_Cell";
    public static const SELECT: String = "select_Cell";

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

    private var _available: Boolean;
    public function get available():Boolean {
        return _available;
    }

    private var _enter: Boolean;
    public function get enter():Boolean {
        return _enter;
    }

    private var _exit: Boolean;
    public function get exit():Boolean {
        return _exit;
    }

    public function get fillable():Boolean {
        return !_gem && !blockIsInner && !decor;
    }

    private var _ingredient: Boolean;
    public function get ingredient():Boolean {
        return _ingredient;
    }

    private var _blockType: String;
    public function get blockType():String {
        return _blockType;
    }
    public function get blockIsInner():Boolean {
        return _blockType && BlockVO.BLOCKS[_blockType].isInner;
    }

    private var _block: int;
    public function get block():int {
        return _block;
    }

    private var _decor: Decor;
    public function get decor():Decor {
        return _decor;
    }
    public function set decor(value: Decor):void {
        _decor = value;
        update();
    }

    private var _idleTime: Number = 0;

    private var _graphics: Array;
    public function get graphics():Array {
        return _graphics;
    }

    private var _selected: Boolean;
    public function get selected():Boolean {
        return _selected;
    }

    public function get matchable():Boolean {
        return gem && gem.matchable;
    }

    private var _match: Match;
    public function get match():Match {
        return _match;
    }
    public function set match(value: Match):void {
        _match = value;
    }

    public function Cell(x: int, y: int, data: Object) {
        _position = new Point(x, y);
        _available = data.available;
        _enter = data.enter;
        _ingredient = data.ingredient;
        _exit = data.exit;
        _blockType = data.block;
        _block = data.rank;
        _graphics = data.graphics;

        setIdle();
    }

    public function setGem(gem: Gem, swap: Boolean = false, silent: Boolean = false):void {
        _gem = gem;
        if (_gem) {
            _gem.place(this);

            if (!silent) {
                _gem.move(swap);
            }
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

    public function fall(cell: Cell):void {
        var tempGem: Gem = cell.gem;
        cell.setGem(_gem, false);
        setGem(tempGem, false);
    }

    private function setIdle():void {
        _idleTime = TimingVO.idle_min + Math.random() * (TimingVO.idle_max - TimingVO.idle_min);
    }

    public function step(delta: Number):void {
        if (blockIsInner) {
            _idleTime -= delta;

            if (_idleTime <= 0) {
                setIdle();
                dispatchEventWith(IDLE);
            }
        } else if (_gem) {
            _gem.step(delta);
        }
    }

    public function damageBlock():void {
        if (_block) {
            _block--;
            if (_block==0) {
                _blockType = null;
            }
        }

        update();
    }

    public function removeGem():void {
        if (_gem) {
            _gem.place(null);
            _gem.kill();
        }
        _gem = null;

        update();
    }

    public function clear():void {
        if (_block) {
            damageBlock();
        }
        if (_gem) {
            removeGem();
        }
    }

    public function update():void {
        dispatchEventWith(UPDATE);
    }
}
}
