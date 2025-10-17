package automat;

import automat.Cell.CellActor;
import haxe.ds.Vector;

class MainActorList {
	
	public var actorList:Vector<Actor>;
	public var freeIndexList:Vector<Int>;
	var pos:Int = 0;
	var posFree:Int = -1;

	public var length(get, never):Int;
	public inline function get_length():Int return pos - (posFree + 1);

	public inline function new(size:Int) {
		actorList = new Vector(size);
		freeIndexList = new Vector(size);
	}

	public inline function get(index:Int):Actor {
		return actorList.get(index);
	}

	public inline function add(actor:Actor):Int {
		if (posFree == -1) {
			if (pos == actorList.length) throw("MainActorList 'add' OVERFLOW");
			actorList.set(pos, actor);
			return pos++;
		}
		else {
			var index = freeIndexList.get(posFree--);
			actorList.set(index, actor);
			return index;
		}
	}

	public inline function remove(index:Int) {
		if (index < 0 || index >= pos) throw("MainActorList 'remove' - index is out of range");
		if (index == pos-1) {
			pos--;
		}
		else {
			if (posFree >= freeIndexList.length) throw("MainActorList 'remove' freeIndexList OVERFLOW");
			freeIndexList.set(++posFree, index);
		}
		
	}
}