/**
 * Created by agnither on 27.05.14.
 */
package com.orchideus.monsters.model.game {
import com.orchideus.monsters.data.BlockVO;

public class Block extends Gem {

    private var _block: BlockVO;
    override public function get type():String {
        return _block.name;
    }

    override public function get points():int {
        return 0;
//        return _block.points;
    }

    override public function get matchable():Boolean {
        return false;
    }

    override public function get allowShuffle():Boolean {
        return false;
    }

    public function Block(type: String, collectable: Boolean) {
        _block = BlockVO.BLOCKS[type];
        super(type, false, collectable, true);
    }

    override public function idle(id: int):void {
        dispatchEventWith(IDLE, false, id);
    }
}
}
