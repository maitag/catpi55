package automat.actor;

import util.Pos;

interface IActor {
	public var type(get, never):ActorType;
	public var name:String;
	public var pos:Pos;
	public var width(get, never):Int;
	public var height(get, never):Int;
	
	public var grid:Grid;
	public var gridKey:Int;
	public var gridKeyR:Int;
	public var gridKeyB:Int;
	public var gridKeyRB:Int;

	public function addToGrid(grid:Grid, pos:Int, syncToView:Bool=true):Void;
	public function removeFromGrid(syncToView:Bool=true):Void;

	public function isFitIntoGrid(grid:Grid, pos:Int):Bool;

	public function freeLeft():Bool;
	public function freeRight():Bool;
	public function freeUp():Bool;
	public function freeDown():Bool;

	public function freeLeftUp():Bool;
	public function freeLeftDown():Bool;
	public function freeRightUp():Bool;
	public function freeRightDown():Bool;

	public function goLeft(syncToView:Bool=true):Void;
	public function goRight(syncToView:Bool=true):Void;
	public function goUp(syncToView:Bool=true):Void;
	public function goDown(syncToView:Bool=true):Void;

	public function goLeftUp(syncToView:Bool=true):Void;
	public function goLeftDown(syncToView:Bool=true):Void;
	public function goRightUp(syncToView:Bool=true):Void;
	public function goRightDown(syncToView:Bool=true):Void;
	
	// SIM:
	public function tryFallDown():Bool;

	public function onAddToGrid():Void;
	public function onAfterMove():Void;

}
