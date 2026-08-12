package render.cell;

import haxe.ds.Vector;

// assets
import asset.Util;
import asset.Anim;
import asset.Tile;
import asset.Sheet;

abstract CellConfigStatic(Map<Int, {tile:Tile, anim:Int}>) from Map<Int, {tile:Tile, anim:Int}>
{
	//@:to 
	// public function toConfigVector(sheets:Array<Sheet>):Vector<CellElemConfigStatic> {
	public function toConfigVector():Vector<CellElemConfigStatic> {
		
		var keyMax:Int = 0;
		for ( key in this.keys()) {
			if ((key:Int) > keyMax) keyMax = key;
		}
		
		// TODO: optimize in Vector<Int>;
		var conf = new Vector<CellElemConfigStatic>(keyMax+1);
		
		for ( key => value in this) {
			var tile:Tile = value.tile;
			// var sheet = sheets[ tile.sheet ];
			conf.set(key, {
				tileNr:tile.anim(tile.animID[value.anim]).start,
				// sheetNr:tile.sheet,
				// width:sheet.width,
				// height:sheet.height
			});
		}
		
		return conf;
	}

}
