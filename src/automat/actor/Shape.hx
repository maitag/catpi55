package automat.actor;

#if !macro

import automat.Cell;
import automat.Cell.CellActor;
import util.BitGrid;
import automat.Pos.xy as P;


// 1x1 shape without macro:
class Shape1x1 {
	// TODO
}

class Shape {

	public static inline function _addToGrid(pos:Pos, xOff:Int, yOff:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int, grid:Grid, actorKey:CellActor, shape:BitGrid)	{
		for (y in yFrom...yTo) {
			for (x in xFrom...xTo) {
				if ( shape.get(x,y) ) {
					grid.setCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff), actorKey);
				}
			}
		}
	}

	public static inline function addToGrid(a:IActor, grid:Grid, pos:Pos, shape:BitGrid) {
		a.grid = grid;
		a.pos = pos;
		a.gridKey = grid.actors.add(a);
		if ( pos.x + shape.width < Grid.WIDTH ) {
			if ( pos.y + shape.height < Grid.HEIGHT) {
				_addToGrid(pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, a.gridKey, shape); // root grid
			}
			else {
				_addToGrid(pos, 0, 0, 0, shape.width, 0, pos.y + shape.height - Grid.HEIGHT, a.grid, a.gridKey, shape); // root grid
				a.gridKeyB = a.grid.bottom.actors.add(a);
				_addToGrid(pos, 0, Grid.HEIGHT, 0, shape.width, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
			}
		}
		else {
			a.gridKeyR = a.grid.right.actors.add(a);
			if ( pos.y + shape.height < Grid.HEIGHT ) {
				_addToGrid(pos, 0, 0, 0, pos.x + shape.width - Grid.WIDTH, 0, shape.height, a.grid, a.gridKey, shape); // root grid
				_addToGrid(pos, Grid.WIDTH, 0, pos.x + shape.width - Grid.WIDTH, shape.width, 0, shape.height, a.grid.right, a.gridKeyR, shape); // right
			}
			else {
				_addToGrid(pos, 0, 0, 0, pos.x + shape.width - Grid.WIDTH, 0, pos.y + shape.height - Grid.HEIGHT, a.grid, a.gridKey, shape); // root grid
				_addToGrid(pos, Grid.WIDTH, 0, pos.x + shape.width - Grid.WIDTH, shape.width, 0, pos.y + shape.height - Grid.HEIGHT, a.grid.right, a.gridKeyR, shape); // right
				a.gridKeyB = a.grid.bottom.actors.add(a);
				_addToGrid(pos, 0, Grid.HEIGHT, 0, pos.x + shape.width - Grid.WIDTH, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
				a.gridKeyRB = a.grid.rightBottom.actors.add(a);
				_addToGrid(pos, Grid.WIDTH, Grid.HEIGHT, pos.x + shape.width - Grid.WIDTH, shape.width, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.rightBottom, a.gridKeyRB, shape); // rightBottom
			}
		}
	}

	public static inline function _removeFromGrid(pos:Pos, xOff:Int, yOff:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int, grid:Grid, shape:BitGrid) {
		for (y in yFrom...yTo) {
			for (x in xFrom...xTo) {
				if ( shape.get(x,y) ) {
					grid.delCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff));
				}
			}
		}
	}

	public static inline function removeFromGrid(a:IActor, shape:BitGrid) {
		if ( a.pos.x + shape.width < Grid.WIDTH ) {
			if ( a.pos.y + shape.height < Grid.HEIGHT) {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, shape); // root grid
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid, shape); // root grid
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, shape.width, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, shape); // bottom
				a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;
			}
		}
		else {
			if ( a.pos.y + shape.height < Grid.HEIGHT ) {
				_removeFromGrid(a.pos, 0, 0, 0, a.pos.x + shape.width - Grid.WIDTH, 0, shape.height, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, a.pos.x + shape.width - Grid.WIDTH, shape.width, 0, shape.height, a.grid.right, shape); // right
				a.grid.right.actors.del(a.gridKeyR); a.gridKeyR = -1;
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, a.pos.x + shape.width - Grid.WIDTH, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, a.pos.x + shape.width - Grid.WIDTH, shape.width, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid.right, shape); // right
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, a.pos.x + shape.width - Grid.WIDTH, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, shape); // bottom
				_removeFromGrid(a.pos, Grid.WIDTH, Grid.HEIGHT, a.pos.x + shape.width - Grid.WIDTH, shape.width, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.rightBottom, shape); // rightBottom
				a.grid.right.actors.del(a.gridKeyR); a.gridKeyR = -1;
				a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;
				a.grid.rightBottom.actors.del(a.gridKeyRB); a.gridKeyRB = -1;
			}
		}
		a.grid.actors.del(a.gridKey); a.gridKey = -1;
		a.grid = null;
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

			// TODO: here i am need also something like Nanjis Morton-traversing (from outer edged to inner!)
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
						// TODO: here no extra checks is need!
						_addToGrid(null, null, null, grid.actors.add(this), 0, 0, 0);
					else // TODO: another way to add the actor to grid-actors -> on demand ! (really hard to unroll)
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

			for (fname in ["removeFromGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro automat.actor.Shape.$fname(this, shapeBitGrid),
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