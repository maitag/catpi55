package automat;

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

		


	// -------------------------------------------------
	// ---------------- SIMMULATION --------------------
	// -------------------------------------------------
	public static inline var MAX_STEPS = 10;
	public static inline var MAX_ACTIONS = 9;
	public static inline var STEP_SIZE = MAX_ACTIONS + 1;

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

		var actionTimeStep = timeStep + delayStep * STEP_SIZE;
		if (actionTimeStep >= MAX_STEPS * STEP_SIZE) actionTimeStep -= MAX_STEPS * STEP_SIZE;
		
		// get the actions-amount at this time
		var actionsPerStep = timeSlicer.get(actionTimeStep);
		if (actionsPerStep >= MAX_ACTIONS) throw("grid-timeslicer actions OVERFLOW");
		
		timeSlicer.set(actionTimeStep + 1 + actionsPerStep, action);

		// increase the actions-amount for this time
		actionsPerStep++;
		timeSlicer.set(actionTimeStep, actionsPerStep);
	}




}

