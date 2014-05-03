/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 09.11.13
 * Time: 0:37
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.GemVO;
import com.orchideus.monsters.data.MultiplierVO;

public class Match {

    private var _cells: Vector.<Cell>;
    public function get cells():Vector.<Cell> {
        return _cells;
    }

    public function get amount():int {
        return _cells.length;
    }

    private var _type: String;
    public function get type():String {
        return _type;
    }

    private var _toConcat: Match;
    public function get toConcat():Match {
        return _toConcat;
    }

    private var _corner: Boolean;
    public function get corner():Boolean {
        return _corner;
    }

    private var _baseLength: int;
    public function get baseLength():int {
        return _baseLength;
    }

    public function Match() {
        _cells = new <Cell>[];
    }

    public function addCell(cell: Cell):Boolean {
        if (cell.type && (!type || cell.type==type)) {
            if (!_type) {
                _type = cell.type;
            }
            if (cell.gem.match) {
                if (cell.gem.match.amount >= 3) {
                    _toConcat = cell.gem.match;
                }
            } else {
                cell.gem.match = this;
            }
            _cells.push(cell);
            return true;
        }
        return false;
    }

    public function concat(match: Match):void {
        _baseLength = amount;
        _corner = true;

        var l: int = match.amount;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = match.cells[i];
            if (_cells.indexOf(cell) < 0) {
                _cells.push(cell);
            }
        }
    }

    public function get score():int {
        if (amount==0) {
            return 0;
        }

        var m: MultiplierVO = MultiplierVO.MULTIPLIERS[amount];
        var points: int = GemVO.GEMS[type].points;
        return m.multiplier * points;
    }

    public function get counters():int {
        if (amount==0) {
            return 0;
        }

        var sum: int = 0;
        var l: int = amount;
        for (var i:int = 0; i < l; i++) {
            if (_cells[i].gem) {
                sum += 1 + _cells[i].gem.counter;
            }
        }
        return sum;
    }

    public function destroy():void {
        while (_cells.length>0) {
            var cell: Cell = _cells.pop();
            if (cell.gem) {
                cell.gem.match = null;
            }
        }
        _cells = null;

        _toConcat = null;
    }
}
}
