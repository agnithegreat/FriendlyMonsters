/**
 * Created by agnither on 25.05.14.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.DecorVO;

import flash.geom.Point;

import starling.events.EventDispatcher;

public class Decor extends EventDispatcher {

    private var _type: String;
    public function get type():String {
        return _type;
    }

    public function get decor():DecorVO {
        return DecorVO.DECORS[_type];
    }

    private var _position: Point;
    public function get position():Point {
        return _position;
    }

    public function Decor(type: String, x: int, y: int) {
        _type = type;
        _position = new Point(x, y);
    }
}
}
