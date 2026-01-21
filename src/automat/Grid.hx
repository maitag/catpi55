package automat;

import haxe.ds.Vector;

import automat.Cell.CellActor;
import automat.actor.IActor;
import automat.actor.Actor;
import automat.Pos.xy as P;

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
	// ------------------- VIEWER ----------------------
	// -------------------------------------------------
	public var viewers = new Array<Viewer>();

	// -------------------------------------------------
	// ------------------- ACTOR -----------------------
	// -------------------------------------------------
	public var actors = new Viktor<IActor>(CellActor.MAX_ACTORS);

	public inline function getActorAt(pos:Pos):IActor {
		var actorID:Int = get(pos).actor;
		return (actorID == CellActor.EMPTY) ? null : actors.get( actorID );
	}

	inline function setCellActorAt(pos:Pos, cellActor:CellActor) {
		var cell = get(pos);
		cell.actor = cellActor;
		set(pos, cell);
	}
	
	// TODO: only used by macro-unroll-mode at now -> better put it inside there then!
	inline function setCellActorAtOffset(x:Int, y:Int,
		gR:Grid, gB:Grid, gRB:Grid,
		a:CellActor, aR:CellActor, aB:CellActor, aRB:CellActor,
		)
	{
		if (x < WIDTH) {
			if (y < HEIGHT) setCellActorAt(P(x,y), a);
			else gB.setCellActorAt(P(x, y - HEIGHT), aB);
		}
		else {
			if (y < HEIGHT) gR.setCellActorAt(P(x - WIDTH, y), aR);
			else gRB.setCellActorAt(P(x - WIDTH, y - HEIGHT), aRB);
		}
	}
	
	inline function delCellActorAt(pos:Pos) {
		var cell = get(pos);
		cell.actor = CellActor.EMPTY;
		set(pos, cell);
	}
	/*
	inline function delCellActorAtOffset(x:Int, y:Int, gR:Grid, gB:Grid, gRB:Grid) {
		if (x < WIDTH) {
			if (y < HEIGHT) delCellActorAt(P(x,y));
			else gB.delCellActorAt(P(x, y - HEIGHT));
		}
		else {
			if (y < HEIGHT) gR.delCellActorAt(P(x - WIDTH, y));
			else gRB.delCellActorAt(P(x - WIDTH, y - HEIGHT));
		}
	}
	*/
		
	inline function getCellAtOffset(pos:Pos, x:Int, y:Int):Cell {
		x += pos.x;
		y += pos.y;
		if (x < 0) return _atOffsetLeftY(x + WIDTH, y);
		else if (x >= WIDTH) return _atOffsetRightY(x - WIDTH, y);
		else if (y < 0) {
			if (top != null) return top.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (y >= HEIGHT) {
			if (bottom != null) return bottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else return get( P(x, y) );
	}

	inline function _atOffsetLeftY(x:Int, y:Int):Cell {
		if (y < 0) {
			if (leftTop != null) return leftTop.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (y >= HEIGHT) {
			if (leftBottom != null) return leftBottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else if (left != null) return left.get( P(x, y) );		
		else return 0;
	}

	inline function _atOffsetRightY(x:Int, y:Int):Cell {
		if (y < 0) {
			if (rightTop != null) return rightTop.get( P(x, y + HEIGHT) );
			else return 0;
		}
		else if (y >= HEIGHT) {
			if (rightBottom != null) return rightBottom.get( P(x, y - HEIGHT) );
			else return 0;
		}
		else if (right != null) return right.get( P(x, y) );
		else return 0;
	}
	




	// -------------------------------------------------
	// ---------------- SIMMULATION --------------------
	// -------------------------------------------------
	public static inline var MAX_STEPS:Int = 10;
	public static inline var MAX_ACTIONS:Int = 9;
	public static inline var STEP_SIZE:Int = MAX_ACTIONS + 1;

	public var timeSlicer = new Vector<Int>(MAX_STEPS * STEP_SIZE);

	public var timeStep:Int = 0;

	public inline function getActionLength() return timeSlicer.get(timeStep);
	public inline function getAction(i:Int) return timeSlicer.get(timeStep + 1 + i);

	// todo: maybe needs a "lock" if setAction called from outwards!
	public function step()
	{		
		// get all actions to the actual time
		for (i in 0...getActionLength()) {
			Sim.step(this, getAction(i));
		}
		
		// ready for the next timestep
		timeSlicer.set(timeStep, 0); // resets all actions at timeStep;
		timeStep += STEP_SIZE;
		if (timeStep >= MAX_STEPS * STEP_SIZE) timeStep = 0;
	}

	public inline function setAction(action:Action, delayStep:Int)
	{
		if (delayStep >= MAX_STEPS) throw("delayStep into setAction is greater then timeslicers MAX_STEPS");

		var actionTimeStep:Int = timeStep + delayStep * STEP_SIZE;
		if (actionTimeStep >= MAX_STEPS * STEP_SIZE) actionTimeStep -= MAX_STEPS * STEP_SIZE;
		
		// get the actions-amount at this time
		var actionsPerStep:Int = timeSlicer.get(actionTimeStep);
		if (actionsPerStep >= MAX_ACTIONS) throw("grid-timeslicer actions OVERFLOW");

		trace(actionTimeStep , actionsPerStep); // TODO: in neko the actionsPerStep is null!

		timeSlicer.set(actionTimeStep + 1 + actionsPerStep, action);

		// increase the actions-amount for this time
		actionsPerStep++;
		timeSlicer.set(actionTimeStep, actionsPerStep);
	}




}

