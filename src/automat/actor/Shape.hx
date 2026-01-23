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
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.setCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff), actorKey);
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
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.delCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff));
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
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, a.pos.x + shape.width - Grid.WIDTH, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, a.pos.x + shape.width - Grid.WIDTH, shape.width, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid.right, shape); // right
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, a.pos.x + shape.width - Grid.WIDTH, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, shape); // bottom
				_removeFromGrid(a.pos, Grid.WIDTH, Grid.HEIGHT, a.pos.x + shape.width - Grid.WIDTH, shape.width, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.rightBottom, shape); // rightBottom
				a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;
				a.grid.rightBottom.actors.del(a.gridKeyRB); a.gridKeyRB = -1;
			}
			a.grid.right.actors.del(a.gridKeyR); a.gridKeyR = -1;
		}
		a.grid.actors.del(a.gridKey); a.gridKey = -1;
		a.grid = null;
	}

	public static function isFitIntoGrid(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if (shape.get(x,y) && _blocked(grid.getCellAtOffset( pos, x, y ), blockedCellType)) return false;
		return true;
	}

	static inline function _blocked(cell:Cell, blockedCellType:Int):Bool {
		return (1<<cell.type & blockedCellType > 0 || cell.hasActor || cell.isTabu); // to store one more CellType: return (1<<(cell.type-1) & blockedCellType > 0 || cell.isTabu || cell.hasActor);
	}
	
	public static function _isFreeSide(sideFunc:Int->Int->Bool, xOff:Int, yOff:Int, grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid) {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if ( shape.get(x,y) && (sideFunc(x,y) || !shape.get(x+xOff,y+yOff)) && _blocked(grid.getCellAtOffset( pos, x+xOff, y+yOff), blockedCellType)) return false;
		return true;
	}

	public static function isFreeLeft(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x==0;}, -1, 0, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRight(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x == shape.width-1;}, 1, 0, grid, pos, blockedCellType, shape );
	}
	public static function isFreeTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return y==0;}, 0, -1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return y == shape.height-1;}, 0, 1, grid, pos, blockedCellType, shape );
	}

	public static function isFreeLeftTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x==0 || y==0;}, -1, -1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeLeftBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x==0 || y == shape.height-1;}, -1, 1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRightTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x == shape.width-1 || y==0;}, 1, -1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRightBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( (x,y)->{return x == shape.width-1 || y == shape.height-1;}, 1, 1, grid, pos, blockedCellType, shape );
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
	static public function build(shape:String, unroll = true):Array<Field>
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
						{name:"aRB", opt:false, meta:[], type: macro:automat.Cell.CellActor}
					],
					expr: macro $b{e},
					ret: null
				})
			});
			
			// ---------- addToGrid --------------
			e = [];
			e.push(macro this.grid = grid);	
			e.push(macro this.pos = pos);	
			e.push(macro gridKey = grid.actors.add(this));	
			e.push(macro 
				if ( pos.x + $v{bitGrid.width} < automat.Grid.WIDTH ) {					
					if ( pos.y + $v{bitGrid.height} < automat.Grid.HEIGHT) {
						_addToGrid(null, null, null, gridKey, 0, 0, 0);
					}
					else {
						gridKeyB = grid.bottom.actors.add(this);
						_addToGrid(null, grid.bottom, null, gridKey, 0, gridKeyB, 0);
					}
				}
				else {
					gridKeyR = grid.right.actors.add(this);
					if ( pos.y + $v{bitGrid.height} < Grid.HEIGHT ) {
						_addToGrid(grid.right, null, null, gridKey, gridKeyR, 0, 0);
					}
					else {
						gridKeyB = grid.bottom.actors.add(this);
						gridKeyRB = grid.rightBottom.actors.add(this);
						_addToGrid(grid.right, grid.bottom, grid.rightBottom, gridKey, gridKeyR, gridKeyB, gridKeyRB);
					}
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

			// ---------- _removeFromGrid --------------
			e = [];
			for (y in 0...bitGrid.height)
				for (x in 0...bitGrid.width)
					if ( bitGrid.get(x,y) ) {
						e.push(macro grid.delCellActorAtOffset(pos.x + $v{x}, pos.y + $v{y}, gR, gB, gRB));
					}			
			fields.push({
				name: "_removeFromGrid",
				access: [APrivate, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"gR", opt:false, meta:[], type: macro:automat.Grid},
						{name:"gB", opt:false, meta:[], type: macro:automat.Grid},
						{name:"gRB", opt:false, meta:[], type: macro:automat.Grid}
					],
					expr: macro $b{e},
					ret: null
				})
			});
			
			// ---------- removeFromGrid --------------
			e = [];
			e.push(macro 
				if ( pos.x + $v{bitGrid.width} < automat.Grid.WIDTH ) {					
					if ( pos.y + $v{bitGrid.height} < automat.Grid.HEIGHT) {
						_removeFromGrid(null, null, null);
					}
					else {
						_removeFromGrid(null, grid.bottom, null);
						grid.bottom.actors.del(gridKeyB); gridKeyB = -1;
					}
				}
				else {
					if ( pos.y + $v{bitGrid.height} < Grid.HEIGHT ) {
						_removeFromGrid(grid.right, null, null);
					}
					else {
						_removeFromGrid(grid.right, grid.bottom, grid.rightBottom);
						grid.bottom.actors.del(gridKeyB); gridKeyB = -1;
						grid.rightBottom.actors.del(gridKeyRB); gridKeyRB = -1;
					}
					grid.right.actors.del(gridKeyR); gridKeyR = -1;
				}
			);
			e.push(macro grid.actors.del(gridKey));
			e.push(macro gridKey = -1);	
			e.push(macro grid = null);	

			fields.push({
				name: "removeFromGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
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


			// ----------------------------------
			// ---------- isFree  ---------------
			// ----------------------------------
			var f = function(sideFunc:Int->Int->Bool, xOff:Int, yOff:Int, checkLeft=true, checkRight=true, checkTop=true, checkBottom=true):Array<Expr> {
				var ee:Array<Expr> = [];
				for (y in 0...bitGrid.height)
					for (x in 0...bitGrid.width)
						if ( bitGrid.get(x,y) && ( sideFunc(x, y) || !bitGrid.get(x+xOff,y+yOff) ) )
							ee.push(macro if ( _blocked( grid.getCellAtOffset(pos, $v{x+xOff}, $v{y+yOff}, $v{checkLeft}, $v{checkRight}, $v{checkTop}, $v{checkBottom}) ) ) return false);
				ee.push(macro return true);
				return ee;
			}

			// ---------- isFreeLeft ---------------
			fields.push({
				name: "isFreeLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x == 0;}, -1, 0 )},
					// more optimized:
					/*expr: macro 
						if (pos.x == 0) {
							if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f((x,y)->{return x==0;},-1,0,true,false,false,false)}; // left
							else $b{f((x,y)->{return x==0;},-1,0,true,false,false,true)}; // left, bottom
						}
						else if (pos.x + $v{bitGrid.width} > Grid.WIDTH) {
							if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f((x,y)->{return x==0;},-1,0,false,true,false,false)}; // right
							else $b{f((x,y)->{return x==0;},-1,0,false,true,false,true)};  // right, bottom
						}
						else if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f((x,y)->{return x==0;},-1,0,false,false,false,false)}; // fully inside
						else $b{f(-1,0,false,false,false,true)} // bottom
					,*/
					ret: macro:Bool
				})
			});

			// ---------- isFreeRight ---------------
			fields.push({
				name: "isFreeRight",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x == bitGrid.width-1;}, 1, 0 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeTop ---------------
			fields.push({
				name: "isFreeTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return y == 0;}, 0, -1 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeBottom ---------------
			fields.push({
				name: "isFreeBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return y == bitGrid.height-1;}, 0, 1 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeLeftTop ---------------
			fields.push({
				name: "isFreeLeftTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x==0 || y==0;}, -1, -1 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeLeftBottom ---------------
			fields.push({
				name: "isFreeLeftBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x==0 || y == bitGrid.height-1;}, -1, 1 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeRightTop ---------------
			fields.push({
				name: "isFreeRightTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x == bitGrid.width-1 || y==0;}, 1, -1 )},
					ret: macro:Bool
				})
			});

			// ---------- isFreeRightBottom ---------------
			fields.push({
				name: "isFreeRightBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f( (x,y)->{return x == bitGrid.width-1 || y == bitGrid.height-1;}, 1, 1 )},
					ret: macro:Bool
				})
			});


			// TODO: move


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

			for (fname in ["isFreeLeft","isFreeRight","isFreeTop","isFreeBottom","isFreeLeftTop","isFreeLeftBottom","isFreeRightTop","isFreeRightBottom"])
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

			// TODO: move
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