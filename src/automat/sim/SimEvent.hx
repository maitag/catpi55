package automat.sim;

import util.Pos;


abstract SimEvent(Int) from Int to Int {
	public inline function new(type:SimEventType, data:Int) {
		this = (data << SimEventType.bits) | type;
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
	public function toString():String return 'type:$type, actorKey:$actorKey';

}
