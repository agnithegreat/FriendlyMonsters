/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:03
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.BonusVO;
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

    private static var width: int = 8;
    private static var height: int = 8;

    private var _fieldObj: Object;
    private var _field: Vector.<Cell>;
    public function get field():Vector.<Cell> {
        return _field;
    }

    private var _availableMoves: Vector.<Move>;
    private var _matches: Vector.<Match>;

    private var _selectedCell: Cell;

    private var _possibleMatch: Vector.<Gem>;

    private var _score: int;
    public function get score():int {
        return _score;
    }

    private var _gemTypes: GemTypesList;
    public function getRandom(fall: Boolean):Gem {
        return new Gem(_gemTypes.getRandom(), fall);
    }

    private var _counters: CountersList;
    public function get counters():CountersList {
        return _counters;
    }

    private var _bonuses: BonusesList;
    public function get bonuses():BonusesList {
        return _bonuses;
    }

    private var _selectedBonus: String;

    private var _time: Number;
    private var _hintTime: Number;

    private var _juggler: Juggler;

    private var _delayedCalls: int;
    public function get busy():Boolean {
        return _delayedCalls>0;
    }

    public function Game() {
        _juggler = new Juggler();

        _gemTypes = new GemTypesList();
        _counters = new CountersList();
        _bonuses = new BonusesList();
    }

    public function init(data: Object):void {
        _score = 0;

        _gemTypes.init(data.types);

        // TODO: вынести ресурсы в конфиг
        _counters.addCounter(GemVO.GEMS[1].type, 50);
        _counters.addCounter(GemVO.GEMS[2].type, 50);
        _counters.addCounter(GemVO.GEMS[3].type, 50);

        _bonuses.addBonus(BonusVO.BONUSES[1].name);
        _bonuses.addBonus(BonusVO.BONUSES[2].name);
        _bonuses.addBonus(BonusVO.BONUSES[3].name);
        _bonuses.addBonus(BonusVO.BONUSES[4].name);
        _bonuses.addBonus(BonusVO.BONUSES[5].name);

        _time = 0;
        _hintTime = 0;

        _delayedCalls = 0;

        _matches = new <Match>[];
        _possibleMatch = new <Gem>[];

        createField(data.cells);

        fillGems(data.gems);

        findMatches();
        while (_matches.length==0) {
            clearMatches();
            shuffleField();
            findMatches();
        }
        while (_matches.length>0) {
            fixMatches();
            findMatches();
        }
        clearMatches();

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

    private function createField(cells: Array):void {
        _field = new <Cell>[];
        _fieldObj = {};

        for (var j:int = 0; j < height; j++) {
            for (var i:int = 0; i < width; i++) {
                var slot: Cell = new Cell(i, j, cells[j*width + i]);

                _field.push(slot);
                _fieldObj[i+"."+j] = slot;
            }
        }
    }

    private function findMoves():void {
        _availableMoves = new <Move>[];
        for (var i:int = 0; i < _field.length; i++) {
            var cell: Cell = _field[i];
            if (cell.x < width-2) {
                _availableMoves = _availableMoves.concat(checkTriple([cell, getCell(cell.x+1, cell.y), getCell(cell.x+2, cell.y)]));
            }
            if (cell.y < height-2) {
                _availableMoves = _availableMoves.concat(checkTriple([cell, getCell(cell.x, cell.y+1), getCell(cell.x, cell.y+2)]));
            }
        }
    }

    private function checkTriple(cells: Array):Vector.<Move> {
        var moves: Vector.<Move> = new <Move>[];

        if (!cells[0].type || !cells[1].type || !cells[2].type) {
            return moves;
        }

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
        clearMatches();
        move.trySwap();
    }

    private function hideHint():void {
        _hintTime = 0;
        while (_possibleMatch.length > 0) {
            _possibleMatch.pop().light = false;
        }
    }

    public function selectBonus(name: String):void {
        if (busy) {
            return;
        }

        if (_selectedBonus == name) {
            _selectedBonus = null;
        } else {
            _selectedBonus = name;

            var bonus: Bonus = _bonuses.getBonus(name);
            if (bonus && bonus.instant) {
                useBonus(name);
            }
        }
    }

    public function useBonus(name: String, cell: Cell = null):void {
        hideHint();

        var bonus: Bonus = _bonuses.getBonus(name);

        switch (name) {
            case BonusVO.REMOVE_GEM:
                if (cell.gem) {
                    addScore(cell.gem.points);
                    _counters.addValue(cell.type, cell.gem.counter+1);
                    cell.clear();
                    delayedCall(fallGems, Gem.FALL_TIME);
                    _selectedBonus = null;
                }
                break;

            case BonusVO.REMOVE_ROW:
                for (var i:int = 0; i < width; i++) {
                    var c: Cell = getCell(i, cell.y);
                    if (c.gem) {
                        addScore(c.gem.points);
                        _counters.addValue(c.type, c.gem.counter+1);
                        c.clear();
                    }
                }
                delayedCall(fallGems, Gem.FALL_TIME);
                _selectedBonus = null;
                break;

            case BonusVO.ADD_COUNTER:
                addCounters(bonus.counter);
                _selectedBonus = null;
                break;

            case BonusVO.REMOVE_TYPE:
                if (cell.type) {
                    removeGemsOfType(cell.type);
                    _selectedBonus = null;
                    delayedCall(fallGems, Gem.FALL_TIME);
                }
                break;

            case BonusVO.EMPTY:
                shuffleField();
                _selectedBonus = null;
                checkField();
                break;
        }
    }

    public function selectCell(cell: Cell):void {
        if (busy) {
            return;
        }

        if (_selectedBonus) {
            useBonus(_selectedBonus, cell);
            return;
        }

        if (!cell.gem || cell.block) {
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
        // TODO: сделать проверку на наличие ингредиентов в списке клеток выхода

        findMatches();
        if (_matches.length>0) {
            removeMatches(byUser);

            delayedCall(fallGems, Gem.KILL_TIME);
        } else {
            findMoves();

            if (_availableMoves.length==0) {
                delayedCall(shuffleField, Gem.KILL_TIME);
                delayedCall(checkField, Gem.KILL_TIME*2);
            }
        }
    }

    private function findMatches():void {
        clearMatches();

        // check vertical matches
        var match: Match;
        for (var i:int = 0; i < width; i++) {
            for (var j:int = 0; j < height; j++) {
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
        for (j = 0; j < height; j++) {
            for (i = 0; i < width; i++) {
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

    private function clearMatches():void {
        while (_matches.length > 0) {
            _matches.pop().destroy();
        }
    }

    private function fixMatches():void {
        while (_matches.length>0) {
            var match: Match = _matches.pop();
            var rand: int = Math.random() * match.cells.length;
            var change: Cell = match.cells[rand];
            match.destroy();

            var neighbours: Vector.<Cell> = getNeighbours(change);
            var swapped: Boolean = false;
            var l2: int = neighbours.length;
            for (var j:int = 0; j < l2; j++) {
                var neighbour: Cell = neighbours[j];
                if (!swapped && neighbour.type && neighbour.type != change.type) {
                    change.swap(neighbour, true);
                    swapped = true;
                }
            }
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
                addCounters(2, addTypeBonus[i]);
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

    private function addCounters(value: int, type: String = null):void {
        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (type) {
                if (cell.type == type) {
                    cell.gem.addCounter(value);
                }
            } else {
                if (_counters.hasCounter(cell.type)) {
                    cell.gem.addCounter(value);
                }
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

    private function fillGems(gems: Array):void {
        for (var i:int = 0; i < width; i++) {
            for (var j:int = 0; j < height; j++) {
                var cell: Cell = getCell(i, j);
                if (cell && cell.fillable) {
                    var g: int = gems[j*height+i];
                    var gem: Gem = g ? new Gem(g, false) : getRandom(false);
                    cell.setGem(gem);
                    dispatchEventWith(NEW_GEM, false, gem);
                }
            }
        }
    }

    private function fallGems():void {
        var refill: Boolean;

        for (var j:int = 1; j <= height; j++) {
            for (var i:int = 0; i < width; i++) {
                var cell: Cell = getCell(i, height-j);
                if (cell) {
                    if (cell.fillable) {
                        var upper: Cell = getCell(cell.x, cell.y-1);
                        var dropped: Boolean = false;
                        if (upper) {
                            if (upper.gem && upper.block==0) {
                                cell.swap(upper);

                                refill = true;
                                dropped = true;
                            } else {
                                while (upper && upper.fillable) {
                                    upper = getCell(upper.x, upper.y-1);
                                }
                                if (upper && (upper.block>0 || !upper.available)) {
                                    var side: Cell = getCell(cell.x-1, cell.y);
                                    if (side && !side.fillable) {
                                        upper = getCell(side.x, side.y-1);
                                        if (upper && upper.gem && upper.block==0) {
                                            cell.swap(upper);

                                            refill = true;
                                            dropped = true;
                                        }
                                    }
                                    if (!dropped) {
                                        side = getCell(cell.x+1, cell.y);
                                        if (side && !side.fillable) {
                                            upper = getCell(side.x, side.y-1);
                                            if (upper && upper.gem && upper.block==0) {
                                                cell.swap(upper);

                                                refill = true;
                                                dropped = true;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if (j==height) {
                            refill = true;
                        }
                    } else if (j==height) {
                        cell.swap(cell);
                    }
                }
            }
        }

        if (refill) {
            delayedCall(refillGems, Gem.FALL_TIME);
            delayedCall(fallGems, Gem.FALL_TIME);
        } else {
            delayedCall(checkField, Gem.FALL_TIME);
        }
    }

    private function refillGems():void {
        // TODO: заменить верхний ряд списком клеток входа
        for (var i:int = 0; i < width; i++) {
            var cell: Cell = getCell(i, 0);
            if (cell && cell.fillable) {
                var gem: Gem = getRandom(true);
                cell.setGem(gem);
                dispatchEventWith(NEW_GEM, false, gem);
            }
        }
    }

    private function shuffleField():void {
        var gems: Vector.<Gem> = new <Gem>[];

        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (cell.gem && !cell.block) {
                if (Math.random()<0.5) {
                    gems.push(cell.gem);
                } else {
                    gems.unshift(cell.gem);
                }
            }
        }

        for (i = 0; i < l; i++) {
            cell = _field[i];
            if (cell.gem && !cell.block) {
                if (Math.random()<0.5) {
                    cell.setGem(gems.pop());
                } else {
                    cell.setGem(gems.shift());
                }
            }
        }
    }

    private function addScore(value: int):void {
        _score += value;
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
