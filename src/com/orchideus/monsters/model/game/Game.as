/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 08.11.13
 * Time: 21:03
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.BlockVO;
import com.orchideus.monsters.data.BonusVO;
import com.orchideus.monsters.data.CountersVO;
import com.orchideus.monsters.data.DecorVO;
import com.orchideus.monsters.data.EffectVO;
import com.orchideus.monsters.data.GemVO;
import com.orchideus.monsters.data.IngredientVO;
import com.orchideus.monsters.data.TimingVO;

import flash.geom.Point;

import starling.animation.Juggler;
import starling.core.Starling;
import starling.events.Event;
import starling.events.EventDispatcher;

public class Game extends EventDispatcher {

    public static const INIT: String = "init_Game";
    public static const NEW_GEM: String = "new_gem_Game";
    public static const UPDATE: String = "update_Game";
    public static const EFFECT: String = "effect_Game";
    public static const COMPLETED: String = "completed_Game";
    public static const CLEAR: String = "clear_Game";

    private static var width: int = 8;
    private static var height: int = 8;

    private var _background: String;
    public function get background():String {
        return _background;
    }

    private var _fieldObj: Object;
    private var _field: Vector.<Cell>;
    public function get field():Vector.<Cell> {
        return _field;
    }

    private var _enterCells: Vector.<Cell>;
    private var _exitCells: Vector.<Cell>;

    private var _decors: Vector.<Decor>;
    public function get decors():Vector.<Decor> {
        return _decors;
    }

    private var _availableMoves: Vector.<Move>;
    private var _matches: Vector.<Match>;

    private var _selectedCell: Cell;

    private var _score: Number;
    public function get score():int {
        return _score;
    }

    private var _gemTypes: GemTypesList;
    public function getRandom(fall: Boolean, allowIngredient: Boolean):Gem {
        if (allowIngredient) {
            var ingredient:Ingredient = _ingredients.releaseIngredient();
            if (ingredient) {
                return ingredient;
            }
        }

        var rand: int = _gemTypes.getRandom();
        var collectable: Boolean = _counters.hasCounter(GemVO.GEMS[rand].type);
        var gem: Gem = new Gem(rand, fall, collectable, false);
        gem.addEventListener(Gem.KILL, handleAddFruit);
        return gem;
    }

    private var _counters: CountersList;
    public function get counters():CountersList {
        return _counters;
    }

    private var _ingredients: IngredientsList;

    private var _starsConditions: Array;

    public function get conditions():Array {
        return _starsConditions;
    }

    public function get progress():int {
        return _counters.progress;
    }
    public function get stars():int {
        var progress: int = _counters.progress;
        return progress>=_starsConditions[2] ? 3 : (progress>=_starsConditions[1] ? 2 : (progress>=_starsConditions[0] ? 1 : 0));
    }

    public function get win():Boolean {
        return _counters.success;
    }

    private var _bonuses: BonusesList;
    public function get bonuses():BonusesList {
        return _bonuses;
    }

    private var _selectedBonus: String;

    private var _moves: int;
    public function get moves():int {
        return _moves;
    }

    private var _time: Number;
    private var _hintTime: Number;
    private var _hintMatch: Vector.<Gem>;

    private var _juggler: Juggler;

    private var _delayedCalls: int;
    public function get busy():Boolean {
        return _delayedCalls>0;
    }

    private var _started: Boolean;
    public function get started():Boolean {
        return _started;
    }

    public function Game() {
        _juggler = new Juggler();

        _gemTypes = new GemTypesList();
        _counters = new CountersList();
        _ingredients = new IngredientsList();
        _bonuses = new BonusesList();
    }

    public function init(data: Object):void {
        _score = 0;

        _background = data.background;

        _moves = data.moves;
        _starsConditions = data.stars;

        _gemTypes.init(data.types);

        setCounters(data.counters);

        _ingredients.init(data.fruits);
        setIngredients(data.ingredients);

        setBlocks(data.blocks);

        _bonuses.addBonus(BonusVO.BONUSES[1].name);
        _bonuses.addBonus(BonusVO.BONUSES[2].name);
        _bonuses.addBonus(BonusVO.BONUSES[3].name);
        _bonuses.addBonus(BonusVO.BONUSES[4].name);
//        _bonuses.addBonus(BonusVO.BONUSES[5].name);

        _time = 0;
        _hintTime = 0;
        _hintMatch = new <Gem>[];

        _delayedCalls = 0;

        _matches = new <Match>[];

        createField(data.cells);

        _decors = new <Decor>[];
        addDecors(data.decors);

        fillGems(data.gems);

        findMatches();
//        while (_matches.length==0) {
//            clearMatches();
//            shuffleField();
//            findMatches();
//        }
        while (_matches.length>0) {
            fixMatches();
            findMatches();
        }
        clearMatches();

        findMoves();

        _started = true;

        dispatchEventWith(INIT);

        Starling.juggler.add(_juggler);
    }

    public function clear():void {
        while (_decors.length>0) {
            removeDecor(_decors[0]);
        }
        
        _counters.clear();
        _ingredients.clear();

        _bonuses.clear();

        dispatchEventWith(CLEAR);

        _fieldObj = null;

        _enterCells = null;
        _exitCells = null;

        while (_field.length>0) {
            var cell: Cell = _field.pop();
            cell.clear();
        }
        _field = null;

        _availableMoves = null;
        _matches = null;
        _selectedCell = null;

        _started = false;

        _juggler.purge();
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

        _enterCells = new <Cell>[];
        _exitCells = new <Cell>[];

        for (var j:int = 0; j < height; j++) {
            for (var i:int = 0; i < width; i++) {
                var cell: Cell = new Cell(i, j, cells[j*width + i]);

                if (cell.enter) {
                    _enterCells.push(cell)
                }
                if (cell.exit) {
                    _exitCells.push(cell);
                }

                _field.push(cell);
                _fieldObj[i+"."+j] = cell;
            }
        }
    }

    private function addDecor(decor: Decor):void {
        var d: DecorVO = decor.decor;
        for (var i:int = 0; i < d.size[0]; i++) {
            for (var j:int = 0; j < d.size[1]; j++) {
                var cell: Cell = getCell(decor.position.x+i, decor.position.y+j);
                if (cell.decor) {
                    removeDecor(cell.decor);
                }
                cell.decor = decor;
            }
        }
        _decors.push(decor);
    }

    private function removeDecor(decor: Decor):void {
        var d: DecorVO = decor.decor;
        for (var i:int = 0; i < d.size[0]; i++) {
            for (var j:int = 0; j < d.size[1]; j++) {
                var cell: Cell = getCell(decor.position.x+i, decor.position.y+j);
                cell.decor = null;
            }
        }
        _decors.splice(_decors.indexOf(decor), 1);
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

        if (!cells[1].matchable) {
            return moves;
        }

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
        while (_hintMatch.length == 0) {
            var rand:int = Math.random() * _availableMoves.length;
            var move:Move = _availableMoves[rand];

            move.trySwap();
            findMatches();
            if (_matches.length>0) {
                var match:Match = _matches[0];
                for (var i:int = 0; i < match.cells.length; i++) {
                    _hintMatch.push(match.cells[i].gem);
                }
            }
            clearMatches();
            move.trySwap();
        }

        for (i = 0; i < _hintMatch.length; i++) {
            Starling.juggler.delayCall(_hintMatch[i].hint, Math.random() * 0.3);
        }

        _hintTime = 0;
    }

    public function selectBonus(name: String):void {
        if (busy) {
            return;
        }

        selectCell(null);

        if (_selectedBonus) {
            _bonuses.getBonus(_selectedBonus).selected = false;
        }

        if (_selectedBonus == name) {
            _selectedBonus = null;
        } else {
            _selectedBonus = name;

            var bonus: Bonus = _bonuses.getBonus(name);
            if (bonus) {
                bonus.selected = true;
                if (bonus.instant) {
                    useBonus(name);
                }
            }
        }
    }

    public function useBonus(name: String, cell: Cell = null):void {
        var bonus: Bonus = _bonuses.getBonus(name);

        switch (name) {
            case BonusVO.REMOVE_GEM:
                if (cell.matchable) {
                    removeGem(cell);
                    delayedCall(fallGems, TimingVO.kill);

                    bonus.selected = false;
                    _selectedBonus = null;
                }
                break;

            case BonusVO.ADD_COUNTER:
                addCounters(_field, bonus.counter);

                bonus.selected = false;
                _selectedBonus = null;
                break;

            case BonusVO.REMOVE_ROW:
                if (cell.matchable) {
                    for (var i:int = 0; i < width; i++) {
                        var c:Cell = getCell(i, cell.y);
                        if (c.matchable) {
                            removeGem(c);
                        }
                    }
                    delayedCall(fallGems, TimingVO.kill);

                    bonus.selected = false;
                    _selectedBonus = null;
                }
                break;

            case BonusVO.REMOVE_TYPE:
                if (cell.matchable) {
                    clearCells(getGemsOfType(cell.type));
                    delayedCall(fallGems, TimingVO.kill);

                    bonus.selected = false;
                    _selectedBonus = null;
                }
                break;
        }
    }

    public function selectCell(cell: Cell):void {
        if (busy || _moves==0) {
            return;
        }

        if (!cell) {
            if (_selectedCell) {
                _selectedCell.select(false);
                _selectedCell = null;
            }
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
            } else {
                _selectedCell = null;
            }
        } else {
            _selectedCell = cell;
            _selectedCell.select(true);
        }
    }

    private function checkSwap(cell1: Cell, cell2: Cell):void {
        for (var i:int = 0; i < _availableMoves.length; i++) {
            var move: Move = _availableMoves[i];
            if (move.check(cell1, cell2)) {
                cell1.swap(cell2);
                delayedCall(checkField, TimingVO.swap+TimingVO.feedback, move);
                return;
            }
        }

        cell1.swap(cell2);
        delayedCall(cell2.swap, TimingVO.swap+TimingVO.feedback, cell1);
    }

    private function checkField(move: Move = null):void {
        if (move) {
            _moves--;
        }

        var toUpdate: Boolean = checkIngredients();

        findMatches();
        if (_matches.length>0) {
            _matches.sort(sortOnAmount);
            if (move && !win) {
                removeCounters();
            }
            removeMatches(move);
        } else if (toUpdate) {
            delayedCall(fallGems, TimingVO.kill);
        } else if (_moves==0) {
            delayedCall(complete, TimingVO.end_game);
        } else {
            findMoves();

            if (_availableMoves.length==0) {
                delayedCall(shuffleField, TimingVO.kill);
                delayedCall(checkField, TimingVO.kill+TimingVO.swap+TimingVO.feedback);
            } else {
                _hintTime = 0;
                _hintMatch.length = 0;
            }
        }
    }

    private function complete():void {
        dispatchEventWith(COMPLETED);
    }

    private function checkIngredients():Boolean {
        for (var i:int = 0; i < _exitCells.length; i++) {
            if (_exitCells[i].gem is Ingredient) {
                _counters.addValue(_exitCells[i].gem.type, 1);
                _exitCells[i].clear();
                return true;
            }
        }
        return false;
    }

    private var _iteration: int = 0;
    private function findMatches():void {
        clearMatches();

        _iteration++;

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
                    match = new Match(_iteration);
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
                    match = new Match(_iteration);
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
                match.destroy();
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
            var change: Cell = match.random;
            if (change) {
                change.removeGem();
                change.setGem(getRandom(false, false));
            }
            match.destroy();
        }
    }

    private function sortOnAmount(match1: Match, match2: Match):int {
        if (match1.baseLength > match2.baseLength) {
            return -1;
        }
        if (match1.baseLength < match2.baseLength) {
            return 1;
        }
        return 0;
    }

    private function removeMatches(move: Move = null):void {
        while (_matches.length>0) {
            var match: Match = _matches.pop();

            var nearGems: Vector.<Cell> = getNearGems(match);

            var counterTarget: Cell = move ? match.getMoveCell(move) : match.getRandomCell();

            if (match.baseLength>=5) {
//                showEffect(EffectVO.GEM_REMOVE_5, counterTarget, match.cells);

                var cells: Vector.<Cell> = getGemsOfType(match.type);
                addCounters(cells, CountersVO.remove_5, match.type, counterTarget);
                delayedCall(clearCells, TimingVO.counter, cells);
            } else if (match.corner) {
//                showEffect(EffectVO.GEM_REMOVE_CORNER, counterTarget, match.cells);

                addCounters(_field, CountersVO.remove_corner, match.type, counterTarget);
            } else if (match.amount==4) {
//                showEffect(EffectVO.GEM_REMOVE_4, counterTarget, match.cells);

                addCounters(nearGems, CountersVO.remove_4, null, counterTarget);
            } else if (match.amount==3) {
                if (move) {
//                    showEffect(EffectVO.GEM_REMOVE_3, counterTarget, match.cells);
                }

                addCounters(nearGems, move ? CountersVO.remove_3_move : CountersVO.remove_3, null, counterTarget);
            }

            delayedCall(clearCells, TimingVO.counter, match.cells);
            match.destroy();
        }
    }

    private function clearCells(cells: Vector.<Cell>):void {
        var blocks: Vector.<Cell> = new <Cell>[];
        while (cells.length > 0) {
            var cell: Cell = cells.shift();
            var neighbours: Vector.<Cell> = getNeighbours(cell);
            for (var i:int = 0; i < neighbours.length; i++) {
                var neighbour: Cell = neighbours[i];
                if (blocks.indexOf(neighbour)<0 && neighbour.blockIsInner) {
                    blocks.push(neighbour);
                    removeGem(neighbour);
                }
            }
            removeGem(cell);
        }

        delayedCall(fallGems, TimingVO.kill);
    }

    private function removeGem(cell: Cell):void {
        if (cell.block) {
            if (cell.block==1) {
                _counters.addValue(cell.blockType, 1);
            }
            cell.damageBlock();
        } else if (cell.gem) {
            showEffect(EffectVO.GEM_REMOVE, cell, new <Cell>[cell]);

            _counters.addValue(cell.gem.type, cell.gem.counter + 1);

            var m: Number = cell.match ? cell.match.multiplier : 1;
            addScore(m * cell.gem.points);
            cell.removeGem();
        }
    }

    private function removeCounters():void {
        var l:int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var gem:Gem = _field[i].gem;
            if (gem && !gem.cell.match) {
                gem.resetCounter();
            }
        }
    }

    private function addCounters(cells: Vector.<Cell>, value: int, type: String = null, from: Cell = null):void {
        var l: int = cells.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = cells[i];
            if (cell.gem && !cell.match) {
                if (type) {
                    if (cell.type == type) {
                        cell.gem.addCounter(value, from);
                    }
                } else {
                    if (_counters.hasCounter(cell.type)) {
                        cell.gem.addCounter(value, from);
                    }
                }
            }
        }
    }

    private function getGemsOfType(type: String):Vector.<Cell> {
        var cells: Vector.<Cell> = new <Cell>[];
        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (cell.type == type) {
                cells.push(cell);
            }
        }
        return cells;
    }

    private function setCounters(counters: Array):void {
        for (var i:int = 0; i < counters.length; i++) {
            _counters.addCounter(GemVO.GEMS[counters[i].id].type, counters[i].amount);
        }
    }

    private function setIngredients(ingredients: Array):void {
        for (var i:int = 0; i < ingredients.length; i++) {
            _counters.addCounter(IngredientVO.INGREDIENTS[ingredients[i].id].name, ingredients[i].amount);
            _ingredients.add(ingredients[i]);
        }
    }

    private function setBlocks(blocks: Array):void {
        for (var i:int = 0; i < blocks.length; i++) {
            _counters.addCounter(BlockVO.BLOCKS[blocks[i].id].name, blocks[i].amount);
        }
    }

    private function addDecors(decors: Array):void {
        var l: int = decors.length;
        for (var i:int = 0; i < l; i++) {
            var decor: Object = decors[i];
            addDecor(new Decor(decor.type, decor.position.x, decor.position.y));
        }
    }

    private function fillGems(gems: Array):void {
        for (var i:int = 0; i < width; i++) {
            for (var j:int = 0; j < height; j++) {
                var cell: Cell = getCell(i, j);
                var data: Object = gems[j*height+i];
                if (cell && cell.available && data) {
                    var g: int = data.id;
                    var collectable: Boolean = g ? _counters.hasCounter(GemVO.GEMS[g].type) : false;
                    var gem: Gem = g ? new Gem(g, false, collectable, true) : getRandom(false, false);
                    cell.setGem(gem);
                    dispatchEventWith(NEW_GEM, false, gem);
                }
            }
        }
    }

    private function fallGems():void {
        var refill: Boolean = false;

        var rows: Array = new Array(width);

        for (var j:int = 1; j <= height; j++) {
            for (var i:int = 0; i < width; i++) {
                if (!rows[i]) {
                    rows[i] = 0;
                }

                var cell: Cell = getCell(i, height-j);
                if (cell) {
                    if (cell.fillable) {
                        if (cell.available && !cell.enter) {
                            rows[i]++;
                        }

                        var upper: Cell = getCell(cell.x, cell.y-1);
                        var dropped: Boolean = false;
                        if (upper && rows[i]>0) {
                            if (upper.gem && upper.block==0) {
                                cell.fall(upper);
                                rows[i]--;

                                dropped = true;
                            } else if (cell.available) {
                                var enter: Boolean = false;
                                while (upper && upper.block==0 && !upper.decor) {
                                    if (upper.enter) {
                                        enter = true;
                                    }
                                    upper = getCell(upper.x, upper.y-1);
                                }
                                if (upper && upper.block>0 || !enter) {
                                    var side: Cell = getCell(cell.x-1, cell.y);
                                    var sideUpper: Cell;
                                    if (side && !side.fillable) {
                                        sideUpper = getCell(side.x, side.y-1);
                                        if (sideUpper && sideUpper.gem && sideUpper.block==0) {
                                            cell.fall(sideUpper);
                                            rows[i]--;

                                            dropped = true;
                                        }
                                    }
                                    if (!dropped) {
                                        side = getCell(cell.x+1, cell.y);
                                        if (side && !side.fillable) {
                                            sideUpper = getCell(side.x, side.y-1);
                                            if (sideUpper && sideUpper.gem && sideUpper.block==0) {
                                                cell.fall(sideUpper);
                                                rows[i]--;

                                                dropped = true;
                                            }
                                        }
                                    }
                                    if (!dropped && upper && (upper.block>0 || upper.decor)) {
                                        rows[i] = 0;
                                    }
                                }
                            }
                        }
                        if (dropped) {
                            refill = true;
                        }
                    }
                }
            }
        }


        refillGems(refill);
    }

    private function refillGems(forceFall: Boolean = false):void {
        var refill: Boolean;

        var l: int = _enterCells.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _enterCells[i];
            if (cell && cell.fillable) {
                var gem: Gem = getRandom(true, cell.ingredient);
                cell.setGem(gem);
                dispatchEventWith(NEW_GEM, false, gem);

                refill = true;
            }
        }

        if (refill || forceFall) {
            delayedCall(fallGems, TimingVO.fall);
        } else {
            delayedCall(checkField, TimingVO.fall);
        }
    }

    private function shuffleField():void {
        var gems: Vector.<Gem> = new <Gem>[];

        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            var cell: Cell = _field[i];
            if (cell.gem && cell.gem.allowShuffle) {
                if (Math.random()<0.5) {
                    gems.push(cell.gem);
                } else {
                    gems.unshift(cell.gem);
                }
            }
        }

        for (i = 0; i < l; i++) {
            cell = _field[i];
            if (cell.gem && cell.gem.allowShuffle) {
                if (Math.random()<0.5) {
                    cell.setGem(gems.pop(), true);
                } else {
                    cell.setGem(gems.shift(), true);
                }
            }
        }
    }

    private function addScore(value: Number):void {
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

    private function getNearGems(match: Match):Vector.<Cell> {
        var near: Vector.<Cell> = new <Cell>[];
        var l: int = match.amount;
        for (var i:int = 0; i < l; i++) {
            var neighbours: Vector.<Cell> = getNeighbours(match.cells[i]);
            var l2: int = neighbours.length;
            for (var j:int = 0; j < l2; j++) {
                var cell: Cell = neighbours[j];
                if (match.cells.indexOf(cell)<0) {
                    var gem:Gem = cell.gem;
                    if (gem && near.indexOf(cell) < 0) {
                        near.push(cell);
                    }
                }
            }
        }
        return near;
    }

    private function showEffect(event: String, move: Cell, cells: Vector.<Cell>):void {
        var effects: Vector.<EffectVO> = EffectVO.EFFECTS[event];
        for (var i:int = 0; i < effects.length; i++) {
            var effect: EffectVO = effects[i];
            if (effect && effect.path) {
                if (effect.target == "move") {
                    delayedCall(startEffect, effect.delay, effect, move);
                } else if (effect.target == "cell") {
                    for (var j:int = 0; j < cells.length; j++) {
                        delayedCall(startEffect, effect.delay, effect, cells[j]);
                    }
                }
            }
        }
    }
    private function startEffect(effect: EffectVO, target: Object):void {
        dispatchEventWith(EFFECT, false, {"effect": effect, "target": target});
    }

    public function step(delta: Number):void {
        if (!_started) {
            return;
        }

        _time += delta;

        var l: int = _field.length;
        for (var i:int = 0; i < l; i++) {
            _field[i].step(delta);
        }

        if (_delayedCalls==0) {
            _hintTime += delta;

            if (_hintTime >= TimingVO.hint) {
                showHint();
            }
        }

        dispatchEventWith(UPDATE);
    }

    private function handleAddFruit(e: Event):void {
        var gem: Gem = e.currentTarget as Gem;
        gem.removeEventListener(Gem.KILL, handleAddFruit);
        _ingredients.addFruits(1);
    }
}
}
