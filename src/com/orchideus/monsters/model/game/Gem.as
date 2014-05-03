/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:04
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.GemVO;

import starling.events.EventDispatcher;

public class Gem extends EventDispatcher {

    public static var FALL_TIME: Number = 0.05;
    public static var SWAP_TIME: Number = 0.15;
    public static var KILL_TIME: Number = 0.3;

    public static const UPDATE: String = "update_Gem";
    public static const COUNTER: String = "counter_Gem";
    public static const LIGHT: String = "light_Gem";
    public static const KILL: String = "kill_Gem";

    // TODO: сделать механизм выдачи случайного гема с учетом заданного распределения
    public static function getRandom(fall: Boolean):Gem {
        return new Gem(1 + Math.random() * GemVO.amount, fall);
    }

    private var _gem: GemVO;
    public function get type():String {
        return _gem.type;
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

    private var _light: Boolean;
    public function get light():Boolean {
        return _light;
    }

    private var _fall: Boolean;
    public function get fall():Boolean {
        return _fall;
    }

    private var _match: Match;
    public function get match():Match {
        return _match;
    }

    public function Gem(id: int, fall: Boolean) {
        _gem = GemVO.GEMS[id];
        _counter = 0;
        _fall = fall;
    }

    public function place(cell: Cell, swap: Boolean = false, silent: Boolean = false):void {
        _cell = cell;

        if (!silent) {
            if (_cell) {
                dispatchEventWith(UPDATE, false, swap);
            } else {
                dispatchEventWith(KILL);
            }
        }
    }

    public function addCounter(value: int):void {
        _counter += value;
        dispatchEventWith(COUNTER);
    }

    public function resetCounter():void {
        _counter = 0;
        dispatchEventWith(COUNTER);
    }

    public function set light(value: Boolean):void {
        _light = value;
        dispatchEventWith(LIGHT);
    }

    public function set match(value: Match):void {
        _match = value;
    }
}
}
