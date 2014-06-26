/**
 * Created by agnither on 03.05.14.
 */
package com.orchideus.monsters.model.game {
import flash.utils.Dictionary;

import starling.events.EventDispatcher;

public class CountersList extends EventDispatcher {

    private var _counters: Vector.<Counter>;
    public function get counters():Vector.<Counter> {
        return _counters;
    }

    private var _counterTypes: Dictionary;

    public function hasCounter(type: String):Boolean {
        return Boolean(_counterTypes[type]);
    }

    public function get progress():int {
        var progress: Number = 0;
        for (var i:int = 0; i < _counters.length; i++) {
            progress += _counters[i].progress;
        }
        return progress/_counters.length * 100;
    }

    public function get success():Boolean {
        for (var i:int = 0; i < _counters.length; i++) {
            if (!_counters[i].completed) {
                return false;
            }
        }
        return true;
    }

    public function CountersList() {
        _counters = new <Counter>[];
        _counterTypes = new Dictionary();
    }

    public function addCounter(type: String, target: int):void {
        var counter: Counter = new Counter(type, target);
        _counters.push(counter);
        _counterTypes[type] = counter;
    }

    public function addValue(type: String, value: int):void {
        var counter: Counter = _counterTypes[type];
        if (counter) {
            counter.addCounter(value);
        }
    }

    public function clear():void {
        _counters.length = 0;

        for (var key: * in _counterTypes) {
            delete _counterTypes[key];
        }
    }
}
}
