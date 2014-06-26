/**
 * Created by agnither on 22.05.14.
 */
package com.orchideus.monstersEditor.view.ui.screens.game.panels {
import com.agnither.ui.Popup;
import com.agnither.utils.CommonRefs;
import com.orchideus.monstersEditor.model.game.Cell;
import com.orchideus.monstersEditor.view.ui.common.CheckBox;

import starling.display.Quad;
import starling.events.Event;

public class CellPopup extends Popup {

    public static const AVAILABLE_CHANGED: String = "available_changed_CellPopup";
    public static const ENTER_CHANGED: String = "enter_changed_CellPopup";
    public static const INGREDIENT_CHANGED: String = "ingredient_changed_CellPopup";
    public static const EXIT_CHANGED: String = "exit_changed_CellPopup";

    private var _back: Quad;

    private var _available: CheckBox;
    private var _enter: CheckBox;
    private var _ingredient: CheckBox;
    private var _exit: CheckBox;

    private var _cell: Cell;

    public function CellPopup(refs:CommonRefs) {
        super(refs, false);
    }

    override protected function initialize():void {
        _back = new Quad(150, 150, 0xCCCCCC);
        addChild(_back);

        _available = new CheckBox(_refs);
        _available.addEventListener(CheckBox.CHANGED, handleAvailableChanged);
        _available.x = 10;
        _available.y = 10;
        addChild(_available);
        _available.text = "Доступна";

        _enter = new CheckBox(_refs);
        _enter.addEventListener(CheckBox.CHANGED, handleEnterChanged);
        _enter.x = 10;
        _enter.y = 40;
        addChild(_enter);
        _enter.text = "Вход";

        _ingredient = new CheckBox(_refs);
        _ingredient.addEventListener(CheckBox.CHANGED, handleIngredientChanged);
        _ingredient.x = 10;
        _ingredient.y = 70;
        addChild(_ingredient);
        _ingredient.text = "Игредиент";

        _exit = new CheckBox(_refs);
        _exit.addEventListener(CheckBox.CHANGED, handleExitChanged);
        _exit.x = 10;
        _exit.y = 100;
        addChild(_exit);
        _exit.text = "Выход";
    }

    private function handleAvailableChanged(e: Event):void {
        dispatchEventWith(AVAILABLE_CHANGED, true, _available.check);
    }

    private function handleEnterChanged(e: Event):void {
        dispatchEventWith(ENTER_CHANGED, true, _enter.check);
    }

    private function handleIngredientChanged(e: Event):void {
        dispatchEventWith(INGREDIENT_CHANGED, true, _ingredient.check);
    }

    private function handleExitChanged(e: Event):void {
        dispatchEventWith(EXIT_CHANGED, true, _exit.check);
    }

    public function showPopup(cell: Cell):void {
        hidePopup();

        _cell = cell;

        _cell.addEventListener(Cell.UPDATE, updateControls);
        updateControls();
    }

    public function hidePopup():void {
        if (_cell) {
            _cell.removeEventListener(Cell.UPDATE, updateControls);
            _cell = null;
        }
    }

    private function updateControls(e: Event = null):void {
        _available.check = _cell.available;
        _enter.check = _cell.enter;
        _ingredient.check = _cell.ingredient;
        _exit.check = _cell.exit;
    }
}
}
