package automat.actor;

#if !macro

import automat.Cell;
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
	}

	public static function isFitIntoGrid(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if ( shape.get(x,y) && _blocked(grid.getCellAtOffset( pos, x, y ), blockedCellType) ) return false;
		return true;
	}

	static inline function _blocked(cell:Cell, blockedCellType:Int):Bool {
		return (1<<cell.type & blockedCellType > 0 || cell.hasActor || cell.isTabu); // to store one more CellType: return (1<<(cell.type-1) & blockedCellType > 0 || cell.isTabu || cell.hasActor);
	}
	static inline function _isFree(x:Int, y:Int, dx:Int, dy:Int, grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		if ( dx==-1 && dy== 0 && (x==0             || !shape.get(x-1,y)) && _blocked(grid.getCellAtOffset(pos,x-1,y), blockedCellType)) return false;
		if ( dx== 1 && dy== 0 && (x==shape.width-1 || !shape.get(x+1,y)) && _blocked(grid.getCellAtOffset(pos,x+1,y), blockedCellType)) return false;
		if ( dx== 0 && dy==-1 && (y==0             || !shape.get(x,y-1)) && _blocked(grid.getCellAtOffset(pos,x,y-1), blockedCellType)) return false;
		if ( dx== 0 && dy== 1 && (y==shape.height-1|| !shape.get(x,y+1)) && _blocked(grid.getCellAtOffset(pos,x,y+1), blockedCellType)) return false;
		if ( dx==-1 && dy==-1 && (x==0 || y==0     || !shape.get(x-1,y-1)) && _blocked(grid.getCellAtOffset(pos,x-1,y-1), blockedCellType)) return false;
		if ( dx== 1 && dy==-1 && (x==shape.width-1 || y==0             || !shape.get(x+1,y-1)) && _blocked(grid.getCellAtOffset(pos,x+1,y-1), blockedCellType)) return false;
		if ( dx==-1 && dy== 1 && (x==0             || y==shape.height-1|| !shape.get(x-1,y+1)) && _blocked(grid.getCellAtOffset(pos,x-1,y+1), blockedCellType)) return false;
		if ( dx== 1 && dy== 1 && (x==shape.width-1 || y==shape.height-1|| !shape.get(x+1,y+1)) && _blocked(grid.getCellAtOffset(pos,x+1,y+1), blockedCellType)) return false;
		return true;
	}
	public static function isFreeXY(dx:Int, dy:Int, grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) for (x in 0...shape.width)
			if ( shape.get(x,y) && !_isFree(x, y, dx, dy, grid, pos, blockedCellType, shape)) return false;
		return true;
	}
	
	public static function isFreeLeft(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) for (x in 0...shape.width)
			if ( shape.get(x,y) && ( x == 0 || !shape.get(x-1,y) ) && _blocked(grid.getCellAtOffset( pos, x-1, y ), blockedCellType)) return false;
		return true;
	}

	public static function isFreeRight(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) for (x in 0...shape.width)
			if ( shape.get(x,y) && ( x == shape.width-1 || !shape.get(x+1,y) ) && _blocked(grid.getCellAtOffset( pos, x+1, y ), blockedCellType)) return false;
		return true;
	}

	public static function isFreeTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) for (x in 0...shape.width)
			if ( shape.get(x,y) && ( y == 0 || !shape.get(x,y-1) ) && _blocked(grid.getCellAtOffset( pos, x, y-1 ), blockedCellType)) return false;
		return true;
	}

	public static function isFreeBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height) for (x in 0...shape.width)
			if ( shape.get(x,y) && ( y == shape.height-1 || !shape.get(x,y+1) ) && _blocked(grid.getCellAtOffset( pos, x, y+1 ), blockedCellType)) return false;
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

		if (unroll) {
			// -----------------------------------------------
			// ---------------- unrolled ---------------------
			// -----------------------------------------------
			var e:Array<Expr> = [];

			// ---------- _addToGrid --------------
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) ) {
						e.push(macro grid.setCellActorAtOffset(pos.x + $v{x}, pos.y + $v{y}, gR, gB, gRB, a, aR, aB, aRB));
					}
			
			fields.push({
				name: "_addToGrid",
				access: [APrivate, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"gR", opt:false, meta:[], type: macro:automat.Grid},
						{name:"gB", opt:false, meta:[], type: macro:automat.Grid},
						{name:"gRB", opt:false, meta:[], type: macro:automat.Grid},
						{name:"a", opt:false, meta:[], type: macro:automat.Cell.CellActor},
						{name:"aR", opt:false, meta:[], type: macro:automat.Cell.CellActor},
						{name:"aB", opt:false, meta:[], type: macro:automat.Cell.CellActor},
						{name:"aRB", opt:false, meta:[], type: macro:automat.Cell.CellActor},
					],
					expr: macro $b{e},
					ret: null
				})
			});
			
			// ---------- addToGrid --------------
			e = [];
			e.push(macro this.grid = grid);	
			e.push(macro this.pos = pos);	
			e.push(macro
				if ( pos.x + $v{bitGrid.width} < automat.Grid.WIDTH ) {					
					if ( pos.y + $v{bitGrid.height} < automat.Grid.HEIGHT)
						_addToGrid(null, null, null, grid.actors.add(this), 0, 0, 0);
					else
						_addToGrid(null, grid.bottom, null, grid.actors.add(this), 0, grid.bottom.actors.add(this), 0);
				}
				else {
					if ( pos.y + $v{bitGrid.height} < Grid.HEIGHT )
						_addToGrid(grid.right, null, null, grid.actors.add(this), grid.right.actors.add(this), 0, 0);
					else
						_addToGrid(grid.right, grid.bottom, grid.rightBottom,
							grid.actors.add(this), grid.right.actors.add(this), grid.bottom.actors.add(this), grid.rightBottom.actors.add(this));
				}
			);

			fields.push({
				name: "addToGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:automat.Pos}
					],
					expr: macro $b{e},
					ret: null
				})
			});

			// ---------- isFitIntoGrid --------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) ) e.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x}, $v{y}) ) ) return false);
			e.push(macro return true);

			fields.push({
				name: "isFitIntoGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:automat.Pos}
					],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// ---------- _blocked ---------------
			fields.push({
				name: "_blocked",
				access: [APrivate, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name:"cell", opt:false, meta:[], type: macro:automat.Cell}],
					expr: macro return (1<<cell.type & blockedCellType > 0 || cell.hasActor || cell.isTabu),
					ret: macro:Bool
				})
			});

			// ---------- isFreeXY ---------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) ) {
						if (x==0               || !bitGrid.get(x-1,y  )) e.push(macro if (dx==-1 && dy== 0 && _blocked(grid.getCellAtOffset(pos,$v{x-1},$v{y}  ))) return false);
						if (x==bitGrid.width-1 || !bitGrid.get(x+1,y  )) e.push(macro if (dx== 1 && dy== 0 && _blocked(grid.getCellAtOffset(pos,$v{x+1},$v{y}  ))) return false);
						if (y==0               || !bitGrid.get(x  ,y-1)) e.push(macro if (dx== 0 && dy==-1 && _blocked(grid.getCellAtOffset(pos,$v{x}  ,$v{y-1}))) return false);
						if (y==bitGrid.height-1|| !bitGrid.get(x  ,y+1)) e.push(macro if (dx== 0 && dy== 1 && _blocked(grid.getCellAtOffset(pos,$v{x}  ,$v{y+1}))) return false);
						if (x==0 || y==0       || !bitGrid.get(x-1,y-1)) e.push(macro if (dx==-1 && dy==-1 && _blocked(grid.getCellAtOffset(pos,$v{x-1},$v{y-1}))) return false);
						if (x==bitGrid.width-1 || y==0               || !bitGrid.get(x+1,y-1)) e.push(macro if (dx== 1 && dy==-1 && _blocked(grid.getCellAtOffset(pos,$v{x+1},$v{y-1}))) return false);
						if (x==0               || y==bitGrid.height-1|| !bitGrid.get(x-1,y+1)) e.push(macro if (dx==-1 && dy== 1 && _blocked(grid.getCellAtOffset(pos,$v{x-1},$v{y+1}))) return false);
						if (x==bitGrid.width-1 || y==bitGrid.height-1|| !bitGrid.get(x+1,y+1)) e.push(macro if (dx== 1 && dy== 1 && _blocked(grid.getCellAtOffset(pos,$v{x+1},$v{y+1}))) return false);
					}
			e.push(macro return true);

			fields.push({
				name: "isFreeXY",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"dx", opt:false, meta:[], type: macro:Int},
						{name:"dy", opt:false, meta:[], type: macro:Int}
					],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// ---------- isFreeLeft ---------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) && ( x == 0 || !bitGrid.get(x-1,y) ) )
						e.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x-1}, $v{y}) ) ) return false);
			e.push(macro return true);

			fields.push({
				name: "isFreeLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// ---------- isFreeRight ---------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) && ( x == bitGrid.width-1 || !bitGrid.get(x+1,y) ) )
						e.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x+1}, $v{y}) ) ) return false);
			e.push(macro return true);

			fields.push({
				name: "isFreeRight",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// ---------- isFreeTop ---------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) && ( y == 0 || !bitGrid.get(x,y-1) ) )
						e.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x}, $v{y-1}) ) ) return false);
			e.push(macro return true);

			fields.push({
				name: "isFreeTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// ---------- isFreeBottom ---------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) && ( y == bitGrid.height-1 || !bitGrid.get(x,y+1) ) )
						e.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x}, $v{y+1}) ) ) return false);
			e.push(macro return true);

			fields.push({
				name: "isFreeBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{e},
					ret: macro:Bool
				})
			});

			// TODO: more function unrolling !

		}
		else { 
			// -----------------------------------------------
			// --------------- delegated ---------------------
			// -----------------------------------------------
			fields.push({
				name: "shapeBitGrid",
				access: [APublic],
				pos: Context.currentPos(),
				kind: FVar(macro:Array<String>, macro $v{bitGrid.toArrayString()})
			});

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
						expr: macro return automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid),
						ret: macro:Bool
					})
				});

			for (fname in ["isFreeXY"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"dx", opt:false, meta:[], type: macro:Int},
							{name:"dy", opt:false, meta:[], type: macro:Int}
						],
						expr: macro return automat.actor.Shape.$fname(dx, dy, grid, pos, blockedCellType, shapeBitGrid),
						ret: macro:Bool
					})
				});

			for (fname in ["isFreeLeft","isFreeRight","isFreeTop","isFreeBottom"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro return automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid),
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