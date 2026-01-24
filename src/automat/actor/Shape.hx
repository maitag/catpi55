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
	
	public static function _isFreeSide(xOff:Int, yOff:Int, grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid) {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if ( shape.get(x,y) && ((x+xOff)<0 || (x+xOff)>=shape.width || (y+yOff)<0 || (y+yOff)>=shape.height || !shape.get(x+xOff,y+yOff)) && _blocked(grid.getCellAtOffset( pos, x+xOff, y+yOff), blockedCellType)) return false;
		return true;
	}

	public static function isFreeLeft(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1, 0, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRight(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1, 0, grid, pos, blockedCellType, shape );
	}
	public static function isFreeTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0,-1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0, 1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeLeftTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1,-1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeLeftBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1, 1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRightTop(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1,-1, grid, pos, blockedCellType, shape );
	}
	public static function isFreeRightBottom(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1, 1, grid, pos, blockedCellType, shape );
	}


	public static function moveLeft(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		if (a.pos.x == 0) addToGrid(a, g.left, P(shape.width - 1, a.pos.y), shape);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y), shape);
	}
	public static function moveRight(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		if (a.pos.x == shape.width - 1) addToGrid(a, g.right, P(0, a.pos.y), shape);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y), shape);
	}
	public static function moveTop(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x, shape.height - 1), shape);
		else addToGrid(a, g, P(a.pos.x, a.pos.y-1), shape);
	}
	public static function moveBottom(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		if (a.pos.y == shape.height - 1) addToGrid(a, g.bottom, P(a.pos.x, 0), shape);
		else addToGrid(a, g, P(a.pos.x, a.pos.y+1), shape);
	}
	public static function moveLeftTop(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		var x:Int = a.pos.x-1; var y:Int = a.pos.y-1;
		if (x < 0 && y < 0) { x = shape.width - 1; y = shape.height - 1; g = g.leftTop; }
		else if (x < 0) { x = shape.width - 1; g = g.left; }
		else if (y < 0) { y = shape.height - 1; g = g.top; }
		else addToGrid(a, g, P(x, y), shape);
	}
	public static function moveLeftBottom(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		var x:Int = a.pos.x-1; var y:Int = a.pos.y+1;
		if (x < 0 && y >= shape.height) { x = shape.width - 1; y = 0; g = g.leftBottom; }
		else if (x < 0) { x = shape.width - 1; g = g.left; }
		else if (y >= shape.height) { y = 0; g = g.bottom; }
		else addToGrid(a, g, P(x, y), shape);
	}
	public static function moveRightTop(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		var x:Int = a.pos.x+1; var y:Int = a.pos.y-1;
		if (x >= shape.width && y < 0) { x = 0; y = shape.height - 1; g = g.rightTop; }
		else if (x >= shape.width) { x = 0; g = g.right; }
		else if (y < 0) { y = shape.height - 1; g = g.top; }
		else addToGrid(a, g, P(x, y), shape);
	}
	public static function moveRightBottom(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape);
		var x:Int = a.pos.x+1; var y:Int = a.pos.y+1;
		if (x >= shape.width && y >= shape.height) { x = 0; y = 0; g = g.rightBottom; }
		else if (x >= shape.width) { x = 0; g = g.right; }
		else if (y >= shape.height) { y = 0; g = g.bottom; }
		else addToGrid(a, g, P(x, y), shape);
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
			var f = function(xOff:Int, yOff:Int, checkLeft=true, checkRight=true, checkTop=true, checkBottom=true):Array<Expr> {
				var e:Array<Expr> = [];
				for (y in 0...bitGrid.height)
					for (x in 0...bitGrid.width)
						if (bitGrid.get(x,y) && ((x+xOff)<0 || (x+xOff)>=bitGrid.width || (y+yOff)<0 || (y+yOff)>=bitGrid.height || !bitGrid.get(x+xOff,y+yOff)))
							e.push(macro if (_blocked(grid.getCellAtOffset(pos, $v{x+xOff}, $v{y+yOff}, $v{checkLeft}, $v{checkRight}, $v{checkTop}, $v{checkBottom}))) return false);
				e.push(macro return true);
				return e;
			}

			fields.push({
				name: "isFreeLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(-1, 0)},
					// more optimized:
					/*expr: macro 
						if (pos.x == 0) {
							if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f(-1,0,true,false,false,false)}; // left
							else $b{f(-1,0,true,false,false,true)}; // left, bottom
						}
						else if (pos.x + $v{bitGrid.width} > Grid.WIDTH) {
							if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f(-1,0,false,true,false,false)}; // right
							else $b{f(-1,0,false,true,false,true)};  // right, bottom
						}
						else if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) $b{f(-1,0,false,false,false,false)}; // fully inside
						else $b{f(-1,0,false,false,false,true)} // bottom
					,*/
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeRight",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(1, 0)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(0, -1)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(0, 1)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeLeftTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(-1, -1)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeLeftBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(-1, 1)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeRightTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(1, -1)},
					ret: macro:Bool
				})
			});

			fields.push({
				name: "isFreeRightBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro $b{f(1, 1)},
					ret: macro:Bool
				})
			});


			// ----------------------------------
			// ------------ MOVE ----------------
			// ----------------------------------
			var f = function(xOff:Int, yOff:Int):Array<Expr> {
				var e:Array<Expr> = [];
				for (y in 0...bitGrid.height) for (x in 0...bitGrid.width) {
					if ( bitGrid.get(x,y) ) {
						if ((xOff == -1 && x == 0) || (xOff == 1 && x == bitGrid.width-1) || (yOff == -1 && y == 0) || (yOff == 1 && y == bitGrid.height-1))
							e.push( macro grid.setCellActorAt(automat.Pos.xy(pos.x+$v{x+xOff}, pos.y+$v{y+yOff}), gridKey) );
						if ((xOff == -1 && x == bitGrid.width-1) || (xOff == 1 && x == 0) || (yOff == -1 && y == bitGrid.height-1) || (yOff == 1 && y == 0)) 
							e.push( macro grid.delCellActorAt(automat.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
						else if ( !bitGrid.get(x-xOff,y-yOff) )
							e.push( macro grid.delCellActorAt(automat.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
					}
					else if ( ( (x-xOff)>=0 && (x-xOff)<bitGrid.width && (y-yOff)>=0 && (y-yOff)<bitGrid.height ) && bitGrid.get(x-xOff,y-yOff) )
						e.push( macro grid.setCellActorAt(automat.Pos.xy(pos.x+$v{x}, pos.y+$v{y}), gridKey) );
				}
				e.push( macro pos = automat.Pos.xy(pos.x + $v{xOff}, pos.y + $v{yOff}) ); // change position
				return e;
			}

			fields.push({
				name: "moveLeft",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
							$b{f(-1,0)};
						else {
							var g = grid; removeFromGrid();
							if (pos.x == 0) addToGrid(g.left, automat.Pos.xy($v{bitGrid.width - 1},pos.y));
							else addToGrid(g, automat.Pos.xy(pos.x-1, pos.y));
						}
						// TODO: more optimized and grid-neigbour-change:
						/*
						if (pos.x > 0)
						{
							if (pos.x + $v{bitGrid.width} < Grid.WIDTH) { // fully keep inside
								$b{f(-1,0)};
							}
							else if (pos.x + $v{bitGrid.width} == Grid.WIDTH) {
								if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) {
									$b{f(-1,0)};
									grid.right.actors.del(gridKeyR); gridKeyR = -1;  // leave right grid
								}
								else {
									$b{f(-1,0)};
									grid.right.actors.del(gridKeyR); gridKeyR = -1;  // leave right grid
									grid.rightBottom.actors.del(gridKeyRB); gridKeyRB = -1;  // leave rightBottom grid
								}
							}
							else {
								if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) {
									$b{f(-1,0)};
								}
								else {
									$b{f(-1,0)};
								}
							}
						}
						else { // pos.x == 0
							if (pos.y + $v{bitGrid.height} < Grid.HEIGHT) {
								$b{f(-1,0)}; // TODO
								grid.right = grid; gridKeyR = gridKey; grid = grid.left; gridKey = grid.actors.add();// enter left grid
							}
							else {
								$b{f(-1,0)};
								grid.rightBottom = grid; grid = grid.left; gridKey = grid.actors.add(); // enter left grid
								grid.right = grid; grid = grid.left; gridKey = grid.actors.add(); // enter left grid
							}
					}
					*/
					,
					ret: null
				})
			});

			fields.push({
				name: "moveRight",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x + $v{bitGrid.width} < Grid.WIDTH-1 && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
							$b{f(1,0)};
						else {
							var g = grid;
							removeFromGrid();
							if (pos.x == $v{bitGrid.width - 1}) addToGrid(g.right, automat.Pos.xy(0, pos.y));
							else addToGrid(g, automat.Pos.xy(pos.x+1, pos.y));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT && pos.x + $v{bitGrid.width} < Grid.WIDTH) // fully keep inside
							$b{f(0,-1)};
						else {
							var g = grid; removeFromGrid();
							if (pos.y == 0) addToGrid(g.top, automat.Pos.xy(pos.x, $v{bitGrid.height - 1}));
							else addToGrid(g, automat.Pos.xy(pos.x, pos.y-1));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.y + $v{bitGrid.height} < Grid.HEIGHT-1 && pos.x + $v{bitGrid.width} < Grid.WIDTH) // fully keep inside
							$b{f(0,1)};
						else {
							var g = grid; removeFromGrid();
							if (pos.y == $v{bitGrid.height - 1}) addToGrid(g.bottom, automat.Pos.xy(pos.x, 0));
							else addToGrid(g, automat.Pos.xy(pos.x, pos.y+1));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveLeftTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
							$b{f(-1,-1)};
						else {
							var g = grid; removeFromGrid();
							var x:Int = pos.x-1; var y:Int = pos.y-1;
							if (x < 0 && y < 0) { x = $v{bitGrid.width-1}; y = $v{bitGrid.height-1}; g = g.leftTop; }
							else if (x < 0) { x = $v{bitGrid.width-1}; g = g.left; }
							else if (y < 0) { y = $v{bitGrid.height-1}; g = g.top; }
							else addToGrid(g, automat.Pos.xy(x, y));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveLeftBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT-1) // fully keep inside
							$b{f(-1,1)};
						else {
							var g = grid; removeFromGrid();
							var x:Int = pos.x-1; var y:Int = pos.y+1;
							if (x < 0 && y >= $v{bitGrid.height}) { x = $v{bitGrid.width-1}; y = 0; g = g.leftBottom; }
							else if (x < 0) { x = $v{bitGrid.width-1}; g = g.left; }
							else if (y >= $v{bitGrid.height}) { y = 0; g = g.bottom; }
							else addToGrid(g, automat.Pos.xy(x, y));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveRightTop",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x + $v{bitGrid.width} < Grid.WIDTH-1 && pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
							$b{f(1,-1)};
						else {
							var g = grid; removeFromGrid();
							var x:Int = pos.x+1; var y:Int = pos.y-1;
							if (x >= $v{bitGrid.width} && y < 0) { x = 0; y = $v{bitGrid.height-1}; g = g.rightTop; }
							else if (x >= $v{bitGrid.width}) { x = 0; g = g.right; }
							else if (y < 0) { y = $v{bitGrid.height-1}; g = g.top; }
							else addToGrid(g, automat.Pos.xy(x, y));
						},
					ret: null
				})
			});

			fields.push({
				name: "moveRightBottom",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro 
						if (pos.x + $v{bitGrid.width} < Grid.WIDTH-1 && pos.y + $v{bitGrid.height} < Grid.HEIGHT-1) // fully keep inside
							$b{f(1,1)};
						else {
							var g = grid; removeFromGrid();
							var x:Int = pos.x+1; var y:Int = pos.y+1;
							if (x >= $v{bitGrid.width} && y >= $v{bitGrid.height}) { x = 0; y = 0; g = g.rightBottom; }
							else if (x >= $v{bitGrid.width}) { x = 0; g = g.right; }
							else if (y >= $v{bitGrid.height}) { y = 0; g = g.bottom; }
							else addToGrid(g, automat.Pos.xy(x, y));
						},
					ret: null
				})
			});


		}
		else { 
			// -------------------------------------------------------------------------------
			// ----------------------------- delegated ---------------------------------------
			// -------------------------------------------------------------------------------
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

			for (fname in ["moveLeft","moveRight","moveTop","moveBottom","moveLeftTop","moveLeftBottom","moveRightTop","moveRightBottom"
				])
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

		}

		// ------------------------------------------------
		// ------------------------------------------------
		// ------------------------------------------------

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