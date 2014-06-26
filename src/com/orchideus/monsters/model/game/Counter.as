/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.model.game {
import starling.events.EventDispatcher;

public class Counter extends EventDispatcher {

    public static const UPDATE: String = "update_Counter";

    private var _type: String;
    public function get type():String {
        return _type;
    }

    private var _amount: int;
    public function get amount():int {
        return _amount;
    }

    private var _target: int;
    public function get target():int {
        return _target;
    }

    public function get progress():Number {
        return _amount/_target;
    }

    public function get completed():Boolean {
        return _amount >= _target;
    }

    public function Counter(type: String, target: int) {
        _type = type;
        _amount = 0;
        _target = target;
    }

    public function addCounter(value: int):void {
        _amount += value;
        dispatchEventWith(UPDATE);
    }
}
}
