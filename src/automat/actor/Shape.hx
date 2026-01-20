package automat.actor;

#if !macro

import automat.Cell.CellActor;
import util.BitGrid;
import automat.Pos.xy as P;

/*
interface IActorShape {
	public var pos:Pos;
	public var grid:Grid;
	public function isFitIntoGrid(grid:Grid, pos:Int):Bool;
	public function isFreeLeft():Bool;
	// public function moveLeft():Bool;
}
*/

// 1x1 shape without macro:
class Shape1x1 {
	// TODO
}

class Shape {

	// A N Y -< now lets "add"

	// only this is needs macrofication!!!
	public static inline function _addToGrid(pos:Pos,
		g:Grid, gR:Grid, gB:Grid, gRB:Grid,
		a:CellActor, aR:CellActor, aB:CellActor, aRB:CellActor,
		shape:BitGrid
		) 
	{
		for (y in 0...shape.height) {
			for (x in 0...shape.width) {
				if ( shape.get(x,y) ) {
					g.setCellActorAtOffset(pos.x + x, pos.y + y, gR, gB, gRB, a, aR, aB, aRB);
				}
			}
		}
	}

	public static inline function addToGrid(actor:IActor, grid:Grid, pos:Pos, shape:BitGrid) {
		actor.grid = grid;
		actor.pos = pos;
		if ( pos.x + shape.width < Grid.WIDTH )
		{					
			if ( pos.y + shape.height < Grid.HEIGHT)
				_addToGrid(pos, grid, null, null, null, grid.actors.add(actor), 0, 0, 0, shape);
			else
				_addToGrid(pos, grid, null, grid.bottom, null,
					grid.actors.add(actor), 0, grid.bottom.actors.add(actor), 0, shape);
		}
		else
		{
			if ( pos.y + shape.height < Grid.HEIGHT )
				_addToGrid(pos, grid, grid.right, null, null,
					grid.actors.add(actor), grid.right.actors.add(actor), 0, 0, shape);
			else
				_addToGrid(pos, grid, grid.right, grid.bottom, grid.rightBottom,
					grid.actors.add(actor), grid.right.actors.add(actor),
					grid.bottom.actors.add(actor), grid.rightBottom.actors.add(actor), shape);
		}

			
		/*
		// TODO: finish optimization for non-macro
		var y_max:Int = Grid.HEIGHT - pos.y;
		var x_max:Int = Grid.WIDTH - pos.x;		
		if (y_max > shape.height) y_max = shape.height;
		if (x_max > shape.width) x_max = shape.width;
		var a:Int = grid.actors.add(actor);
		for (y in 0...y_max) {
			for (x in 0...x_max) {
				if ( shape.get(x,y) ) grid.setCellActorAt(pos, x, y, a);
			}
		}
		var g:Grid;
		// rightBottom
		if (y_max < shape.height && x_max < shape.width && grid.rightBottom != null) {
			g = grid.rightBottom;
			a = g.actors.add(actor);
			for (y in y_max...shape.height) {
				for (x in x_max...shape.width) {
					if ( shape.get(x,y) ) g.setCellActorAt(pos, x - x_max, y - y_max, a);
				}
			}	
		}
		// at right out of bounds
		// ...
		// at bottom out of bounds
		*/
	}

	public static function isFitIntoGrid(actor:IActor, grid:Grid, pos:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) {
			for (x in 0...shape.width) {
				if ( shape.get(x,y) ) {
					var cell:Cell = grid.getCellAtOffset( pos, x, y );
					// TODO: more parameters to check what cell-TYPE should block the actor
					if (cell.isTabu || cell.type == METAL || cell.hasActor) return false;
					// if (cell.isTabu || cell.hasActor) return false;
				}
			}
		}
		return true;
	}

	public static function isFreeLeft(actor:IActor, grid:Grid, pos:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) {
			for (x in 0...shape.width) {
				if ( shape.get(x,y) ) {
					if ( x == 0 || !shape.get(x-1,y) ) {
						var cell:Cell = grid.getCellAtOffset( pos, x-1, y );
						// TODO: more parameters to check what cell-TYPE should block the actor
						// if (cell.isTabu || cell.type == METAL || cell.hasActor) return false;
						if (cell.isTabu || cell.hasActor) return false;
					}
				}
			}
		}
		return true;
	}

	public static function moveLeft(actor:IActor, shapeBitGrid:BitGrid) {
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

			// functions with args
			for (fname in ["addToGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
							{name:"pos", opt:false, meta:[], type: macro:automat.Pos}
						],
						expr: macro automat.actor.Shape.$fname(this, grid, pos, shapeBitGrid),
						ret: null
					})
				});

			for (fname in ["isFitIntoGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
							{name:"pos", opt:false, meta:[], type: macro:automat.Pos}
						],
						expr: macro return automat.actor.Shape.$fname(this, grid, pos, shapeBitGrid),
						ret: macro:Bool
					})
				});

			// functions without args:
			for (fname in ["isFreeLeft"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro return automat.actor.Shape.$fname(this, grid, pos, shapeBitGrid),
						ret: macro:Bool
					})
				});

			// TODO: more function delegations into loops !
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