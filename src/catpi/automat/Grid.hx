package catpi.automat;

import haxe.ds.Vector;

import catpi.automat.Cell.CellActor;
import catpi.automat.actor.IActor;
import catpi.automat.sim.Sim;
import catpi.automat.sim.SimEvent;
import catpi.util.Pos;
import catpi.util.Pos.xy as P;

@:allow(catpi.automat.actor)
class Grid {
	// -------------------------------------------------
	// -------------------- DATA -----------------------
	// -------------------------------------------------
	public static inline final WIDTH:Int = 64;
	public static inline final HEIGHT:Int = 64;

	#if CellGrid_Bytes
	var data = haxe.io.Bytes.alloc(WIDTH*HEIGHT*4);
	inline function _get(p:Int):Int return data.getInt32(p<<2);
	inline function _set(p:Int, v:Int) data.setInt32(p<<2, v);
	#else
	var data = new Vector<Int>(WIDTH*HEIGHT);
	inline function _get(p:Int):Int return data.get(p);
	inline function _set(p:Int, v:Int) data.set(p, v);
	#end

	public function get(pos:Pos):Cell return _get(pos);
	public function set(pos:Pos, cell:Cell) _set(pos, cell);

	// ---- constructor ----
	public function new() {
		// init timeslicer vector (e.g. on neko it is initialized by "null")
		for (i in 0...MAX_STEPS) timeSlicer.set(i*STEP_SIZE, 0);
	}

	// -------------------------------------------------
	// ---------------- linked GRIDs -------------------
	// -------------------------------------------------
	public var left:Grid = null;
	public var right:Grid = null;
	public var top:Grid = null;
	public var bottom:Grid = null;

	public var leftTop(get, never):Grid;
	public var leftBottom(get, never):Grid;
	public var rightTop(get, never):Grid;
	public var rightBottom(get, never):Grid;
	inline function get_leftTop():Grid return ( (left != null && left.top != null) ? left.top : (top != null && top.left != null) ? top.left : null );
	inline function get_leftBottom():Grid return ( (left != null && left.bottom != null) ? left.bottom : (bottom != null && bottom.left != null) ? bottom.left : null );
	inline function get_rightTop():Grid return ( (right != null && right.top != null) ? right.top : (top != null && top.right != null) ? top.right : null );
	inline function get_rightBottom():Grid return ( (right != null && right.bottom != null) ? right.bottom : (bottom != null && bottom.right != null) ? bottom.right : null );

	// -------------------------------------------------
	// ------------------- VIEWS -----------------------
	// -------------------------------------------------
	public var views = new Array<GridView>(); // optimize later by holeless vector!

	// -------------------------------------------------
	// ------------------- ACTOR -----------------------
	// -------------------------------------------------
	public var actors = new Viktor<IActor>(CellActor.MAX_ACTORS);

	public inline function getActorAt(pos:Pos):IActor {
		var actorID:Int = get(pos).actor;
		return (actorID == CellActor.EMPTY) ? null : actors.get( actorID );
	}

	public inline function getActorAtOffset(x:Int, y:Int):IActor {
		var grid = this;
		if (x < 0) { x = WIDTH - x; grid = grid.left; }
		else if (x >= WIDTH) { x = 0; grid = grid.right; }

		if (grid == null) return null;// TODO

		if (y < 0) { y = HEIGHT - y; grid = grid.top; }
		else if (y >= HEIGHT) { y = 0; grid = grid.bottom; }
		
		if (grid == null) return null;

		var actorID:Int = grid.get(P(x,y)).actor;
		return (actorID == CellActor.EMPTY) ? null : grid.actors.get( actorID );
	}

	
	// TODO: optimize arguments by change CellActor into Int!
	
	inline function setCellActorAt(pos:Pos, cellActor:CellActor, isOrigin:Bool) {
		var cell = get(pos);
		// cell.actor = cellActor;
		cell.setActor(cellActor, isOrigin);
		set(pos, cell);
	}

	// only used by macro-unroll-mode (DCE eliminated if-branches)
	inline function setCellActorAtOffset(x:Int, y:Int, gR:Grid, gB:Grid, gRB:Grid,
		a:CellActor, aR:CellActor, aB:CellActor, aRB:CellActor, isOrigin:Bool)
	{	
		if (gRB != null) {
			if (x < WIDTH) {
				if ( y < HEIGHT) setCellActorAt(P(x,y), a, isOrigin);
				else gB.setCellActorAt(P(x, y - HEIGHT), aB, isOrigin);
			}
			else {
				if ( y < HEIGHT) gR.setCellActorAt(P(x - WIDTH, y), aR, isOrigin);
				else gRB.setCellActorAt(P(x - WIDTH, y - HEIGHT), aRB, isOrigin);
			}
		}
		else if (gR != null) {
			if (x < WIDTH) setCellActorAt(P(x,y), a, isOrigin);
			else gR.setCellActorAt(P(x - WIDTH, y), aR, isOrigin);
		}
		else if (gB != null) {
			if ( y < HEIGHT) setCellActorAt(P(x,y), a, isOrigin);
			else gB.setCellActorAt(P(x, y - HEIGHT), aB, isOrigin);
		}
		else setCellActorAt(P(x,y), a, isOrigin);
	}

	inline function setActorOriginAt(pos:Pos) {
		var cell = get(pos);
		cell.setOrigin();
		set(pos, cell);
	}
	inline function delActorOriginAt(pos:Pos) {
		var cell = get(pos);
		cell.delOrigin();
		set(pos, cell);
	}
	
	// removes also the "origin" bit
	inline function delCellActorAt(pos:Pos) {
		var cell = get(pos);
		// cell.actor = CellActor.EMPTY;
		cell.removeActor();
		set(pos, cell);
	}
/*
	inline function getAndDelCellActorAt(pos:Pos):CellActor {
		var cell = get(pos);
		var cellActor:CellActor = cell.actor;
		cell.actor = CellActor.EMPTY;
		set(pos, cell);
		return cellActor;
	}
*/	

	// only used by macro-unroll-mode (DCE eliminated if-branches)
	inline function delCellActorAtOffset(x:Int, y:Int, gR:Grid, gB:Grid, gRB:Grid) {
		if (gRB != null) {
			if (x < WIDTH) {
				if (y < HEIGHT) delCellActorAt(P(x,y));
				else gB.delCellActorAt(P(x, y - HEIGHT));
			}
			else {
				if (y < HEIGHT) gR.delCellActorAt(P(x - WIDTH, y));
				else gRB.delCellActorAt(P(x - WIDTH, y - HEIGHT));
			}
		}
		else if (gR != null) {
			if (x < WIDTH) delCellActorAt(P(x,y));
			else gR.delCellActorAt(P(x - WIDTH, y));
		}
		else if (gB != null) {
			if ( y < HEIGHT) delCellActorAt(P(x,y));
			else gB.delCellActorAt(P(x, y - HEIGHT));
		}
		else delCellActorAt(P(x,y));	
	}
	
	// the optional check-parameters here is used in macro-unroll-mode to optimize the "isFree" functions!
	inline function getCellAtOffset(pos:Pos, x:Int, y:Int, checkLeft=true, checkRight=true, checkTop=true, checkBottom=true ):Cell {
		x += pos.x;
		y += pos.y;
		if (checkLeft && x < 0) return _atOffsetLeftY(x + WIDTH, y, checkTop, checkBottom);
		else if (checkRight && x >= WIDTH) return _atOffsetRightY(x - WIDTH, y, checkTop, checkBottom);
		else if (checkTop && y < 0) {
			if (top != null) return top.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (checkBottom && y >= HEIGHT) {
			if (bottom != null) return bottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else return get( P(x, y) );
	}

	inline function _atOffsetLeftY(x:Int, y:Int, checkTop, checkBottom):Cell {
		if (checkTop && y < 0) {
			if (leftTop != null) return leftTop.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (checkBottom && y >= HEIGHT) {
			if (leftBottom != null) return leftBottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else if (left != null) return left.get( P(x, y) );		
		else return 0;
	}

	inline function _atOffsetRightY(x:Int, y:Int, checkTop, checkBottom):Cell {
		if (checkTop && y < 0) {
			if (rightTop != null) return rightTop.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (checkBottom && y >= HEIGHT) {
			if (rightBottom != null) return rightBottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else if (right != null) return right.get( P(x, y) );
		else return 0;
	}
	
	// --------------- SYNC ACTOR TO VIEWS -------------------
	inline function viewsActorAdd(actor:IActor, actorKey:Int, actor_pos_x:Int) {
		for (view in views) view.addActor(actor, actorKey, actor_pos_x);
	}
	
	inline function viewsActorRemove(actor:IActor, actorKey:Int, actor_pos_x:Int) {
		for (view in views) view.removeActor(actor, actorKey, actor_pos_x);
	}

	// ------- left -------
	inline function viewsActorToLeft(a:IActor, key:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToLeft(a, key, oldX, newX, time);
	}
	inline function viewsActorToLeftOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToLeftOut(a, newGrid, oldKey, newKey, oldX, newX, time);
	}
	inline function viewsActorToLeftIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToLeftIn(a, oldGrid, key, oldX, newX, time);
	}
	// ------- right -------
	inline function viewsActorToRight(a:IActor, key:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToRight(a, key, oldX, newX, time);
	}
	inline function viewsActorToRightOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToRightOut(a, newGrid, oldKey, newKey, oldX, newX, time);
	}
	inline function viewsActorToRightIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, time:Int) {
		for (view in views) view.actorToRightIn(a, oldGrid, key, oldX, newX, time);
	}
	// ------- up -------
	inline function viewsActorToUp(a:IActor, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToUp(a, key, x, oldY, newY, time);
	}
	inline function viewsActorToUpOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToUpOut(a, newGrid, oldKey, newKey, x, oldY, newY, time);
	}
	inline function viewsActorToUpIn(a:IActor, oldGrid:Grid, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToUpIn(a, oldGrid, key, x, oldY, newY, time);
	}
	// ------- down -------
	inline function viewsActorToDown(a:IActor, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToDown(a, key, x, oldY, newY, time);
	}
	inline function viewsActorToDownOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToDownOut(a, newGrid, oldKey, newKey, x, oldY, newY, time);
	}
	inline function viewsActorToDownIn(a:IActor, oldGrid:Grid, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToDownIn(a, oldGrid, key, x, oldY, newY, time);
	}

	// ------- leftUp -------
	inline function viewsActorToLeftUp(a:IActor, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftUp(a, key, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToLeftUpOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftUpOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToLeftUpIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftUpIn(a, oldGrid, key, oldX, newX, oldY, newY, time);
	}
	// ------- leftDown -------
	inline function viewsActorToLeftDown(a:IActor, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftDown(a, key, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToLeftDownOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftDownOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToLeftDownIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToLeftDownIn(a, oldGrid, key, oldX, newX, oldY, newY, time);
	}
	// ------- rightUp -------
	inline function viewsActorToRightUp(a:IActor, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightUp(a, key, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToRightUpOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightUpOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToRightUpIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightUpIn(a, oldGrid, key, oldX, newX, oldY, newY, time);
	}
	// ------- rightDown -------
	inline function viewsActorToRightDown(a:IActor, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightDown(a, key, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToRightDownOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightDownOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
	}
	inline function viewsActorToRightDownIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		for (view in views) view.actorToRightDownIn(a, oldGrid, key, oldX, newX, oldY, newY, time);
	}

	// -------------------------------------------------
	// ---------------- SIMMULATION --------------------
	// -------------------------------------------------
	public static inline var MAX_STEPS:Int = 10;
	public static inline var MAX_EVENTS_PER_STEP:Int = 4096;//9;
	public static inline var STEP_SIZE:Int = MAX_EVENTS_PER_STEP + 1;

	public var timeSlicer = new Vector<Int>(MAX_STEPS * STEP_SIZE);

	public var timeStep:Int = 0;

	inline function simEventsLength() return timeSlicer.get(timeStep);
	inline function getSimEvent(i:Int) return timeSlicer.get(timeStep + 1 + i);

	// todo: maybe needs a "lock" if setSimEvent called from outwards!
	public function step()
	{	// get all events to the actual time
		for (i in 0...simEventsLength()) {
			Sim.step(this, getSimEvent(i));
		}
		
		// ready for the next timestep
		timeSlicer.set(timeStep, 0); // resets all events at timeStep;
		timeStep += STEP_SIZE;
		if (timeStep >= MAX_STEPS * STEP_SIZE) timeStep = 0;
	}

	public inline function setSimEvent(event:SimEvent, delayStep:Int)
	{
		if (delayStep >= MAX_STEPS) throw("delayStep into setSimEvent is greater then timeslicers MAX_STEPS");

		var eventTimeStep:Int = timeStep + delayStep * STEP_SIZE;
		if (eventTimeStep >= MAX_STEPS * STEP_SIZE) eventTimeStep -= MAX_STEPS * STEP_SIZE;
		
		// get the events-amount at this time
		var eventsPerStep:Int = timeSlicer.get(eventTimeStep);//trace("eventsPerStep",eventsPerStep);
		if (eventsPerStep >= MAX_EVENTS_PER_STEP) throw("grid-timeslicer events OVERFLOW");

		// trace(eventTimeStep , eventsPerStep);

		timeSlicer.set(eventTimeStep + 1 + eventsPerStep, event);

		// increase the events-amount for this time
		eventsPerStep++;
		timeSlicer.set(eventTimeStep, eventsPerStep);
	}


	// ------------------------------------------------------------
	// ---------- traverse all knotted grids into step() ----------
	// ------------------------------------------------------------
	
	var traversed:Bool = false;

	public function stepAll() {		
		_stepAllDirection(!traversed, true, true, true, true);
	}

	// do simmulation step() of all knotted grids
	inline function _stepAllDirection(isTraversed:Bool, doLeft:Bool, doRight:Bool, doTop:Bool, doBottom:Bool) {
		if (traversed == isTraversed) return;
		step();
		traversed = isTraversed;
		if (doLeft && left != null) left._stepAllDirection(isTraversed, true, false, true, true);
		if (doRight && right != null) right._stepAllDirection(isTraversed, false, true, true, true);
		if (doTop && top != null) top._stepAllDirection(isTraversed, true, true, true, false);
		if (doBottom && bottom != null) bottom._stepAllDirection(isTraversed, true, true, false, true);
	}

	// returns a list of all knotted grids
	public function getAllAsList():Array<Grid> {	
		var list = new Array<Grid>();	
		_pushAllDirection(list, !traversed, true, true, true, true);
		return list;
	}

	inline function _pushAllDirection(list:Array<Grid>, isTraversed:Bool, doLeft:Bool, doRight:Bool, doTop:Bool, doBottom:Bool) {
		if (traversed == isTraversed) return;
		list.push(this);
		traversed = isTraversed;
		if (doLeft && left != null) left._pushAllDirection(list, isTraversed, true, false, true, true);
		if (doRight && right != null) right._pushAllDirection(list, isTraversed, false, true, true, true);
		if (doTop && top != null) top._pushAllDirection(list, isTraversed, true, true, true, false);
		if (doBottom && bottom != null) bottom._pushAllDirection(list, isTraversed, true, true, false, true);
	}
	
}

