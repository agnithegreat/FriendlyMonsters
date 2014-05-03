/**
 * Created by agnither on 09.04.14.
 */
package com.orchideus.monsters.view.ui.screens {
import com.agnither.ui.Screen;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.GameController;

public class MainScreen extends Screen {

    public static const ID: String = "MainScreen";

    private var _controller: GameController;

    public function MainScreen(refs:CommonRefs, controller: GameController) {
        _controller = controller;

        super(refs);
    }

    override protected function initialize():void {
    }
}
}
