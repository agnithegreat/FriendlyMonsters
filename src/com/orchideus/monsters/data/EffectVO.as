/**
 * Created by agnither on 14.04.14.
 */
package com.orchideus.monsters.data {
import flash.utils.Dictionary;

public class EffectVO {

    public static const GEM_REMOVE_3: String = "gem_remove_3";
    public static const GEM_REMOVE_4: String = "gem_remove_4";
    public static const GEM_REMOVE_5: String = "gem_remove_5";
    public static const GEM_REMOVE_CORNER: String = "gem_remove_corner";

    public static const GEM_REMOVE: String = "gem_remove";

    public static const BOOSTER_USE: String = "booster_use";

    public static const LEAF_TRACE: String = "leaf_trace";
    public static const LEAF_END: String = "leaf_end";

    public static var EFFECTS: Dictionary = new Dictionary();

    public static var animations: Array = [];

    public static function parse(data: Object):void {
        for each (var row: Object in data) {
            var effect: EffectVO = new EffectVO();
            effect.id = row.id;
            effect.event = row.event;
            effect.type = row.type;
            effect.name = row.name;
            effect.path = row.path;
            effect.target = row.target;
            effect.delay = row.delay;

            if (!EFFECTS[effect.event]) {
                EFFECTS[effect.event] = new <EffectVO>[];
            }
            EFFECTS[effect.event].push(effect);

            if (effect.name && effect.type=="animation" && animations.indexOf(effect.name)<0) {
                animations.push(effect.name);
            }
        }
    }

    public var id: int;
    public var event: String;
    public var type: String;
    public var name: String;
    public var path: String;
    public var target: String;
    public var delay: Number;
}
}
