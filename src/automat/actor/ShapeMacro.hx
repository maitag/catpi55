package automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class ShapeMacro {
	
	// builds the unrolled functions of Shape.hx
	static public function build(bitGrid:util.BitGrid, fields:Array<Field>)
	{
		var e:Array<Expr> = [];

		// ---------- __addToGrid --------------
		var originXOffset:Int = bitGrid.originXOffset;
		for (y in 0...bitGrid.height)
			for (x in 0...bitGrid.width)
				if ( bitGrid.get(x,y) ) {
					e.push(macro grid.setCellActorAtOffset(pos.x + $v{x}, pos.y + $v{y}, gR, gB, gRB, a, aR, aB, aRB, $v{(y == 0 && x == originXOffset)}));
				}			
		fields.push({
			name: "__addToGrid",
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"gR", opt:false, meta:[], type: macro:automat.Grid},
					{name:"gB", opt:false, meta:[], type: macro:automat.Grid},
					{name:"gRB", opt:false, meta:[], type: macro:automat.Grid},
					{name:"a", opt:false, meta:[], type: macro:automat.Cell.CellActor}, // TODO: use INT everywhere!
					{name:"aR", opt:false, meta:[], type: macro:automat.Cell.CellActor},
					{name:"aB", opt:false, meta:[], type: macro:automat.Cell.CellActor},
					{name:"aRB", opt:false, meta:[], type: macro:automat.Cell.CellActor}
				],
				expr: macro $b{e},
				ret: null
			})
		});
		
		// ---------- _addToGrid --------------
		e = [];
		// TODO: keepGrid=false argument, to optimize MODE functions (remove+add again)
		e.push(macro this.grid = grid);	
		e.push(macro this.pos = pos);	
		e.push(macro gridKey = grid.actors.add(this));	
		e.push(macro 
			if (pos.x + $v{bitGrid.width} <= automat.Grid.WIDTH) {					
				if ( pos.y + $v{bitGrid.height} <= automat.Grid.HEIGHT) {
					__addToGrid(null, null, null, gridKey, 0, 0, 0);
				}
				else {
					gridKeyB = grid.bottom.actors.add(this);
					__addToGrid(null, grid.bottom, null, gridKey, 0, gridKeyB, 0);
				}
			}
			else {
				gridKeyR = grid.right.actors.add(this);
				if ( pos.y + $v{bitGrid.height} <= Grid.HEIGHT ) {
					__addToGrid(grid.right, null, null, gridKey, gridKeyR, 0, 0);
				}
				else {
					gridKeyB = grid.bottom.actors.add(this);
					gridKeyRB = grid.rightBottom.actors.add(this);
					__addToGrid(grid.right, grid.bottom, grid.rightBottom, gridKey, gridKeyR, gridKeyB, gridKeyRB);
				}
			}
		);
		e.push(macro 
			// add actor to the views
			if (syncToView) {
				if (pos.x + $v{originXOffset} < automat.Grid.WIDTH) {
					grid.viewsActorAdd(this, gridKey, pos.x + $v{originXOffset});
				}
				else {
					grid.right.viewsActorAdd(this, gridKeyR, (pos.x + $v{originXOffset}) % Grid.WIDTH);
				}
			}
		);
		
		fields.push({
			name: "_addToGrid",
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:util.Pos},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro $b{e},
				ret: null
			})
		});

		// ---------- addToGrid --------------
		fields.push({
			name: "addToGrid",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:util.Pos},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro _addToGrid(grid, pos, syncToView),
				ret: null
			})
		});

		// ---------- __removeFromGrid --------------
		e = [];
		for (y in 0...bitGrid.height)
			for (x in 0...bitGrid.width)
				if ( bitGrid.get(x,y) ) {
					e.push(macro grid.delCellActorAtOffset(pos.x + $v{x}, pos.y + $v{y}, gR, gB, gRB));
				}			
		fields.push({
			name: "__removeFromGrid",
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
		
		// ---------- _removeFromGrid --------------
		e = [];
		// TODO: keepGrid=false argument, to optimize MOVE functions (remove+add again)
		e.push(macro 
			if ( pos.x + $v{bitGrid.width} <= automat.Grid.WIDTH ) {					
				if ( pos.y + $v{bitGrid.height} <= automat.Grid.HEIGHT) {
					__removeFromGrid(null, null, null);
				}
				else {
					__removeFromGrid(null, grid.bottom, null);
					grid.bottom.actors.del(gridKeyB); gridKeyB = -1;
				}
			}
			else {
				if ( pos.y + $v{bitGrid.height} <= Grid.HEIGHT ) {
					__removeFromGrid(grid.right, null, null);
				}
				else {
					__removeFromGrid(grid.right, grid.bottom, grid.rightBottom);
					grid.bottom.actors.del(gridKeyB); gridKeyB = -1;
					grid.rightBottom.actors.del(gridKeyRB); gridKeyRB = -1;
				}
				grid.right.actors.del(gridKeyR); //gridKeyR = -1;
			}
		);
		e.push(macro grid.actors.del(gridKey));
		e.push(macro 
			// trigger actor-remove to the origin corresponding grid and its views
			if (syncToView) {
				if (pos.x + $v{originXOffset} < automat.Grid.WIDTH) grid.viewsActorRemove(this, gridKey, pos.x + $v{originXOffset});
				else grid.right.viewsActorRemove(this, gridKeyR, (pos.x + $v{originXOffset}) % automat.Grid.WIDTH);
			}
		);
		e.push(macro gridKey = -1);
		e.push(macro gridKeyR = -1);
		e.push(macro grid = null);
		
		fields.push({
			name: "_removeFromGrid",
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}],
				expr: macro $b{e},
				ret: null
			})
		});

		// ---------- removeFromGrid --------------
		fields.push({
			name: "removeFromGrid",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}],
				expr: macro _removeFromGrid(syncToView),
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

		// TODO: implement "checkSize"

		fields.push({
			name: "freeLeftUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"checkSide", opt:false, meta:[], type: macro:Bool, value:macro false}],
				expr: macro if (checkSide) {return freeLeft() && freeLeftUp(false);} else $b{f(-1, -1)},
				// expr: macro $b{f(-1, -1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeLeftDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"checkSide", opt:false, meta:[], type: macro:Bool, value:macro false}],
				expr: macro if (checkSide) {return freeLeft() && freeLeftDown(false);} else $b{f(-1, 1)},
				// expr: macro $b{f(-1, 1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeRightUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"checkSide", opt:false, meta:[], type: macro:Bool, value:macro false}],
				expr: macro if (checkSide) {return freeRight() && freeRightUp(false);} else $b{f(1, -1)},
				// expr: macro $b{f(1, -1)},
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeRightDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [{name:"checkSide", opt:false, meta:[], type: macro:Bool, value:macro false}],
				expr: macro if (checkSide) {return freeRight() && freeRightDown(false);} else $b{f(1, 1)},
				// expr: macro $b{f(1, 1)},
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

		// TODO: refactor constant arguments for view-sync out!
		
		// ------- left -------
		fields.push({
			name: "goLeft",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= Grid.WIDTH && pos.y + $v{bitGrid.height} <= Grid.HEIGHT) { // fully keep inside
						$b{f(-1,0)};
						if (syncToView) grid.viewsActorToLeft(this, gridKey, pos.x + $v{originXOffset}+1, pos.x + $v{originXOffset}, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }
										
						_removeFromGrid(false);						
						if (pos.x == 0) _addToGrid(g.left, util.Pos.xy(Grid.WIDTH-1,pos.y), false);
						else _addToGrid(g, util.Pos.xy(pos.x-1, pos.y), false);
												
						if (syncToView) { // sync views
							if (oldX > 0) oldGrid.viewsActorToLeft(this, oldKey, oldX, oldX-1, time);
							else {
								var newX:Int = Grid.WIDTH-1;
								var newGrid = oldGrid.left;
								var newKey:Int = gridKey;
								oldGrid.viewsActorToLeftOut(this, newGrid, oldKey, newKey, oldX, newX, time);
								newGrid.viewsActorToLeftIn(this, oldGrid, newKey, oldX, newX, time);
							}
						}
					},
				ret: null
			})
		});
		// ------- right -------
		fields.push({
			name: "goRight",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} <= Grid.HEIGHT) { // fully keep inside
						$b{f(1,0)};
						if (syncToView) grid.viewsActorToRight(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }
				
						_removeFromGrid(false);
						if (pos.x == Grid.WIDTH-1) _addToGrid(g.right, util.Pos.xy(0, pos.y), false);
						else _addToGrid(g, util.Pos.xy(pos.x+1, pos.y), false);

						if (syncToView) { // sync views
							if (oldX < Grid.WIDTH-1) oldGrid.viewsActorToRight(this, oldKey, oldX, oldX+1, time);
							else {
								var newX:Int = 0;
								var newGrid = oldGrid.right;
								var newKey:Int = ($v{originXOffset} == 0) ? gridKey : gridKeyR;
								oldGrid.viewsActorToRightOut(this, newGrid, oldKey, newKey, oldX, newX, time);
								newGrid.viewsActorToRightIn(this, oldGrid, newKey, oldX, newX, time);
							}
						}
					},
				ret: null
			})
		});
		// ------- top -------
		fields.push({
			name: "goUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.y > 0 && pos.y + $v{bitGrid.height} <= Grid.HEIGHT && pos.x + $v{bitGrid.width} <= Grid.WIDTH) { // fully keep inside
						$b{f(0,-1)};
						if (syncToView) grid.viewsActorToUp(this, gridKey, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }
										
						_removeFromGrid(false);
						if (pos.y == 0) _addToGrid(g.top, util.Pos.xy(pos.x, Grid.HEIGHT-1), false);
						else _addToGrid(g, util.Pos.xy(pos.x, pos.y-1), false);
						
						if (syncToView) { // sync views							
							if (oldY > 0) oldGrid.viewsActorToUp(this, oldKey, oldX, oldY, oldY-1, time);
							else {
								var newY:Int = Grid.HEIGHT-1;
								var newGrid = oldGrid.top;
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToUpOut(this, newGrid, oldKey, newKey, oldX, oldY, newY, time);
								newGrid.viewsActorToUpIn(this, oldGrid, newKey, oldX, oldY, newY, time);
							}
						}
					},
				ret: null
			})
		});
		// ------- down -------
		fields.push({
			name: "goDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.y + $v{bitGrid.height} < Grid.HEIGHT && pos.x + $v{bitGrid.width} <= Grid.WIDTH) { // fully keep inside
						$b{f(0,1)};
						if (syncToView) grid.viewsActorToDown(this, gridKey, pos.x + $v{originXOffset}, pos.y - 1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }
				
						_removeFromGrid(false);
						if (pos.y == Grid.HEIGHT-1) _addToGrid(g.bottom, util.Pos.xy(pos.x, 0), false);
						else _addToGrid(g, util.Pos.xy(pos.x, pos.y+1), false);

						if (syncToView) { // sync views							
							if (oldY < Grid.HEIGHT-1) oldGrid.viewsActorToDown(this, oldKey, oldX, oldY, oldY+1, time);
							else {
								var newY:Int = 0;
								var newGrid = oldGrid.bottom;
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToDownOut(this, newGrid, oldKey, newKey, oldX, oldY, newY, time);
								newGrid.viewsActorToDownIn(this, oldGrid, newKey, oldX, oldY, newY, time);
							}
						}
					},
				ret: null
			})
		});
		// ------- leftUp -------
		fields.push({
			name: "goLeftUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} <= Grid.HEIGHT) { // fully keep inside
						$b{f(-1,-1)};
						if (syncToView) grid.viewsActorToLeftUp(this, gridKey, pos.x + $v{originXOffset}+1, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }

						_removeFromGrid(false);
						if (pos.x == 0 && pos.y == 0) _addToGrid(g.leftTop, util.Pos.xy(Grid.WIDTH - 1, Grid.HEIGHT - 1), false);
						else if (pos.x == 0) _addToGrid(g.left, util.Pos.xy(Grid.WIDTH - 1, pos.y-1), false);
						else if (pos.y == 0) _addToGrid(g.top, util.Pos.xy(pos.x-1, Grid.HEIGHT - 1), false);
						else _addToGrid(g, util.Pos.xy(pos.x-1, pos.y-1), false);

						if (syncToView) { // sync views
							if (oldX > 0 && oldY > 0) oldGrid.viewsActorToLeftUp(this, oldKey, oldX, oldX-1, oldY, oldY-1, time);
							else {			
								var newX:Int = (oldX > 0) ? oldX-1 : Grid.WIDTH-1;
								var newY:Int = (oldY > 0) ? oldY-1 : Grid.HEIGHT-1;
								var newGrid = (oldX == 0 && oldY == 0) ? oldGrid.leftTop  :  ((oldX == 0) ? oldGrid.left : oldGrid.top);
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToLeftUpOut(this, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
								newGrid.viewsActorToLeftUpIn(this, oldGrid, newKey, oldX, newX, oldY, newY, time);				
							}
						}				
					},
				ret: null
			})
		});
		// ------- leftDown -------
		fields.push({
			name: "goLeftDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT) { // fully keep inside
						$b{f(-1,1)};
						if (syncToView) grid.viewsActorToLeftDown(this, gridKey, pos.x + $v{originXOffset}+1,  pos.x + $v{originXOffset}, pos.y-1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }

						_removeFromGrid(false);
						if (pos.x == 0 && pos.y == Grid.HEIGHT - 1) _addToGrid(g.leftBottom, util.Pos.xy(Grid.WIDTH - 1, 0), false);
						else if (pos.x == 0) _addToGrid(g.left, util.Pos.xy(Grid.WIDTH - 1, pos.y+1), false);
						else if (pos.y == Grid.HEIGHT - 1) _addToGrid(g.bottom, util.Pos.xy(pos.x-1, 0), false);
						else _addToGrid(g, util.Pos.xy(pos.x-1, pos.y+1), false);

						if (syncToView) { // sync views
							if (oldX > 0 && oldY < Grid.HEIGHT-1) oldGrid.viewsActorToLeftDown(this, oldKey, oldX, oldX-1, oldY, oldY+1, time);
							else {			
								var newX:Int = (oldX > 0) ? oldX-1 : Grid.WIDTH-1;
								var newY:Int = (oldY < Grid.HEIGHT-1) ? oldY+1 : 0;
								var newGrid:Grid = (oldX == 0 && oldY == Grid.HEIGHT-1) ? oldGrid.leftBottom  :  ((oldX == 0) ? oldGrid.left : oldGrid.bottom);
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToLeftDownOut(this, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
								newGrid.viewsActorToLeftDownIn(this, oldGrid, newKey, oldX, newX, oldY, newY, time);				
							}
						}									
					},
				ret: null
			})
		});
		// ------- rightUp -------
		fields.push({
			name: "goRightUp",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} <= Grid.HEIGHT) { // fully keep inside
						$b{f(1,-1)};
						if (syncToView) grid.viewsActorToRightUp(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }

						_removeFromGrid(false);
						if (pos.x == Grid.WIDTH - 1 && pos.y == 0) _addToGrid(g.rightTop, util.Pos.xy(0, Grid.HEIGHT - 1), false);
						else if (pos.x == Grid.WIDTH - 1) _addToGrid(g.right, util.Pos.xy(0, pos.y-1), false);
						else if (pos.y == 0) _addToGrid(g.top, util.Pos.xy(pos.x+1, Grid.HEIGHT - 1), false);
						else _addToGrid(g, util.Pos.xy(pos.x+1, pos.y-1), false);

						if (syncToView) { // sync views
							if (oldX < Grid.WIDTH-1 && oldY > 0) oldGrid.viewsActorToRightUp(this, oldKey, oldX, oldX+1, oldY, oldY-1, time);
							else {			
								var newX:Int = (oldX < Grid.WIDTH-1) ? oldX+1 : 0;
								var newY:Int = (oldY > 0) ? oldY-1 : Grid.HEIGHT-1;
								var newGrid:Grid = (oldX == Grid.WIDTH-1 && oldY == 0) ? oldGrid.rightTop  :  ((oldX == Grid.WIDTH-1) ? oldGrid.right : oldGrid.top);
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToRightUpOut(this, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
								newGrid.viewsActorToRightUpIn(this, oldGrid, newKey, oldX, newX, oldY, newY, time);				
							}
						}				
					},
				ret: null
			})
		});
		// ------- rightDown -------
		fields.push({
			name: "goRightDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < Grid.WIDTH && pos.y + $v{bitGrid.height} < Grid.HEIGHT) { // fully keep inside
						$b{f(1,1)};
						if (syncToView) grid.viewsActorToRightDown(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, pos.y-1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= Grid.WIDTH; }
						
						_removeFromGrid(false);
						if (pos.x == Grid.WIDTH - 1 && pos.y == Grid.HEIGHT - 1) _addToGrid(g.rightBottom, util.Pos.xy(0, 0), false);
						else if (pos.x == Grid.WIDTH - 1) _addToGrid(g.right, util.Pos.xy(0, pos.y+1), false);
						else if (pos.y == Grid.HEIGHT - 1) _addToGrid(g.bottom, util.Pos.xy(pos.x+1, 0), false);
						else _addToGrid(g, util.Pos.xy(pos.x+1, pos.y+1), false);

						if (syncToView) { // sync views
							if (oldX < Grid.WIDTH-1 && oldY < Grid.HEIGHT-1) oldGrid.viewsActorToRightDown(this, oldKey, oldX, oldX+1, oldY, oldY+1, time);
							else {			
								var newX:Int = (oldX < Grid.WIDTH-1) ? oldX+1 : 0;
								var newY:Int = (oldY < Grid.HEIGHT-1) ? oldY+1 : 0;
								var newGrid:Grid = (oldX == Grid.WIDTH-1 && oldY == Grid.HEIGHT-1) ? oldGrid.rightBottom  :  ((oldX == Grid.WIDTH-1) ? oldGrid.right : oldGrid.bottom);
								var newKey:Int = (pos.x + $v{originXOffset} < Grid.WIDTH) ? gridKey : gridKeyR;
								oldGrid.viewsActorToRightDownOut(this, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
								newGrid.viewsActorToRightDownIn(this, oldGrid, newKey, oldX, newX, oldY, newY, time);				
							}
						}				
					},
				ret: null
			})
		});

	}
}
#end