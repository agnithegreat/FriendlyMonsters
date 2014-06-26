/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 09.11.13
 * Time: 0:37
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.MultiplierVO;

public class Match {

    private var _iteration: int;
    public function get iteration():int {
        return _iteration;
    }

    private var _cells: Vector.<Cell>;
    public function get cells():Vector.<Cell> {
        return _cells;
    }

    public function get random():Cell {
        var randomGems: Vector.<Cell> = new <Cell>[];
        for (var i:int = 0; i < cells.length; i++) {
            if (!cells[i].gem.fixed) {
                randomGems.push(cells[i]);
            }
        }
        var rand: int = Math.random() * randomGems.length;
        return rand>0 ? randomGems[rand] : null;
    }

    public function get amount():int {
        return _cells ? _cells.length : 0;
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
        return _corner ? _baseLength : amount;
    }

    public function get multiplier():Number {
        return amount ? MultiplierVO.getMultiplier(amount).multiplier : 0;
    }

    public function Match(iteration: int) {
        _iteration = iteration;
        _cells = new <Cell>[];
    }

    public function addCell(cell: Cell):Boolean {
        if (cell.matchable && (!type || cell.type==type)) {
            if (!_type) {
                _type = cell.type;
            }
            if (cell.match) {
                if (cell.match.amount >= 3) {
                    _toConcat = cell.match.toConcat ? cell.match.toConcat : cell.match;
                }
            } else {
                cell.match = this;
            }
            _cells.push(cell);
            return true;
        }
        return false;
    }

    public function concat(match: Match):void {
        _baseLength = Math.max(amount, match.amount);
        _corner = true;

        var l: int = match.amount;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = match.cells[i];
            if (_cells.indexOf(cell) < 0) {
                cell.match = this;
                _cells.push(cell);
            }
        }
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

    public function getMoveCell(move: Move):Cell {
        if (!move) {
            return null;
        }

        if (_cells.indexOf(move.cell1)>=0) {
            return move.cell1;
        }
        if (_cells.indexOf(move.cell2)>=0) {
            return move.cell2;
        }
        return null;
    }

    public function getRandomCell():Cell {
        var rand: int = 1 + Math.random()*(_cells.length-2);
        return _cells[rand];
    }

    public function destroy():void {
        for (var i:int = 0; i < _cells.length; i++) {
            var cell: Cell = _cells[i];
            if (cell.match==this) {
                cell.match = null;
            }
        }
        _cells = null;

        _toConcat = null;
    }
}
}
