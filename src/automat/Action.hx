package automat;

enum abstract ActionType(Int) from Int to Int {

	var CELL_MOVE;
	var CELL_EMPTY;

	public static var bits(get, never):Int;
	static inline function get_bits():Int return 4;

	public static var mask(get, never):Int;
	static inline function get_mask():Int return 0x0F;
}

// ------------------------------------------------------

abstract Action(Int) from Int to Int {
	public inline function new(type:ActionType, pos:Pos) {
		this = (pos << ActionType.bits) | type;
	}

	public var type(get, set):ActionType;
	inline function get_type():ActionType return this & ActionType.mask;
	inline function set_type(type:ActionType):ActionType return this = (this & ~ActionType.mask) | type;

	// position into cellgrid
	public var pos(get, set):Pos;
	inline function get_pos():Pos return this >> ActionType.bits;
	inline function set_pos(pos:Pos):Pos return (pos << ActionType.bits) | type;



}
