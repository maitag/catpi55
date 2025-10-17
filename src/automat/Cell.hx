package automat;

enum abstract CellType(Int) from Int to Int {

	// solid
	// public static inline function isSolid(type:Int):Bool return (type <= (METAL:Int));
	public var isSolid(get, never):Bool;
	inline function get_isSolid():Bool return this <= (METAL:Int);
	var EARTH;
	var WOOD;
	var ROCK;
	var METAL;

	// fluid
	// public static inline function isFluid(type:Int):Bool return (type >= (WATER:Int) && type <= (PLASMA:Int));
	public var isFluid(get, never):Bool;
	inline function get_isFluid():Bool return (this >= (WATER:Int) && this <= (PLASMA:Int));
	var WATER;
	var MILK;
	var ACID;
	var MAGMA;
	var PLASMA;

	// gas
	// public static inline function isGas(type:Int):Bool return (type >= (AIR:Int));
	public var isGas(get, never):Bool;
	inline function get_isGas():Bool return this >= (AIR:Int);
	var AIR;
	var SMOKE;
	var FOG;

	/*
	public static var bits(get, never):Int;
	static inline function get_bits():Int return 4;

	public static var mask(get, never):Int;
	static inline function get_mask():Int return (1 << bits)-1;
	*/
	public static inline var bits:Int = 4;
	public static inline var mask:Int = (1 << bits)-1;

	
	// debug:
	public function toString():String return util.EnumMacro.nameByValue(automat.CellType).get(this);
}

// ----------------------------------------------------
abstract CellParam(Int) from Int to Int {
	/*
	public static var bits(get, never):Int;
	static inline function get_bits():Int return 8;

	public static var mask(get, never):Int;
	static inline function get_mask():Int return ((1 << bits)-1) << CellType.bits;
	*/
	public static inline var bits:Int = 8;
	public static inline var mask:Int = ((1 << bits)-1) << CellType.bits;

}

@:forward @:forwardStatics
abstract SolidParam(Int) from CellParam to CellParam {

}

@:forward @:forwardStatics
abstract FluidParam(Int) from CellParam to CellParam {

}

@:forward @:forwardStatics
abstract GasParam(Int) from CellParam to CellParam {

}

// ----------------------------------------------------
abstract CellActor(Int) from Int to Int {
	public static inline var bits:Int = 12;
	public static inline var mask:Int = ((1 << bits)-1) << (CellType.bits + CellParam.bits);

	public static inline var ATOM_MAX:Int = 10;
	public static inline var BASE_MAX:Int = ((Grid.WIDTH * Grid.HEIGHT)>>2) + (Grid.WIDTH>>1) + (Grid.HEIGHT>>1) - 1; // 1087
	public static inline var MAIN_MAX:Int = BASE_MAX;

	public static inline var ATOM_START_INDEX:Int = 1;
	public static inline var BASE_START_INDEX:Int = ATOM_START_INDEX + ATOM_MAX;
	public static inline var MAIN_START_INDEX:Int = BASE_START_INDEX + BASE_MAX;

	public var isEmpty(get, never):Bool;
	inline function get_isEmpty():Bool return (this == 0 );

	public var isAtomActor(get, never):Bool;
	inline function get_isAtomActor():Bool return (this < 10 );

	public var isBaseActor(get, never):Bool;
	inline function get_isBaseActor():Bool return (this < 10 );

	public var isMainActor(get, never):Bool;
	inline function get_isMainActor():Bool return (this < 10 );

}

// ----------------------------------------------------

abstract Cell(Int) from Int to Int {
	public inline function new(type:CellType, ?param:CellParam) {
		if (param == null) {
			param = 0;
			/*if (type.isSolid) {trace("todo: SET SOLID DEFAULTS");param = 1;}
			else if (type.isFluid) {trace("todo: SET FLUID DEFAULTS");param = 2;}
			else {trace("todo: SET GAS DEFAULTS");param = 3;}*/
		}
		this = (param << CellType.bits) | type;
	}

	// --------- TYPE ----------

	public var type(get, set):CellType;
	inline function get_type():CellType return this & CellType.mask;
	inline function set_type(type:CellType):CellType return this = (this & ~CellType.mask) | type;


	// to check the CellType category

	public var isSolid(get, never):Bool;
	// inline function get_isSolid():Bool return CellType.isSolid(this & CellType.mask);
	inline function get_isSolid():Bool return type.isSolid;
	
	public var isFluid(get, never):Bool;
	// inline function get_isFluid():Bool return CellType.isFluid(this & CellType.mask);
	inline function get_isFluid():Bool return type.isFluid;

	public var isGas(get, never):Bool;
	// inline function get_isGas():Bool return CellType.isGas(this & CellType.mask);
	inline function get_isGas():Bool return type.isGas;


	// --------- PARAM (depends on the type) ----------

	public var param(get, set):CellParam;
	inline function get_param():CellParam return (this & CellParam.mask) >> CellType.bits;
	inline function set_param(param:CellParam):CellParam return this = (this & ~CellParam.mask) | (param << CellType.bits);


	// --------- ACTOR index -------------

	public var actor(get, set):CellActor;
	inline function get_actor():CellActor return (this & CellActor.mask) >> CellActor.bits;
	inline function set_actor(actor:CellActor):CellActor return this = (this & ~CellActor.mask) | (actor << CellActor.bits);
	// TODO: problem on neko with the bitops


	// debug:
	public function toString():String return 'type:$type, param:$param, actor-index:$actor';

}
