package catpi.automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class ShapeMacro {
	
	// builds the unrolled functions of Shape.hx
	static public function build(bitGrid:catpi.util.BitGrid, fields:Array<Field>)
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"gR", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"gB", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"gRB", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"a", opt:false, meta:[], type: macro:catpi.automat.Cell.CellActor}, // TODO: use INT everywhere!
					{name:"aR", opt:false, meta:[], type: macro:catpi.automat.Cell.CellActor},
					{name:"aB", opt:false, meta:[], type: macro:catpi.automat.Cell.CellActor},
					{name:"aRB", opt:false, meta:[], type: macro:catpi.automat.Cell.CellActor}
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
		e.push(macro gridKey = (setKey==-1) ? grid.actors.add(this) : setKey);
		e.push(macro 
			if (pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH) {					
				if ( pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) {
					__addToGrid(null, null, null, gridKey, 0, 0, 0);
				}
				else {
					gridKeyB = (setKeyB==-1) ? grid.bottom.actors.add(this) : setKeyB;
					__addToGrid(null, grid.bottom, null, gridKey, 0, gridKeyB, 0);
				}
			}
			else {
				gridKeyR = (setKeyR==-1) ? grid.right.actors.add(this) : setKeyR;
				if ( pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT ) {
					__addToGrid(grid.right, null, null, gridKey, gridKeyR, 0, 0);
				}
				else {
					gridKeyB = (setKeyB==-1) ? grid.bottom.actors.add(this) : setKeyB;
					gridKeyRB = (setKeyRB==-1) ? grid.rightBottom.actors.add(this) : setKeyRB;
					__addToGrid(grid.right, grid.bottom, grid.rightBottom, gridKey, gridKeyR, gridKeyB, gridKeyRB);
				}
			}
		);
		e.push(macro 
			// add actor to the views
			if (syncToView) {
				if (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) {
					grid.viewsActorAdd(this, gridKey, pos.x + $v{originXOffset});
				}
				else {
					grid.right.viewsActorAdd(this, gridKeyR, (pos.x + $v{originXOffset}) % catpi.automat.Grid.WIDTH);
				}
			}
		);
		
		fields.push({
			name: "_addToGrid",
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"grid", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:catpi.util.Pos},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true},
					{name:"setKey", opt:false, meta:[], type: macro:Int, value:macro -1},
					{name:"setKeyR", opt:false, meta:[], type: macro:Int, value:macro -1},
					{name:"setKeyB", opt:false, meta:[], type: macro:Int, value:macro -1},
					{name:"setKeyRB", opt:false, meta:[], type: macro:Int, value:macro -1}
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
					{name:"grid", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:catpi.util.Pos},
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"gR", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"gB", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"gRB", opt:false, meta:[], type: macro:catpi.automat.Grid}
				],
				expr: macro $b{e},
				ret: null
			})
		});
		
		// ---------- _removeFromGrid --------------
		e = [];
		// TODO: keepGrid=false argument, to optimize MOVE functions (remove+add again)
		e.push(macro 
			if ( pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH ) {					
				if ( pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) {
					__removeFromGrid(null, null, null);
				}
				else {
					__removeFromGrid(null, grid.bottom, null);
					if (delKeyB) {grid.bottom.actors.del(gridKeyB); gridKeyB = -1;}
				}
			}
			else {
				if ( pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT ) {
					__removeFromGrid(grid.right, null, null);
				}
				else {
					__removeFromGrid(grid.right, grid.bottom, grid.rightBottom);
					if (delKeyB) {grid.bottom.actors.del(gridKeyB); gridKeyB = -1;}
					if (delKeyRB) {grid.rightBottom.actors.del(gridKeyRB); gridKeyRB = -1;}
				}
				if (delKeyR) grid.right.actors.del(gridKeyR); //gridKeyR = -1;
			}
		);
		e.push(macro if (delKey) grid.actors.del(gridKey));
		e.push(macro 
			// trigger actor-remove to the origin corresponding grid and its views
			if (syncToView) {
				if (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) grid.viewsActorRemove(this, gridKey, pos.x + $v{originXOffset});
				else grid.right.viewsActorRemove(this, gridKeyR, (pos.x + $v{originXOffset}) % catpi.automat.Grid.WIDTH);
			}
		);
		e.push(macro if (delKey) gridKey = -1);
		e.push(macro if (delKeyR) gridKeyR = -1);
		e.push(macro grid = null);
		
		fields.push({
			name: "_removeFromGrid",
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APrivate, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true},
					{name:"delKey", opt:false, meta:[], type: macro:Bool, value:macro true},
					{name:"delKeyR", opt:false, meta:[], type: macro:Bool, value:macro true},
					{name:"delKeyB", opt:false, meta:[], type: macro:Bool, value:macro true},
					{name:"delKeyRB", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"grid", opt:false, meta:[], type: macro:catpi.automat.Grid},
					{name:"pos", opt:false, meta:[], type: macro:catpi.util.Pos}
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
				args: [{name:"cell", opt:false, meta:[], type: macro:catpi.automat.Cell}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro $b{f(-1, 0)},
				// more optimized:
				/*expr: macro 
					if (pos.x == 0) {
						if (pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT) $b{f(-1,0,true,false,false,false)}; // left
						else $b{f(-1,0,true,false,false,true)}; // left, bottom
					}
					else if (pos.x + $v{bitGrid.width} > catpi.automat.Grid.WIDTH) {
						if (pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT) $b{f(-1,0,false,true,false,false)}; // right
						else $b{f(-1,0,false,true,false,true)};  // right, bottom
					}
					else if (pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT) $b{f(-1,0,false,false,false,false)}; // fully inside
					else $b{f(-1,0,false,false,false,true)} // bottom
				,*/
				ret: macro:Bool
			})
		});

		fields.push({
			name: "freeRight",
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
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
							e.push( macro grid.setCellActorAt(catpi.util.Pos.xy(pos.x+$v{x+xOff}, pos.y+$v{y+yOff}), gridKey, true) );
						}
						else e.push( macro grid.setCellActorAt(catpi.util.Pos.xy(pos.x+$v{x+xOff}, pos.y+$v{y+yOff}), gridKey, false) );
					}
					if ((xOff == -1 && x == bitGrid.width-1) || (xOff == 1 && x == 0) || (yOff == -1 && y == bitGrid.height-1) || (yOff == 1 && y == 0)) {
						if (!originWasDel && y == 0 && x == originXOffset) originWasDel = true;
						e.push( macro grid.delCellActorAt(catpi.util.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
					}
					else if ( !bitGrid.get(x-xOff,y-yOff) ) {
						if (!originWasDel && y == 0 && x == originXOffset) originWasDel = true;
						e.push( macro grid.delCellActorAt(catpi.util.Pos.xy(pos.x+$v{x}, pos.y+$v{y})) );
					}
				}
				else if ( ( (x-xOff)>=0 && (x-xOff)<bitGrid.width && (y-yOff)>=0 && (y-yOff)<bitGrid.height ) && bitGrid.get(x-xOff,y-yOff) ) {
					if (!originWasSet && y == 0 && x == originXOffset) { 
						originWasSet = true;
						e.push( macro grid.setCellActorAt(catpi.util.Pos.xy(pos.x+$v{x}, pos.y+$v{y}), gridKey, true) );
					}
					else e.push( macro grid.setCellActorAt(catpi.util.Pos.xy(pos.x+$v{x}, pos.y+$v{y}), gridKey, false) );
				}
			}
			// remove old origin
			if (!originWasDel) e.push( macro grid.delActorOriginAt(catpi.util.Pos.xy(pos.x+$v{originXOffset}, pos.y)) );
			// change position
			e.push( macro pos = catpi.util.Pos.xy(pos.x + $v{xOff}, pos.y + $v{yOff}) );
			// set new origin
			if (!originWasSet) e.push( macro grid.setActorOriginAt(catpi.util.Pos.xy(pos.x+$v{originXOffset}, pos.y)) );
			return e;
		}

		// TODO: refactor constant arguments for view-sync out!
		
		// ------- left -------
		fields.push({
			name: "goLeft",
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH && pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(-1,0)};
						if (syncToView) grid.viewsActorToLeft(this, gridKey, pos.x + $v{originXOffset}+1, pos.x + $v{originXOffset}, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == 0) {
							_removeFromGrid(false, $v{(bitGrid.width == 1)}, false, $v{(bitGrid.width == 1)}, false);
							_addToGrid(g.left, catpi.util.Pos.xy(catpi.automat.Grid.WIDTH-1,pos.y), false, -1, gridKey, -1, gridKeyB);
						}
						else {
							_removeFromGrid(false, false, (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1), false, (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1));
							_addToGrid(g, catpi.util.Pos.xy(pos.x-1, pos.y), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX > 0) oldGrid.viewsActorToLeft(this, oldKey, oldX, oldX-1, time);
							else {
								var newX:Int = catpi.automat.Grid.WIDTH-1;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < catpi.automat.Grid.WIDTH && pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(1,0)};
						if (syncToView) grid.viewsActorToRight(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == catpi.automat.Grid.WIDTH-1) {
							_removeFromGrid(false, true, false, true, false);
							_addToGrid(g.right, catpi.util.Pos.xy(0, pos.y), false, gridKeyR, -1, gridKeyRB, -1);
							gridKeyR = -1; gridKeyRB = -1;
						}
						else {
							_removeFromGrid(false, false, false, false, false);
							_addToGrid(g, catpi.util.Pos.xy(pos.x+1, pos.y), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX < catpi.automat.Grid.WIDTH-1) oldGrid.viewsActorToRight(this, oldKey, oldX, oldX+1, time);
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.y > 0 && pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT && pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH) { // fully keep inside
						$b{f(0,-1)};
						if (syncToView) grid.viewsActorToUp(this, gridKey, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.y == 0) {
							_removeFromGrid(false, $v{(bitGrid.height == 1)}, $v{(bitGrid.height == 1)}, false, false);
							_addToGrid(g.top, catpi.util.Pos.xy(pos.x, catpi.automat.Grid.HEIGHT-1), false, -1, -1, gridKey, gridKeyR);
						}
						else {
							_removeFromGrid(false, false, false, (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1), (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1));
							_addToGrid(g, catpi.util.Pos.xy(pos.x, pos.y-1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldY > 0) oldGrid.viewsActorToUp(this, oldKey, oldX, oldY, oldY-1, time);
							else {
								var newY:Int = catpi.automat.Grid.HEIGHT-1;
								var newGrid = oldGrid.top;
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT && pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH) { // fully keep inside
						$b{f(0,1)};
						if (syncToView) grid.viewsActorToDown(this, gridKey, pos.x + $v{originXOffset}, pos.y - 1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.y == catpi.automat.Grid.HEIGHT-1) {
							_removeFromGrid(false, true, true, false, false);
							_addToGrid(g.bottom, catpi.util.Pos.xy(pos.x, 0), false, gridKeyB, gridKeyRB, -1, -1);
							gridKeyB = -1; gridKeyRB = -1;
						}
						else {
							_removeFromGrid(false, false, false, false, false);
							_addToGrid(g, catpi.util.Pos.xy(pos.x, pos.y+1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldY < catpi.automat.Grid.HEIGHT-1) oldGrid.viewsActorToDown(this, oldKey, oldX, oldY, oldY+1, time);
							else {
								var newY:Int = 0;
								var newGrid = oldGrid.bottom;
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(-1,-1)};
						if (syncToView) grid.viewsActorToLeftUp(this, gridKey, pos.x + $v{originXOffset}+1, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == 0 && pos.y == 0) {
							_removeFromGrid(false, $v{(bitGrid.width == 1)} || $v{(bitGrid.height == 1)}, false, false, false);
							_addToGrid(g.leftTop, catpi.util.Pos.xy(catpi.automat.Grid.WIDTH - 1, catpi.automat.Grid.HEIGHT - 1), false, -1, -1, -1, gridKey);
						}
						else if (pos.x == 0) {
							_removeFromGrid(false, $v{(bitGrid.width == 1)}, false,  $v{(bitGrid.width == 1)} || (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1), false);
							_addToGrid(g.left, catpi.util.Pos.xy(catpi.automat.Grid.WIDTH - 1, pos.y-1), false, -1, gridKey, -1, gridKeyB);
						}
						else if (pos.y == 0) {
							_removeFromGrid(false, $v{(bitGrid.height == 1)}, $v{(bitGrid.height == 1)} || (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1), false, false);
							_addToGrid(g.top, catpi.util.Pos.xy(pos.x-1, catpi.automat.Grid.HEIGHT - 1), false, -1, -1, gridKey, gridKeyR);
						}
						else {
							_removeFromGrid(false, false, (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1), (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1), (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1) || (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1));
							_addToGrid(g, catpi.util.Pos.xy(pos.x-1, pos.y-1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX > 0 && oldY > 0) oldGrid.viewsActorToLeftUp(this, oldKey, oldX, oldX-1, oldY, oldY-1, time);
							else {			
								var newX:Int = (oldX > 0) ? oldX-1 : catpi.automat.Grid.WIDTH-1;
								var newY:Int = (oldY > 0) ? oldY-1 : catpi.automat.Grid.HEIGHT-1;
								var newGrid = (oldX == 0 && oldY == 0) ? oldGrid.leftTop  :  ((oldX == 0) ? oldGrid.left : oldGrid.top);
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x > 0 && pos.x + $v{bitGrid.width} <= catpi.automat.Grid.WIDTH && pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(-1,1)};
						if (syncToView) grid.viewsActorToLeftDown(this, gridKey, pos.x + $v{originXOffset}+1,  pos.x + $v{originXOffset}, pos.y-1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == 0 && pos.y == catpi.automat.Grid.HEIGHT - 1) {
							_removeFromGrid(false, true, false, false, false);
							_addToGrid(g.leftBottom, catpi.util.Pos.xy(catpi.automat.Grid.WIDTH - 1, 0), false, -1, gridKeyB, -1, -1);
							gridKeyB = -1;
						}
						else if (pos.x == 0) {
							_removeFromGrid(false, $v{(bitGrid.width == 1)}, false, $v{(bitGrid.width == 1)}, false);
							_addToGrid(g.left, catpi.util.Pos.xy(catpi.automat.Grid.WIDTH - 1, pos.y+1), false, -1, gridKey, -1, gridKeyB);
						}
						else if (pos.y == catpi.automat.Grid.HEIGHT - 1) {
							_removeFromGrid(false, true, true, false, false);
							_addToGrid(g.bottom, catpi.util.Pos.xy(pos.x-1, 0), false, gridKeyB, gridKeyRB, -1, -1);
							gridKeyB = -1; gridKeyRB = -1;
						}
						else {
							_removeFromGrid(false, false, (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1), false, (pos.x + $v{bitGrid.width} == catpi.automat.Grid.WIDTH+1));
							_addToGrid(g, catpi.util.Pos.xy(pos.x-1, pos.y+1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX > 0 && oldY < catpi.automat.Grid.HEIGHT-1) oldGrid.viewsActorToLeftDown(this, oldKey, oldX, oldX-1, oldY, oldY+1, time);
							else {			
								var newX:Int = (oldX > 0) ? oldX-1 : catpi.automat.Grid.WIDTH-1;
								var newY:Int = (oldY < catpi.automat.Grid.HEIGHT-1) ? oldY+1 : 0;
								var newGrid = (oldX == 0 && oldY == catpi.automat.Grid.HEIGHT-1) ? oldGrid.leftBottom  :  ((oldX == 0) ? oldGrid.left : oldGrid.bottom);
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < catpi.automat.Grid.WIDTH && pos.y > 0 && pos.y + $v{bitGrid.height} <= catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(1,-1)};
						if (syncToView) grid.viewsActorToRightUp(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, pos.y+1, pos.y, time);
					}
					else {
						var g = grid;
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == catpi.automat.Grid.WIDTH - 1 && pos.y == 0) {
							_removeFromGrid(false, true, $v{(bitGrid.height == 1)}, false, false);
							_addToGrid(g.rightTop, catpi.util.Pos.xy(0, catpi.automat.Grid.HEIGHT - 1), false, -1, -1, gridKeyR, -1);
							gridKeyR = -1;
						}
						else if (pos.x == catpi.automat.Grid.WIDTH - 1) {
							_removeFromGrid(false, true, false, true, (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1));
							_addToGrid(g.right, catpi.util.Pos.xy(0, pos.y-1), false, gridKeyR, -1, gridKeyRB, -1);
							gridKeyR = -1; gridKeyRB = -1;
						}
						else if (pos.y == 0) {
							_removeFromGrid(false, $v{(bitGrid.height == 1)}, $v{(bitGrid.height == 1)}, false, false);
							_addToGrid(g.top, catpi.util.Pos.xy(pos.x+1, catpi.automat.Grid.HEIGHT - 1), false, -1, -1, gridKey, gridKeyR);
						}
						else {
							_removeFromGrid(false, false, false, (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1), (pos.y + $v{bitGrid.height} == catpi.automat.Grid.HEIGHT+1));
							_addToGrid(g, catpi.util.Pos.xy(pos.x+1, pos.y-1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX < catpi.automat.Grid.WIDTH-1 && oldY > 0) oldGrid.viewsActorToRightUp(this, oldKey, oldX, oldX+1, oldY, oldY-1, time);
							else {			
								var newX:Int = (oldX < catpi.automat.Grid.WIDTH-1) ? oldX+1 : 0;
								var newY:Int = (oldY > 0) ? oldY-1 : catpi.automat.Grid.HEIGHT-1;
								var newGrid = (oldX == catpi.automat.Grid.WIDTH-1 && oldY == 0) ? oldGrid.rightTop  :  ((oldX == catpi.automat.Grid.WIDTH-1) ? oldGrid.right : oldGrid.top);
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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
			meta: [{name:":access", params:[macro catpi.automat], pos:Context.currentPos()}],
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [
					{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
					{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
				],
				expr: macro 
					if (pos.x + $v{bitGrid.width} < catpi.automat.Grid.WIDTH && pos.y + $v{bitGrid.height} < catpi.automat.Grid.HEIGHT) { // fully keep inside
						$b{f(1,1)};
						if (syncToView) grid.viewsActorToRightDown(this, gridKey, pos.x + $v{originXOffset}-1, pos.x + $v{originXOffset}, pos.y-1, pos.y, time);
					}
					else {
						var g = grid;
						// store old values to sync the views afterwards
						var oldY:Int = pos.y;
						var oldGrid = g; var oldKey:Int = gridKey; var oldX:Int = pos.x + $v{originXOffset};
						if (syncToView && oldX >= catpi.automat.Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = gridKeyR; oldX -= catpi.automat.Grid.WIDTH; }
						
						if (pos.x == catpi.automat.Grid.WIDTH - 1 && pos.y == catpi.automat.Grid.HEIGHT - 1) {
							_removeFromGrid(false, true, true, true, false);
							_addToGrid(g.rightBottom, catpi.util.Pos.xy(0, 0), false, gridKeyRB, -1, -1, -1);
							gridKeyRB = -1;
						}
						else if (pos.x == catpi.automat.Grid.WIDTH - 1) {
							_removeFromGrid(false, true, false, true, false);
							_addToGrid(g.right, catpi.util.Pos.xy(0, pos.y+1), false, gridKeyR, -1, gridKeyRB, -1);
							gridKeyR = -1; gridKeyRB = -1;
						}
						else if (pos.y == catpi.automat.Grid.HEIGHT - 1) {
							_removeFromGrid(false, true, true, false, false);
							_addToGrid(g.bottom, catpi.util.Pos.xy(pos.x+1, 0), false, gridKeyB, gridKeyRB, -1, -1);
							gridKeyB = -1; gridKeyRB = -1;
						}
						else {
							_removeFromGrid(false, false, false, false, false);
							_addToGrid(g, catpi.util.Pos.xy(pos.x+1, pos.y+1), false, gridKey, gridKeyR, gridKeyB, gridKeyRB);
						}
						
						if (syncToView) { // sync views
							if (oldX < catpi.automat.Grid.WIDTH-1 && oldY < catpi.automat.Grid.HEIGHT-1) oldGrid.viewsActorToRightDown(this, oldKey, oldX, oldX+1, oldY, oldY+1, time);
							else {
								var newX:Int = (oldX < catpi.automat.Grid.WIDTH-1) ? oldX+1 : 0;
								var newY:Int = (oldY < catpi.automat.Grid.HEIGHT-1) ? oldY+1 : 0;
								var newGrid = (oldX == catpi.automat.Grid.WIDTH-1 && oldY == catpi.automat.Grid.HEIGHT-1) ? oldGrid.rightBottom  :  ((oldX == catpi.automat.Grid.WIDTH-1) ? oldGrid.right : oldGrid.bottom);
								var newKey:Int = (pos.x + $v{originXOffset} < catpi.automat.Grid.WIDTH) ? gridKey : gridKeyR;
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