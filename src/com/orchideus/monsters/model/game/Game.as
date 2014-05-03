/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:03
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.GemVO;

import flash.geom.Point;

import starling.animation.Juggler;
import starling.core.Starling;
import starling.events.EventDispatcher;

public class Game extends EventDispatcher {

    public static const INIT: String = "init_Game";
    public static const NEW_GEM: String = "new_gem_Game";
    public static const UPDATE: String = "update_Game";
    public static const COMPLETED: String = "completed_Game";
    public static const CLEAR: String = "clear_Game";

    // TODO: вынести в конфиг
    public static var HINT_TIME: int = 5;

    private var _width: int;
    private var _height: int;

    private var _fieldObj: Object;
    private var _field: Vector.<Cell>;
    public function get field():Vector.<Cell> {
        return _field;
    }

    private var _availableMoves: Vector.<Move>;
    private var _matches: Vector.<Match>;

    private var _selectedCell: Cell;

    private var _possibleMatch: Vector.<Gem>;

//    private var _init: Boolean;

    private var _score: int;
    public function get score():int {
        return _score;
    }

    private var _counters: CountersList;
    public function get counters():CountersList {
        return _counters;
    }

    private var _time: Number;
    private var _hintTime: Number;

    private var _juggler: Juggler;

    private var _delayedCalls: int;
    public function get busy():Boolean {
        return _delayedCalls>0;
    }

    private var _afterFallStateChanged: Boolean;

    public function Game() {
        _juggler = new Juggler();

        _counters = new CountersList();
    }

    public function init(width: int, height: int):void {
        _width = width;
        _height = height;

        _score = 0;

        // TODO: вынести ресурсы в конфиг
        _counters.addCounter(GemVO.GEMS[1].type, 50);
        _counters.addCounter(GemVO.GEMS[2].type, 50);
        _counters.addCounter(GemVO.GEMS[3].type, 50);

        _time = 0;
        _hintTime = 0;

        _delayedCalls = 0;

        _matches = new <Match>[];
        _possibleMatch = new <Gem>[];

        createField();

        fillGems();

        findMatches();
        while (_matches.length>0) {
            fixMatches();
            findMatches();
        }
        findMoves();

        dispatchEventWith(INIT);

        Starling.juggler.add(_juggler);
    }

    public function clear():void {
        _counters.clear();

        dispatchEventWith(CLEAR);

        _fieldObj = null;

        while (_field.length>0) {
            var cell: Cell = _field.pop();
            cell.clear();
        }
        _field = null;

        _availableMoves = null;
        _matches = null;
        _selectedCell = null;
        _possibleMatch = null;

        Starling.juggler.remove(_juggler);
    }

    private function delayedCall(call: Function, delay: Number, ...params):void {
        _delayedCalls++;
        _juggler.delayCall(delayedCallFinal, delay, call, params);
    }

    private function delayedCallFinal(call: Function, params: Array):void {
        _delayedCalls--;
        if (params.length>0) {
            call.apply(this, params);
        } else {
            call();
        }
    }

    private function createField():void {
        _field = new <Cell>[];
        _fieldObj = {};
        for (var j:int = 0; j < _height; j++) {
            for (var i:int = 0; i < _width; i++) {
                var slot: Cell = new Cell(i, j);

                if (Math.random() < 0.3) {
                    slot.block = Math.random() * 4;
                }

                _field.push(slot);
                _fieldObj[i+"."+j] = slot;
            }
        }
    }

    private function findMoves():void {
        _availableMoves = new <Move>[];
        for (var i:int = 0; i < _field.length; i++) {
            var cell: Cell = _field[i];
            if (cell.x < _width-2) {
                _availableMoves = _availableMoves.concat(checkTriple([cell, getCell(cell.x+1, cell.y), getCell(cell.x+2, cell.y)]));
            }
            if (cell.y < _height-2) {
                _availableMoves = _availableMoves.concat(checkTriple([cell, getCell(cell.x, cell.y+1), getCell(cell.x, cell.y+2)]));
            }
        }
    }

    private function checkTriple(cells: Array):Vector.<Move> {
        cells.sortOn("type");

        var excess: Cell;
        if (cells[0].type != cells[1].type) {
            excess = cells[0];
        }
        if (cells[1].type != cells[2].type) {
            if (!excess) {
                excess = cells[2];
            } else {
                excess = null;
            }
        }

        var moves: Vector.<Move> = new <Move>[];
        if (excess && excess.block==0) {
            var neighbours: Vector.<Cell> = getNeighbours(excess);
            for (var i:int = 0; i < neighbours.length; i++) {
                var neighbour: Cell = neighbours[i];
                if (neighbour.block==0) {
                    if (cells.indexOf(neighbour)<0 && cells[1].type==neighbour.type) {
                        moves.push(new Move(excess, neighbour));
                    }
                }
            }
        }
        return moves;
    }

    private function showHint():void {
        if (_possibleMatch.length > 0) {
            return;
        }

        var rand: int = Math.random() * _availableMoves.length;
        var move: Move = _availableMoves[rand];

        move.trySwap();
        findMatches();
        var match: Match = _matches[0];
        for (var i:int = 0; i < match.cells.length; i++) {
            var gem: Gem = match.cells[i].gem;
            gem.light = true;
            _possibleMatch.push(gem);
        }
        move.trySwap();
    }

    private function hideHint():void {
        _hintTime = 0;
        while (_possibleMatch.length > 0) {
            _possibleMatch.pop().light = false;
        }
    }

    public function selectCell(cell: Cell):void {
        if (busy) {
            return;
        }

        if (cell.block) {
            return;
        }

        if (_selectedCell) {
            _selectedCell.select(false);

            var distance: Number = Point.distance(_selectedCell.position, cell.position);
            if (distance > 1) {
                _selectedCell = cell;
                _selectedCell.select(true);
            } else if (distance == 1) {
                checkSwap(_selectedCell, cell);
                _selectedCell = null;
            }
        } else {
            _selectedCell = cell;
            _selectedCell.select(true);
        }
    }

    private function checkSwap(cell1: Cell, cell2: Cell):void {
        hideHint();

        for (var i:int = 0; i < _availableMoves.length; i++) {
            var move: Move = _availableMoves[i];
            if (move.check(cell1, cell2)) {
                cell1.swap(cell2);
                delayedCall(checkField, Gem.SWAP_TIME, true);
                return;
            }
        }

        cell1.swap(cell2);
        delayedCall(cell2.swap, Gem.SWAP_TIME, cell1);
    }

    private function checkField(byUser: Boolean = false):void {
        findMatches();
        if (_matches.length>0) {
            removeMatches(byUser);

            _afterFallStateChanged = false;
            delayedCall(fallGems, Gem.KILL_TIME, _height-1);
        } else {
            findMoves();

            if (_availableMoves.length==0) {
                resetField();
            }
        }
    }

    private function findMatches():void {
        while (_matches.length > 0) {
            _matches.pop().destroy();
        }

        // check vertical matches
        var match: Match;
        for (var i:int = 0; i < _width; i++) {
            for (var j:int = 0; j < _height; j++) {
                var cell: Cell = getCell(i, j);
                if (match && !match.addCell(cell)) {
                    if (match.amount >= 3) {
                        _matches.push(match);
                    } else {
                        match.destroy();
                    }
                    match = null;
                }
                if (!match) {
                    match = new Match();
                    match.addCell(cell);
                }
            }
            if (match.amount >= 3) {
                _matches.push(match);
            } else {
                match.destroy();
            }
            match = null;
        }

        // check horizontal matches
        for (j = 0; j < _height; j++) {
            for (i = 0; i < _width; i++) {
                cell = getCell(i, j);
                if (match && !match.addCell(cell)) {
                    if (match.amount >= 3) {
                        _matches.push(match);
                    } else {
                        match.destroy();
                    }
                    match = null;
                }
                if (!match) {
                    match = new Match();
                    match.addCell(cell);
                }
            }
            if (match.amount >= 3) {
                _matches.push(match);
            } else {
                match.destroy();
            }
            match = null;
        }

        var l: int = _matches.length;
        for (i = 0; i < l; i++) {
            match = _matches[i];
            if (match.toConcat) {
                match.toConcat.concat(match);
                _matches.splice(i--, 1);
                l--;
            }
        }
    }

    private function fixMatches():void {
        for (var i:int = 0; i < _matches.length; i++) {
            var match: Match = _matches[i];
            match.cells[1].setGem(Gem.getRandom(false));
        }
    }

    private function removeMatches(byUser: Boolean = false):void {
        var simpleCounterGems: Vector.<Gem> = new <Gem>[];
        var fourCounterGems: Vector.<Gem> = new <Gem>[];
        var addTypeBonus: Vector.<String> = new <String>[];
        var removeTypeBonus: Vector.<String> = new <String>[];

        var clear: Vector.<Cell> = new <Cell>[];
        while (_matches.length>0) {
            var match: Match = _matches.pop();
            addScore(match.score);
            _counters.addValue(match.type, match.counters);

            var nearGems: Vector.<Gem> = getNearGems(match);
            simpleCounterGems = simpleCounterGems.concat(nearGems);

            if (match.corner) {
                if (match.baseLength >= 5 || match.amount-match.baseLength >= 4) {
                    removeTypeBonus.push(match.type);
                } else {
                    addTypeBonus.push(match.type);
                }
            } else if (match.amount>=5) {
                removeTypeBonus.push(match.type);
            } else if (match.amount==4) {
                fourCounterGems = fourCounterGems.concat(nearGems);
            }

            var l: int = match.amount;
            for (var j:int = 0; j < l; j++) {
                var matchCell: Cell = match.cells[j];
                if (clear.indexOf(matchCell) < 0) {
                    clear.push(matchCell);
                    matchCell.clear();
                }
            }
        }

        if (byUser) {
            removeCounters();
        }

        l = simpleCounterGems.length;
        for (var i:int = 0; i < l; i++) {
            // TODO: вынести каунтеры в конфиг
            if (_counters.hasCounter(simpleCounterGems[i].type)) {
                simpleCounterGems[i].addCounter(byUser ? 2 : 1);
            }
        }

        l = fourCounterGems.length;
        for (i = 0; i < l; i++) {
            // TODO: вынести каунтеры в конфиг
            if (_counters.hasCounter(fourCounterGems[i].type)) {
                fourCounterGems[i].addCounter(1);
            }
        }

        l = addTypeBonus.length;
        for (i = 0; i < l; i++) {
            // TODO: вынести каунтеры в конфиг
            if (_counters.hasCounter(addTypeBonus[i])) {
                addCountersOfType(addTypeBonus[i], 2);
            }
        }

        l = removeTypeBonus.length;
        for (i = 0; i < l; i++) {
            removeGemsOfType(removeTypeBonus[i]);
        }

        findMoves();
    }

    private function removeCounters():void {
        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var gem: Gem = _field[i].gem;
            if (gem) {
                gem.resetCounter();
            }
        }
    }

    private function addCountersOfType(type: String, value: int):void {
        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (cell.type == type) {
                cell.gem.addCounter(value);
            }
        }
    }

    private function removeGemsOfType(type: String):void {
        var counters: int = 0;
        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (cell.type == type) {
                counters += cell.gem.counter+1;
                cell.clear();
            }
        }
        _counters.addValue(type, counters);
    }

    private function fillGems():void {
        if (!_field) {
            return;
        }

        for (var i:int = 0; i < _width; i++) {
            for (var j:int = 0; j < _height; j++) {
                var cell: Cell = getCell(i, j);
                if (!cell.gem) {
                    var gem: Gem = Gem.getRandom(false);
                    cell.setGem(gem);
                    dispatchEventWith(NEW_GEM, false, gem);
                }
            }
        }
    }

    private function fallGems(row: int, retry: Boolean = false):void {
        if (!_field) {
            return;
        }

        var fall: Boolean;
        var refill: Boolean;

        for (var i:int = 0; i < _width; i++) {
            var cell: Cell = getCell(i, row);
            var upper: Cell = cell;
            if (!cell.gem) {
                var swapped: Boolean = false;
                while (upper && !upper.gem) {
                    upper = getCell(upper.x, upper.y-1);
                }
                if (upper && upper.block==0) {
                    cell.swap(upper);

                    fall = true;
                    swapped = true;
                } else {
                    var side: Cell = getCell(cell.x-1, cell.y);
                    if (side && side.gem) {
                        upper = getCell(side.x, side.y-1);
                        if (upper && upper.gem && upper.block==0) {
                            cell.swap(upper);

                            fall = true;
                            swapped = true;
                        }
                    }
                    if (!swapped) {
                        side = getCell(cell.x+1, cell.y);
                        if (side && side.gem) {
                            upper = getCell(side.x, side.y-1);
                            if (upper && upper.gem && upper.block==0) {
                                cell.swap(upper);

                                fall = true;
                                swapped = true;
                            }
                        }
                    }
                }

                refill = true;
            } else if (row==0) {
                cell.swap(cell);
            }
        }

        if (fall) {
            _afterFallStateChanged = true;

            delayedCall(refillGems, Gem.FALL_TIME);

            var under: Cell = getCell(cell.x, cell.y+1);
            if (under && !under.gem) {
                delayedCall(fallGems, Gem.FALL_TIME, row+1);
            } else {
                delayedCall(fallGems, Gem.FALL_TIME, row-1);
            }
        } else {
            if (refill && !retry) {
                delayedCall(refillGems, Gem.FALL_TIME);
                delayedCall(fallGems, Gem.FALL_TIME, row, true);
            } else if (row>0) {
                fallGems(row-1);
            } else if (_afterFallStateChanged) {
                _afterFallStateChanged = false;
                fallGems(_height-1);
            } else {
                delayedCall(checkField, Gem.FALL_TIME);
            }
        }
    }

    private function refillGems():void {
        if (!_field) {
            return;
        }

        for (var i:int = 0; i < _width; i++) {
            var cell: Cell = getCell(i, 0);
            if (!cell.gem) {
                var gem: Gem = Gem.getRandom(true);
                cell.setGem(gem);
                dispatchEventWith(NEW_GEM, false, gem);
            }
        }
    }

    private function addScore(value: int):void {
        _score += value;
    }

    private function resetField():void {
        for (var i:int = 0; i < _field.length; i++) {
            var cell: Cell = _field[i];
            if (!cell.block) {
                cell.clear();
            }
        }

        delayedCall(fallGems, Gem.KILL_TIME, _height-1);
    }

    private function getCell(x: int, y: int):Cell {
        return _fieldObj[x+"."+y];
    }

    private function getNeighbours(cell: Cell):Vector.<Cell> {
        var neighbours: Vector.<Cell> = new <Cell>[];
        for (var i:int = -1; i <= 1; i++) {
            for (var j:int = -1; j <= 1; j++) {
                if (Math.abs(i)+Math.abs(j)==1) {
                    var neighbour: Cell = getCell(cell.x+i, cell.y+j);
                    if (neighbour) {
                        neighbours.push(neighbour);
                    }
                }
            }
        }
        return neighbours;
    }

    private function getNearGems(match: Match):Vector.<Gem> {
        var near: Vector.<Gem> = new <Gem>[];
        var l: int = match.amount;
        for (var i:int = 0; i < l; i++) {
            var neighbours: Vector.<Cell> = getNeighbours(match.cells[i]);
            var l2: int = neighbours.length;
            for (var j:int = 0; j < l2; j++) {
                var gem: Gem = neighbours[j].gem;
                if (gem && near.indexOf(gem)<0) {
                    near.push(gem);
                }
            }
        }
        return near;
    }

    public function step(delta: Number):void {
        _time += delta;

        if (_delayedCalls==0 && _possibleMatch.length==0) {
            _hintTime += delta;

            if (_hintTime >= HINT_TIME) {
                showHint();
            }
        }

        dispatchEventWith(UPDATE);
    }
}
}
