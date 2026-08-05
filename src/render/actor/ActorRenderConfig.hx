package render.actor;

import haxe.ds.Vector;
import automat.actor.ActorType;

// assets
import asset.Util;
import asset.generated.actors.Actors;
import asset.generated.actors.Actors.TileID;
// import asset.generated.Actors.AnimID;

class ActorRenderConfig {
	
	var conf:Vector<ActorElemConfig>;

	static var typeToTile:Map<ActorType, TileID> = [
		STONE1x1 => TileID.STONE1x1,
		STONE1x2 => TileID.STONE1x2,
		STONE2x2 => TileID.STONE2x2,
		CROSS => TileID.CROSS,
		EDGEBR3x3 => TileID.EDGEBR3x3,
		HAXE => TileID.HAXE,
		LIME => TileID.LIME,
		OPENFL => TileID.OPENFL,
		FLIXEL => TileID.FLIXEL,
		SEMMI => TileID.SEMMI
	];

	public function new() {
		conf = new Vector<ActorElemConfig>(ActorType.length);
		
		for ( actorType => tileID in typeToTile) {
			var tile = Actors.tile(tileID);
			var sheet = Actors.sheets[ tile.sheet ];
			conf.set(actorType, {
				tileNr:tile.anim(tile.animID[0]).start,
				sheetNr:tile.sheet,
				width:sheet.width,
				height:sheet.height
			});
		}
		
	}

	public inline function get(actorType:ActorType):ActorElemConfig {
		return conf.get(actorType);
	}

}

@:structInit @:publicFields
class ActorElemConfig {
	var tileNr:Int;
	var sheetNr:Int;
	var width:Int;
	var height:Int;
}