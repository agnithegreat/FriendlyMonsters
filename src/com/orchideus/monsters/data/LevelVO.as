/**
 * Created by agnither on 22.05.14.
 */
package com.orchideus.monsters.data {
public class LevelVO {

    private var _id: int;
    public function get id():int {
        return _id;
    }

    private var _data: Object;
    public function get data():Object {
        return _data;
    }
    public function set data(value: Object):void {
        _data = value;
    }

    public function get filename():String {
        return "level"+_id+".json"
    }

    public function LevelVO(id: int) {
        _id = id;
    }
}
}
