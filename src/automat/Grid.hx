package automat;

import haxe.ds.Vector;

import automat.Cell.CellActor;
import automat.actor.IActor;
import automat.sim.Sim;
import automat.sim.SimEvent;
import util.Pos;
import util.Pos.xy as P;

@:allow(automat.actor)
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

	inline function setCellActorAt(pos:Pos, cellActor:CellActor, isOrigin:Bool) {
		var cell = get(pos);
		// cell.actor = cellActor;
		cell.setActor(cellActor, isOrigin);
		set(pos, cell);
	}

	// only used by macro-unroll-mode
	inline function setCellActorAtOffset(x:Int, y:Int, gR:Grid, gB:Grid, gRB:Grid,
		a:CellActor, aR:CellActor, aB:CellActor, aRB:CellActor, isOrigin:Bool)
	{
		if (gR==null || gRB==null || x < WIDTH) {
			if (gB==null || y < HEIGHT) setCellActorAt(P(x,y), a, isOrigin);
			else gB.setCellActorAt(P(x, y - HEIGHT), aB, isOrigin);
		}
		else {
			if (gRB==null || y < HEIGHT) gR.setCellActorAt(P(x - WIDTH, y), aR, isOrigin);
			else gRB.setCellActorAt(P(x - WIDTH, y - HEIGHT), aRB, isOrigin);
		}
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

	// only used by macro-unroll-mode
	inline function delCellActorAtOffset(x:Int, y:Int, gR:Grid, gB:Grid, gRB:Grid) {
		if (gR==null || gRB==null || x < WIDTH) {
			if (gB==null || y < HEIGHT) delCellActorAt(P(x,y));
			else gB.delCellActorAt(P(x, y - HEIGHT));
		}
		else {
			if (gRB==null || y < HEIGHT) gR.delCellActorAt(P(x - WIDTH, y));
			else gRB.delCellActorAt(P(x - WIDTH, y - HEIGHT));
		}
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
	inline function viewsActorAdd(actor:IActor, cellActor:CellActor) {
		for (view in views) view.addActor(actor, cellActor);
	}
	
	inline function viewsActorRemove(actor:IActor, cellActor:CellActor) {
		for (view in views) view.removeActor(cellActor);
	}

	// TODO: for each direction
	inline function viewsActorToGridLeft(oldoldActorKey:CellActor, newActorKey:CellActor) {
		for (view in views) view.actorSwitchGridLeft( oldoldActorKey, newActorKey);
	}
	inline function viewsActorGoLeft(actorKey:CellActor, time:Int = 0) {
		for (view in views) view.actorGoLeft( actorKey, time);
	}


	// -------------------------------------------------
	// ---------------- SIMMULATION --------------------
	// -------------------------------------------------
	public static inline var MAX_STEPS:Int = 10;
	public static inline var MAX_EVENTS_PER_STEP:Int = 9;
	public static inline var STEP_SIZE:Int = MAX_EVENTS_PER_STEP + 1;

	public var timeSlicer = new Vector<Int>(MAX_STEPS * STEP_SIZE);

	public var timeStep:Int = 0;

	inline function simEventsLength() return timeSlicer.get(timeStep);
	inline function getSimEvent(i:Int) return timeSlicer.get(timeStep + 1 + i);

	// todo: maybe needs a "lock" if setSimEvent called from outwards!
	public function step()
	{		
		// get all events to the actual time
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
		var eventsPerStep:Int = timeSlicer.get(eventTimeStep);
		if (eventsPerStep >= MAX_EVENTS_PER_STEP) throw("grid-timeslicer events OVERFLOW");

		trace(eventTimeStep , eventsPerStep); // TODO: in neko the eventsPerStep is null!

		timeSlicer.set(eventTimeStep + 1 + eventsPerStep, event);

		// increase the events-amount for this time
		eventsPerStep++;
		timeSlicer.set(eventTimeStep, eventsPerStep);
	}




}

