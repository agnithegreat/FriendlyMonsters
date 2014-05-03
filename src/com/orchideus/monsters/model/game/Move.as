/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 23:17
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {

public class Move {

    private var _cell1: Cell;
    public function get cell1():Cell {
        return _cell1;
    }

    private var _cell2: Cell;
    public function get cell2():Cell {
        return _cell2;
    }

    public function Move(cell1: Cell, cell2: Cell) {
        _cell1 = cell1;
        _cell2 = cell2;
    }

    public function check(c1: Cell, c2: Cell):Boolean {
        return cell1==c1 && cell2==c2 || cell1==c2 && cell2==c1;
    }

    public function trySwap():void {
        _cell1.swap(_cell2, true);
    }
}
}
