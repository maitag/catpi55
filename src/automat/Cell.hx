package automat;

enum abstract CellType(Int) from Int to Int {

	var TABU; // to mark a cell as forbidden into grid 

	// solid
	public var isSolid(get, never):Bool;
	inline function get_isSolid():Bool return (this > 0 && this <= (METAL:Int));
	var EARTH;
	var WOOD;
	var ROCK;
	var METAL;

	// fluid
	public var isFluid(get, never):Bool;
	inline function get_isFluid():Bool return (this >= (WATER:Int) && this <= (PLASMA:Int));
	var WATER;
	// var SAND; // (0_1)
	var MILK;
	var PISS;
	var ACID;
	var MAGMA;
	var PLASMA;

	// gas
	public var isGas(get, never):Bool;
	inline function get_isGas():Bool return this >= (AIR:Int);
	var AIR;
	var SMOKE;
	var FOG;

	public static inline var bits:Int = 4;
	public static inline var mask:Int = (1 << bits)-1;

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
	// amount for full filled by 1x1-shape actors 
	public static inline var MAX_ACTORS:Int = Grid.WIDTH * Grid.HEIGHT;
	// amount for full filled by min 2x1-shape actors:
	// public static inline var MAX_ACTORS:Int = ((Grid.WIDTH * Grid.HEIGHT)>>1) + Grid.WIDTH + Grid.HEIGHT - 2;
	// amount for full filled by min 2x2-shape actors: 
	// public static inline var MAX_ACTORS:Int = ((Grid.WIDTH + 2) * (Grid.HEIGHT+2)) >> 2;

	// public static inline var bits:Int = 13; // for 64x64+1
	public static inline var bits:Int = util.BitUtil.bitsize(MAX_ACTORS);
	public static inline var mask:Int = ((1 << bits)-1) << (CellParam.bits + CellType.bits);

	public static inline var maskWithOrigin:Int = ((1 << bits+1)-1) << (CellParam.bits + CellType.bits);
	public static inline var ORIGIN_BIT:Int = (1 << (CellActor.bits + CellParam.bits + CellType.bits));
	
	public static inline var EMPTY:Int = MAX_ACTORS;

	public var isEmpty(get, never):Bool;
	inline function get_isEmpty():Bool return (this == EMPTY);
}


// -------------------------------------------------------------------------
// |   actorOriginBit 1 |         actor 13       |     param 8    | type 4 |
// -------------------------------------------------------------------------
abstract Cell(Int) from Int to Int {
	public inline function new(type:CellType, ?param:CellParam) {
		if (param == null) {
			param = 0;
			/*if (type.isSolid) {trace("todo: SET SOLID DEFAULTS");param = 1;}
			else if (type.isFluid) {trace("todo: SET FLUID DEFAULTS");param = 2;}
			else {trace("todo: SET GAS DEFAULTS");param = 3;}*/
		}
		this = (CellActor.MAX_ACTORS << (CellParam.bits + CellType.bits)) |  (param << CellType.bits) | type;
	}

	// if a cell is fetched from outside of grid-space or to forbid cells into a grid:
	public var isTabu(get, never):Bool;
	inline function get_isTabu():Bool return type == TABU;

	// --------- TYPE ----------

	public var type(get, set):CellType;
	inline function get_type():CellType return this & CellType.mask;
	inline function set_type(type:CellType):CellType return this = (this & ~CellType.mask) | type;

	public var isSolid(get, never):Bool;
	inline function get_isSolid():Bool return type.isSolid;
	
	public var isFluid(get, never):Bool;
	inline function get_isFluid():Bool return type.isFluid;

	public var isGas(get, never):Bool;
	inline function get_isGas():Bool return type.isGas;


	// --------- PARAM (depends on the type) ----------

	public var param(get, set):CellParam;
	inline function get_param():CellParam return (this & CellParam.mask) >> CellType.bits;
	inline function set_param(param:CellParam):CellParam return this = (this & ~CellParam.mask) | (param << CellType.bits);


	// --------- ACTOR key -------------

	public var actor(get, set):CellActor;
	inline function get_actor():CellActor return (this & CellActor.mask) >> (CellParam.bits + CellType.bits);
	inline function set_actor(actor:CellActor):CellActor return this = (this & ~CellActor.mask) | (actor << (CellParam.bits + CellType.bits));
	// TODO: problem on neko with the bitops

	public inline function setActor(actor:CellActor, isOrigin:Bool = false):CellActor {
		if (isOrigin)
			return this = (this & ~CellActor.maskWithOrigin) | CellActor.ORIGIN_BIT | (actor << (CellParam.bits + CellType.bits));
		else
			return this = (this & ~CellActor.maskWithOrigin) | (actor << (CellParam.bits + CellType.bits));
	}

	// inline function removeActor() this = (this & ~CellActor.mask) | (CellActor.EMPTY << (CellParam.bits + CellType.bits));
	// removes also the "origin" bit
	public inline function removeActor() this = (this & ~CellActor.maskWithOrigin) | (CellActor.EMPTY << (CellParam.bits + CellType.bits));

	public var hasActor(get, never):Bool;
	inline function get_hasActor():Bool return !actor.isEmpty;

	public var isOrigin(get, never):Bool;
	inline function get_isOrigin():Bool return (this & CellActor.ORIGIN_BIT > 0);

	public inline function setOrigin() this = this | CellActor.ORIGIN_BIT;
	public inline function delOrigin() this = this & ~CellActor.ORIGIN_BIT;

	// ------------ Debug ----------------

	public function toString():String return 'type:$type, param:$param, actor-index:$actor';

}
