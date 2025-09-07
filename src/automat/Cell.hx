package automat;

enum abstract CellType(Int) from Int to Int {

	// solid
	public static inline function isSolid(type:Int):Bool return (type <= (METAL:Int));
	var EARTH;
	var WOOD;
	var ROCK;
	var METAL;

	// fluid
	public static inline function isFluid(type:Int):Bool return (type >= (WATER:Int) && type <= (PLASMA:Int));
	var WATER;
	var MILK;
	var ACID;
	var MAGMA;
	var PLASMA;

	// gas
	public static inline function isGas(type:Int):Bool return (type >= (AIR:Int));
	var AIR;
	var SMOKE;
	var FOG;


	public static var bits(get, never):Int;
	static inline function get_bits():Int return 4;

	public static var mask(get, never):Int;
	static inline function get_mask():Int return 0x0F;

	public function toString():String return util.EnumMacro.nameByValue(automat.CellType).get(this);
}


// ----------------------------------------------------

abstract Cell(Int) from Int to Int {
	public inline function new(?type:CellType) {
		this = (type == null) ? 0 : type;
	}

	public var type(get, set):CellType;
	inline function get_type():CellType return this & CellType.mask;
	inline function set_type(type:CellType):CellType return this = (this & ~CellType.mask) | type;


	// to check the CellType category

	public var isSolid(get, never):Bool;
	inline function get_isSolid():Bool return CellType.isSolid(this & CellType.mask);

	public var isFluid(get, never):Bool;
	inline function get_isFluid():Bool return CellType.isFluid(this & CellType.mask);

	public var isGas(get, never):Bool;
	inline function get_isGas():Bool return CellType.isGas(this & CellType.mask);

	// parameters in depend of the type


	// debug:
	public function toString():String return 'type:$type';

}
