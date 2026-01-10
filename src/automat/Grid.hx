package automat;

import automat.Cell.CellActor;
import automat.actor.Actor;
import haxe.ds.Vector;

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
	public var top:Grid = null;
	public var bottom:Grid = null;
	public var left:Grid = null;
	public var right:Grid = null;

	// -------------------------------------------------
	// ------------------- VIEWER ----------------------
	// -------------------------------------------------
	public var viewers = new Array<Viewer>();

	// -------------------------------------------------
	// ------------------- ACTOR -----------------------
	// -------------------------------------------------
	public var actors = new Viktor<Actor>(CellActor.MAX_ACTORS);

	public inline function getActor(pos:Pos):CellActor return get(pos).actor;
	public inline function setActor(pos:Pos, actor:CellActor) {
		var cell = get(pos);
		cell.actor = actor;
		set(pos, cell);
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

