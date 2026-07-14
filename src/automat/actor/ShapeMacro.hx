package automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class ShapeMacro {
	
	// builds the unrolled functions of Shape.hx
	static public function build(bitGrid:util.BitGrid, fields:Array<Field>)
	{
		var e:Array<Expr> = [];

		// ---------- _addToGrid --------------
		var originXOffset:Int = bitGrid.originXOffset;
		for (y in 0...bitGrid.height)
			for (x in 0...bitGrid.width)
				if ( bitGrid.get(x,y) ) {
					e.push(macro grid.setCellActorAtOffset(pos.x + $v{x}, pos.y + $v{y}, gR, gB, gRB, a, aR, aB, aRB, $v{(y == 0 && x == originXOffset)}));
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
			if (pos.x + $v{bitGrid.width} < automat.Grid.WIDTH) {					
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
		e.push(macro 
			// add actor to the views
			if (pos.x + $v{originXOffset} < automat.Grid.WIDTH) {
				grid.addActorToView(this, gridKey);
			}
			else {
				grid.right.addActorToView(this, gridKeyR);
			}
		);
		
		fields.push({
			name: "addToGrid",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:util.Pos}
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
				grid.right.actors.del(gridKeyR); gridKeyR = -1; // Optimize: only if not add again (maybe add/remove extra function!)
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
					{name:"pos", opt:false, meta:[], type: macro:util.Pos}
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
			name: "freeLeft",
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
			name: "freeRight",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(1, 0)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(0, -1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(0, 1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeLeftUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(-1, -1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeLeftDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(-1, 1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeRightUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(1, -1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeRightDown",
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
			var originWasSet:Bool = false;
			var originWasDel:Bool = false;
			for (y in 0...bitGrid.height) for (x in 0...bitGrid.width) {
				if ( bitGrid.get(x,y) ) {
					if ((xOff == -1 && x == 0) || (xOff == 1 && x == bitGrid.width-1) || (yOff == -1 && y == 0) || (yOff == 1 && y == bitGrid.height-1)) {
						if (!originWasSet && y == 0 && x == originXOffset) { 
							originWasSet = true;
							e.push( macro grid.setCellActorAt(util.Pos.xy(pos.x+$v{x+xOff}, pos.y+$v{y+yOff}), gridKey, true) );
						}
						else e.push( macro grid.setCellActorAt(util.Pos.xy(pos.x+$v{x+xOff}, pos.y+$v{y+yOff}), gridKey, false) );
					}
					if ((xOff == -1 && x == bitGrid.width-1) || (xOff == 1 && x == 0) || (yOff == -1 && y == bitGrid.height-1) || (yOff == 1 && y == 0)) {
						if (!originWasDel && y == 0 && x == originXOffset) originWasDel = true;
						e.push( macro grid.delCellActorAt(util.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
					}
					else if ( !bitGrid.get(x-xOff,y-yOff) ) {
						if (!originWasDel && y == 0 && x == originXOffset) originWasDel = true;
						e.push( macro grid.delCellActorAt(util.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
					}
				}
				else if ( ( (x-xOff)>=0 && (x-xOff)<bitGrid.width && (y-yOff)>=0 && (y-yOff)<bitGrid.height ) && bitGrid.get(x-xOff,y-yOff) ) {
					if (!originWasSet && y == 0 && x == originXOffset) { 
						originWasSet = true;
						e.push( macro grid.setCellActorAt(util.Pos.xy(pos.x+$v{x}, pos.y+$v{y}), gridKey, true) );
					}
					else e.push( macro grid.setCellActorAt(util.Pos.xy(pos.x+$v{x}, pos.y+$v{y}), gridKey, false) );
				}
			}
			// remove old origin
			if (!originWasDel) e.push( macro grid.delActorOriginAt(util.Pos.xy(pos.x+$v{originXOffset}, pos.y)) );
			// change position
			e.push( macro pos = util.Pos.xy(pos.x + $v{xOff}, pos.y + $v{yOff}) );
			// set new origin
			if (!originWasSet) e.push( macro grid.setActorOriginAt(util.Pos.xy(pos.x+$v{originXOffset}, pos.y)) );
			return e;
		}

		fields.push({
			name: "goLeft",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
						$b{f(-1,0)};
					else {
						// Optimization: keep the actor key while remove and adding again
						
						// TODO: param to not remove it from the View
						var g = grid; removeFromGrid();
						
						// TODO: param to not add it to the View again!
						if (pos.x == 0) addToGrid(g.left, util.Pos.xy(Grid.WIDTH-1,pos.y));
						else addToGrid(g, util.Pos.xy(pos.x-1, pos.y));
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
			name: "goRight",
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
						if (pos.x == Grid.WIDTH-1) addToGrid(g.right, util.Pos.xy(0, pos.y));
						else addToGrid(g, util.Pos.xy(pos.x+1, pos.y));
					},
				ret: null
			})
		});

		fields.push({
			name: "goUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT && pos.x + $v{bitGrid.width} < Grid.WIDTH) // fully keep inside
						$b{f(0,-1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.y == 0) addToGrid(g.top, util.Pos.xy(pos.x, Grid.HEIGHT-1));
						else addToGrid(g, util.Pos.xy(pos.x, pos.y-1));
					},
				ret: null
			})
		});

		fields.push({
			name: "goDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.y + $v{bitGrid.height} < Grid.HEIGHT-1 && pos.x + $v{bitGrid.width} < Grid.WIDTH) // fully keep inside
						$b{f(0,1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.y == Grid.HEIGHT-1) addToGrid(g.bottom, util.Pos.xy(pos.x, 0));
						else addToGrid(g, util.Pos.xy(pos.x, pos.y+1));
					},
				ret: null
			})
		});

		fields.push({
			name: "goLeftUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
						$b{f(-1,-1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.x == 0 && pos.y == 0) addToGrid(g.leftTop, util.Pos.xy(Grid.WIDTH - 1, Grid.HEIGHT - 1));
						else if (pos.x == 0) addToGrid(g.left, util.Pos.xy(Grid.WIDTH - 1, pos.y-1));
						else if (pos.y == 0) addToGrid(g.top, util.Pos.xy(pos.x-1, Grid.HEIGHT - 1));
						else addToGrid(g, util.Pos.xy(pos.x-1, pos.y-1));
					},
				ret: null
			})
		});

		fields.push({
			name: "goLeftDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT-1) // fully keep inside
						$b{f(-1,1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.x == 0 && pos.y == Grid.HEIGHT - 1) addToGrid(g.leftBottom, util.Pos.xy(Grid.WIDTH - 1, 0));
						else if (pos.x == 0) addToGrid(g.left, util.Pos.xy(Grid.WIDTH - 1, pos.y+1));
						else if (pos.y == Grid.HEIGHT - 1) addToGrid(g.bottom, util.Pos.xy(pos.x-1, 0));
						else addToGrid(g, util.Pos.xy(pos.x-1, pos.y+1));					
					},
				ret: null
			})
		});

		fields.push({
			name: "goRightUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < Grid.WIDTH-1 && pos.y > 0 && pos.y + $v{bitGrid.height} < Grid.HEIGHT) // fully keep inside
						$b{f(1,-1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.x == Grid.WIDTH - 1 && pos.y == 0) addToGrid(g.rightTop, util.Pos.xy(0, Grid.HEIGHT - 1));
						else if (pos.x == Grid.WIDTH - 1) addToGrid(g.right, util.Pos.xy(0, pos.y-1));
						else if (pos.y == 0) addToGrid(g.bottom, util.Pos.xy(pos.x+1, Grid.HEIGHT - 1));
						else addToGrid(g, util.Pos.xy(pos.x+1, pos.y-1));
					},
				ret: null
			})
		});

		fields.push({
			name: "goRightDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < Grid.WIDTH-1 && pos.y + $v{bitGrid.height} < Grid.HEIGHT-1) // fully keep inside
						$b{f(1,1)};
					else {
						var g = grid; removeFromGrid();
						if (pos.x == Grid.WIDTH - 1 && pos.y == Grid.HEIGHT - 1) addToGrid(g.rightBottom, util.Pos.xy(0, 0));
						else if (pos.x == Grid.WIDTH - 1) addToGrid(g.left, util.Pos.xy(0, pos.y+1));
						else if (pos.y == Grid.HEIGHT - 1) addToGrid(g.bottom, util.Pos.xy(pos.x+1, 0));
						else addToGrid(g, util.Pos.xy(pos.x+1, pos.y+1));
					},
				ret: null
			})
		});

	}
}
#end