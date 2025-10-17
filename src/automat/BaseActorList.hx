package automat;

import automat.Cell.CellActor;
import haxe.ds.Vector;

class BaseActorList {

	public var actorList:Vector<Int>; // TODO: Int to -> abstract BaseActor<Int>
	var pos:Int = 0;
	var posFree:Int;

	public var length(get, never):Int;
	public inline function get_length():Int return pos - (posFree-size + 1);

	var size:Int;

	public inline function new(size:Int) {
		this.size = size;
		posFree = size - 1;
		actorList = new Vector(size<<1);
	}

	public inline function get(index:Int):Int {
		return actorList.get(index);
	}

	public inline function add(actor:Int):Int {
		if (posFree < size) {
			if (pos == size) throw("BaseActorList 'add' OVERFLOW");
			actorList.set(pos, actor);
			return pos++;
		}
		else {
			var index = actorList.get(posFree--);
			actorList.set(index, actor);
			return index;
		}
	}

	public inline function remove(index:Int) {
		if (index < 0 || index >= pos) throw("BaseActorList 'remove' - index is out of range");
		if (index == pos-1) {
			pos--;
		}
		else {
			if (posFree >= size) throw("BaseActorList 'remove' free Index OVERFLOW");
			actorList.set(++posFree, index);
		}
		
	}
}