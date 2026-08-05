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

	// TODO: make this customizable for ActorTypes and generated Assets
	// -> let it be Argument for ActorRender.init()
	// and together with the Actor.sheets for the textures to load
	static var mapTypeToTile:Map<ActorType, TileID> = [
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

	// TODO: better handle all of this into ActorRender as static into init()
	// and fully asset-customizable then!
	public function new() {
		
		var keyMax:Int = 0;
		for ( key in mapTypeToTile.keys()) {
			if ((key:Int) > keyMax) keyMax = key;
		}
		
		conf = new Vector<ActorElemConfig>(keyMax+1);
		
		for ( actorType => tileID in mapTypeToTile) {
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