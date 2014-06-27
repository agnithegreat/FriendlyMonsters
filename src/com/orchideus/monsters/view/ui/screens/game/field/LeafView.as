/**
 * Created by agnither on 02.05.14.
 */
package com.orchideus.monsters.view.ui.screens.game.field {
import com.agnither.ui.AbstractView;
import com.agnither.utils.CommonRefs;
import com.orchideus.monsters.data.EffectVO;

import extensions.PDParticleSystem;

import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class LeafView extends AbstractView {

    private var _view: Image;

    private var _trace: PDParticleSystem;

    override public function set x(value: Number):void {
        super.x = value;
        _trace.emitterX = value;
    }

    override public function set y(value: Number):void {
        super.y = value;
        _trace.emitterY = value;
    }

    public function LeafView(refs:CommonRefs) {
        super(refs);
    }

    override protected function initialize():void {
        _view = new Image(_refs.game.getTexture("leaf.png"));
        _view.rotation = Math.PI/3;
        _view.touchable = false;
        _view.pivotX = int(_view.width/2);
        _view.pivotY = int(_view.height/2);
        addChild(_view);

        var effect: EffectVO = EffectVO.EFFECTS[EffectVO.LEAF_TRACE][0];
        _trace = new PDParticleSystem(_refs.game.getXml(effect.path.replace(".pex", "")), _refs.game.getTexture(effect.name+".png"));
        _trace.addEventListener(Event.COMPLETE, handleRemoveParticle);
        Starling.juggler.add(_trace);
        _trace.start();
        parent.addChild(_trace);
    }

    private function handleRemoveParticle(e: Event):void {
        _trace.removeEventListener(Event.COMPLETE, handleRemoveParticle);

        Starling.juggler.remove(_trace);
        _trace.parent.removeChild(_trace, true);
        _trace = null;
    }

    override public function destroy():void {
        removeChild(_view, true);
        _view = null;

        _trace.stop();

        removeFromParent(true);

        super.destroy();
    }
}
}
