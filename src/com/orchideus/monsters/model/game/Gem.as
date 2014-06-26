/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:04
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.GemVO;
import com.orchideus.monsters.data.TimingVO;

import starling.events.EventDispatcher;

public class Gem extends EventDispatcher {

    public static const UPDATE: String = "update_Gem";
    public static const COUNTER: String = "counter_Gem";
    public static const HINT: String = "hint_Gem";
    public static const IDLE: String = "idle_Gem";
    public static const KILL: String = "kill_Gem";

    private static var idleGem: Gem;

    private var _gem: GemVO;
    public function get type():String {
        return _gem.type;
    }

    private var _fixed: Boolean;
    public function get fixed():Boolean {
        return _fixed;
    }

    public function get points():int {
        return _gem.points;
    }

    private var _counter: int;
    public function get counter():int {
        return _counter;
    }

    private var _cell: Cell;
    public function get cell():Cell {
        return _cell;
    }

    private var _fall: Boolean;
    public function get fall():Boolean {
        return _fall;
    }

    private var _collect: Boolean;
    public function get collect():Boolean {
        return _collect;
    }

    private var _idleTime: Number = 0;

    public function get matchable():Boolean {
        return true;
    }

    public function get movable():Boolean {
        return cell && cell.block==0;
    }

    public function get allowShuffle():Boolean {
        return movable;
    }

    public function Gem(id: int, fall: Boolean, collect: Boolean, fixed: Boolean) {
        _gem = GemVO.GEMS[id];
        _counter = 0;
        _fall = fall;
        _collect = collect;
        _fixed = fixed;
        _idleTime = 10;
    }

    public function place(cell: Cell):void {
        _cell = cell;

        setIdle(true);
    }

    public function move(swap: Boolean = false):void {
        dispatchEventWith(UPDATE, false, swap);
    }

    public function kill():void {
        dispatchEventWith(KILL);

        if (idleGem && idleGem == this) {
            idleGem = null;
        }
    }

    public function addCounter(value: int, from: Cell = null):void {
        if (cell && !cell.block && matchable && collect) {
            _counter += value;
            dispatchEventWith(COUNTER, false, from);
        }
    }

    private function setIdle(start: Boolean = false):void {
        _idleTime = start ? Math.random() * (TimingVO.idle_max - TimingVO.idle_min) : TimingVO.idle_min + Math.random() * (TimingVO.idle_max - TimingVO.idle_min);
        if (cell && !cell.block) {
            if (!idleGem) {
                idleGem = this;
            }
        }
    }

    public function step(delta: Number):void {
        _idleTime -= delta;

        if (_idleTime<=0 && cell && !cell.block) {
            setIdle();
            if (idleGem && idleGem == this) {
                idleGem = null;
                dispatchEventWith(IDLE, false, 2+Math.random()*4);
            } else {
                dispatchEventWith(IDLE, false, 1);
            }
        }
    }

    public function resetCounter():void {
        _counter = 0;
        dispatchEventWith(COUNTER);
    }

    public function hint():void {
        if (cell && !cell.block) {
            setIdle();
            dispatchEventWith(HINT);
        }
    }
}
}
