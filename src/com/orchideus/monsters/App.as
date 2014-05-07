/**
 * Created with IntelliJ IDEA.
 * User: agnither
 * Date: 8/23/13
 * Time: 11:17 PM
 * To change this template use File | Settings | File Templates.
 */
package com.orchideus.monsters {
import com.agnither.utils.DeviceResInfo;
import com.agnither.utils.ResourcesManager;
import com.orchideus.monsters.data.BlockVO;
import com.orchideus.monsters.data.BonusVO;
import com.orchideus.monsters.data.GemVO;
import com.orchideus.monsters.data.MultiplierVO;
import com.orchideus.monsters.view.ui.Animations;

import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

public class App extends Sprite {

    private var _resources: ResourcesManager;

    private var _controller: GameController;

    public function App() {
        addEventListener(Event.ADDED_TO_STAGE, start);
    }

    public function start(e: Event = null):void {
        removeEventListener(Event.ADDED_TO_STAGE, start);

        var info: DeviceResInfo = DeviceResInfo.getInfo(Starling.current.nativeOverlay.stage);
        Starling.current.nativeOverlay.stage.frameRate = info.frameRate;

        _resources = new ResourcesManager(info);
//        _resources.addEventListener(ResourcesManager.COMPLETE_PHASE, handlePreloader);
//        _resources.loadPreloader();
        _resources.addEventListener(ResourcesManager.COMPLETE_PHASE, handleComplete);
        _resources.loadMain();
        _resources.loadGUI();

        _controller = new GameController(stage, _resources);
        _controller.init();

        _resources.load();
    }

    private function handleComplete(e: Event):void {
        _resources.removeEventListener(ResourcesManager.COMPLETE_PHASE, handleComplete);

//        initLocale();
        loadConfig();

        _resources.addEventListener(ResourcesManager.COMPLETE, handleInit);
    }

//    private function initLocale():void {
//        LocalizationManager.parse(_resources.main.getObject("locale"));
//    }

    private function loadConfig():void {
        var config: Object = _resources.main.getObject("config");

        GemVO.parse(config.gems);
        BlockVO.parse(config.blocks);
        MultiplierVO.parse(config.multiplier);
        BonusVO.parse(config.bonuses);
    }

    private function handleInit():void {
        _resources.removeEventListener(ResourcesManager.COMPLETE, handleInit);

        Animations.init();
        Animations.convert(_resources.gui.getByteArray("Charry3"), handleConvert);
    }

    private function handleConvert(e: * = null):void {
        _controller.ready();
    }
}
}
