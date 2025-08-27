package automat;

#if !macro
@:build(automat.Pos.PosMacro.build(6,6)) abstract Pos(Int) from Int to Int {}

// @:build(automat.Pos.PosMacro.build(5,5)) abstract Pos32(Int) to Int {}
// @:build(automat.Pos.PosMacro.build(6,6)) abstract Pos64(Int) to Int {}
// @:build(automat.Pos.PosMacro.build(7,7)) abstract Pos128(Int) to Int {}
// @:build(automat.Pos.PosMacro.build(8,8)) abstract Pos256(Int) to Int {}

// @:build(automat.Pos.PosMacro.build(6,5)) abstract Pos64x32(Int) to Int {}
// @:build(automat.Pos.PosMacro.build(5,6)) abstract Pos32x64(Int) to Int {}


// this is manual haxe code for using fully Int 32 bitsize
/*
private abstract Pos(Int) to Int {

	// lower bits for x position
	public static inline var xBits:Int = 16;
	public static inline var xMax:Int = 0xffff;

	// higher bits for y position
	public static inline var yBits:Int = 16;
	public static inline var yMax:Int = 0xffff;
	
	// --------------------------------------------------

	public var x(get,set):Int;
	inline function get_x():Int return this & xMax;
	inline function set_x(v:Int):Int {
		// TODO: bounds check
		return this = (this & (yMax << xBits)) | v;
	}

	public var y(get,set):Int;
	inline function get_y():Int return this >> xBits;
	inline function set_y(v:Int):Int {
		// TODO: bounds check
		return this = (v << xBits) | (this & xMax);
	}

	public inline function new(x:Int, y:Int) set(x, y);
	public inline function set(x:Int, y:Int) this = (y << xBits) | x;
}*/

#else 

import haxe.macro.Expr;
import haxe.macro.Context;

class PosMacro {
	static public function build(xBits:Int, yBits:Int):Array<Field> {
		var xMax:Int = (1 << xBits) - 1;
		var yMax:Int = (1 << yBits) - 1;

		var fields = Context.getBuildFields();
		fields.push({
			name: "xMax",
			doc: null,
			meta: [],
			access: [AStatic, APublic, AInline],
			kind: FVar(macro:Int, macro $v{xMax}),
			pos: Context.currentPos()
		});
		fields.push({
			name: "yMax",
			doc: null,
			meta: [],
			access: [AStatic, APublic, AInline],
			kind: FVar(macro:Int, macro $v{yMax}),
			pos: Context.currentPos()
		});
		fields.push({
			name: "xBits",
			doc: null,
			meta: [],
			access: [AStatic, APublic, AInline],
			kind: FVar(macro:Int, macro $v{xBits}),
			pos: Context.currentPos()
		});
		fields.push({
			name: "yBits",
			doc: null,
			meta: [],
			access: [AStatic, APublic, AInline],
			kind: FVar(macro:Int, macro $v{yBits}),
			pos: Context.currentPos()
		});
		
		// ---------- x and y --------------------
		
		fields.push({
			name: "x",
			doc: null,
			meta: [],
			access: [APublic],
			kind: FProp("get", "set", macro:Int, null),
			pos: Context.currentPos()
		});

		fields.push({
			name: "get_x",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return this & xMax,
				params: [],
				ret: macro:Int
			})
		});

		fields.push({
			name: "set_x",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"v", opt:false, meta:[], type: macro:Int}],
				expr: macro return this = (this & (yMax << xBits)) | v,
				params: [],
				ret: macro:Int
			})
		});

		// -------------------------------------------
		
		fields.push({
			name: "y",
			doc: null,
			meta: [],
			access: [APublic],
			kind: FProp("get", "set", macro:Int, null),
			pos: Context.currentPos()
		});

		fields.push({
			name: "get_y",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return this >> xBits,
				params: [],
				ret: macro:Int
			})
		});

		fields.push({
			name: "set_y",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"v", opt:false, meta:[], type: macro:Int}],
				expr: macro return this = (v << xBits) | (this & xMax),
				params: [],
				ret: macro:Int
			})
		});

		// -------------------------------------------

		fields.push({
			name: "new",
			access: [AInline, APublic],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"x", opt:false, meta:[], type: macro:Int}, {name:"y", opt:false, meta:[], type: macro:Int}],
				expr: macro set(x, y),
				params: [],
				ret: null
			})
		});

		fields.push({
			name: "set",
			access: [AInline, APublic],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"x", opt:false, meta:[], type: macro:Int}, {name:"y", opt:false, meta:[], type: macro:Int}],
				expr: macro this = (y << xBits) | x,
				params: [],
				ret: null
			})
		});

		// for (field in fields) trace(new haxe.macro.Printer().printField(field));

		return fields;
	}
}


#end