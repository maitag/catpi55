package automat.sim;

import util.Pos;

enum abstract SimEventType(Int) from Int to Int {

	var CELL_MOVE;
	var CELL_EMPTY;

	var ACTOR_AFTER_MOVE;

	// ... more here

	var LAST;

	public static var bits(get, never):Int;
	static inline function get_bits():Int return util.BitUtil.bitsize((LAST:Int));

	public static var mask(get, never):Int;
	static inline function get_mask():Int return (1 << bits)-1;


	// debug:
	public function toString():String return util.EnumMacro.nameByValue(automat.sim.SimEventType).get(this);
}

// ------------------------------------------------------

abstract SimEvent(Int) from Int to Int {
	public inline function new(type:SimEventType, pos:Pos) {
		this = (pos << SimEventType.bits) | type;
	}

	public var type(get, set):SimEventType;
	inline function get_type():SimEventType return this & SimEventType.mask;
	inline function set_type(type:SimEventType):SimEventType return this = (this & ~SimEventType.mask) | type;

	// for CELL events -> position
	public var pos(get, set):Pos;
	inline function get_pos():Pos return this >> SimEventType.bits;
	inline function set_pos(pos:Pos):Pos return (pos << SimEventType.bits) | type;

	// for ACTOR events -> actorkey
	public var actorKey(get, set):Int;
	inline function get_actorKey():Int return this >> SimEventType.bits;
	inline function set_actorKey(key:Int):Pos return (key << SimEventType.bits) | type;





	// debug:
	public function toString():String return 'type:$type, pos:$pos';

}
