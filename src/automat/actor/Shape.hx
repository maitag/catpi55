package automat.actor;

#if !macro

// import automat.Cell.CellActor;
import util.BitGrid;
import automat.Pos.xy as P;


interface IActorShape {
	public var pos:Pos;
	public var grid:Grid;
	public function isFreeLeft():Bool;
	// public function moveLeft():Bool;
}

// 1x1 shape without macro:
class Shape1x1 {
}

class Shape {

	// A N Y -< now lets "add"

	public static function add(actorID:Int, p:Pos, shape:BitGrid) {
		
	}

	public static function isFreeLeft(grid:Grid, pos:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) {
			for (x in 0...shape.width) {
				if ( shape.get(x,y) && !grid.getActorAtOffset( pos, x-1, y ).isEmpty) return false;
			}
		}
		return true;
	}

	public static function moveLeft(actor:IActorShape, shapeBitGrid:BitGrid) {
		// TODO
		return true;
	}

}


#else 

import haxe.macro.Expr;
import haxe.macro.Context;

class ShapeMacro {
	static public function build(shape:String, unroll = false):Array<Field>
	{
		trace("ShapeMacro");

		var bitGrid:util.BitGrid = shape;
		var fields = Context.getBuildFields();

		if (unroll) { // --------- unrolled ---------------------
	
			fields.push({
				name: "isFreeLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					// TODO: unroll it same as into equivalent static Shapes functions !!!
					expr: macro return true,
					ret: macro:Bool
				})
			});

			// TODO: more function unrolling !

		}
		else { // --------------- delegated ---------------------
			fields.push({
				name: "shapeBitGrid",
				access: [APublic],
				pos: Context.currentPos(),
				kind: FVar(macro:Array<String>, macro $v{bitGrid.toArrayString()})
			});

			fields.push({
				name: "isFreeLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro return automat.actor.Shape.isFreeLeft(grid, pos, shapeBitGrid),
					ret: macro:Bool
				})
			});

			// TODO: more function delegations into loop !
		}

		fields.push({
			name: "width",
			doc: "shape width",
			access: [APublic],
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});

		fields.push({
			name: "get_width",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.width},
				ret: macro:Int
			})
		});

		fields.push({
			name: "height",
			doc: "shape height",
			access: [APublic],
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});

		fields.push({
			name: "get_height",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.height},
				params: [],
				ret: macro:Int
			})
		});
		
	
		for (field in fields) trace(new haxe.macro.Printer().printField(field));

		return fields;
	}
}


#end