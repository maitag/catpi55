package catpi.automat.sim;

import catpi.util.Pos;
import catpi.util.BitUtil;
import catpi.util.EnumMacro;

enum abstract SimEventType(Int) from Int to Int {

	var CELL_MOVE;
	var CELL_EMPTY;

	var ACTOR_AFTER_MOVE;

	// ... more here

	var LAST;

	public static var bits(get, never):Int;
	static inline function get_bits():Int return BitUtil.bitsize((LAST:Int));

	public static var mask(get, never):Int;
	static inline function get_mask():Int return (1 << bits)-1;


	// debug:
	public function toString():String return EnumMacro.nameByValue(catpi.automat.sim.SimEventType).get(this);
}
