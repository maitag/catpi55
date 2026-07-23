package render.actor;

import haxe.ds.IntMap;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.TextureConfig;

import automat.actor.ActorType;

// assets
import asset.Util;
import asset.generated.actors.Actors;
import asset.generated.actors.Actors.TileID;
// import asset.generated.Actors.AnimID;

class ActorRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;
	public static var textures:Array<Texture>;

	public static function init(peoteView:PeoteView) {
		ActorRender.peoteView = peoteView;
		loadTextures();
	}

	public static function loadTextures() {

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		textures = Util.loadTextures(Actors.sheets, textureConfig, false);
	}
	//--------------------------------------------------

	var display:ActorDisplay;

	var bufferStatic:Buffer<ActorElemStatic>;
	var bufferAnim:Buffer<ActorElemAnim>;

	var elemViewBuffer:IntMap<ActorElemStatic>;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return display.zoom;
	inline function set_zoom(z:Float):Float return display.zoom = z;

	// -------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		bufferStatic = new Buffer<ActorElemStatic>(1024, 512);
		bufferAnim = new Buffer<ActorElemAnim>(1024, 512);

		display = new ActorDisplay(x, y, width, height, bufferStatic, bufferAnim, textures);
		peoteView.addDisplay(display);
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewBuffer = new IntMap<ActorElemStatic>();
	}
	// public function purgeView() {}

	public inline function addActor(x:Int, y:Int, mapkey:Int, actorType:ActorType) {
		var px = x*32 + scrollOffsetX;
		var py = y*32 + scrollOffsetY;
		switch (actorType) {
			// TODO
			case STONE1x1:
				var tile = Actors.tile(TileID.STONE1x1);
				var sheet = Actors.sheets[ tile.sheet ];
				var element = new ActorElemStatic(tile.anim(tile.animID[0]).start , tile.sheet, px, py, sheet.width, sheet.height);
				elemViewBuffer.set(mapkey, element);
				bufferStatic.addElement(element);

			case STONE1x2:
				var tile = Actors.tile(TileID.STONE1x2);
				var sheet = Actors.sheets[ tile.sheet ];
				var element = new ActorElemStatic(tile.anim(tile.animID[0]).start , tile.sheet, px, py, sheet.width, sheet.height);
				elemViewBuffer.set(mapkey, element);
				bufferStatic.addElement(element);

			case STONE2x2:
				var tile = Actors.tile(TileID.STONE2x2);
				var sheet = Actors.sheets[ tile.sheet ];
				var element = new ActorElemStatic(tile.anim(tile.animID[0]).start , tile.sheet, px, py, sheet.width, sheet.height);
				elemViewBuffer.set(mapkey, element);
				bufferStatic.addElement(element);

			case CROSS:
				var tile = Actors.tile(TileID.CROSS);
				var sheet = Actors.sheets[ tile.sheet ];
				var element = new ActorElemStatic(tile.anim(tile.animID[0]).start , tile.sheet, px, py, sheet.width, sheet.height);
				elemViewBuffer.set(mapkey, element);
				bufferStatic.addElement(element);

			case EDGEBR3x3:
				var tile = Actors.tile(TileID.EDGEBR3x3);
				var sheet = Actors.sheets[ tile.sheet ];
				var element = new ActorElemStatic(tile.anim(tile.animID[0]).start , tile.sheet, px, py, sheet.width, sheet.height);
				elemViewBuffer.set(mapkey, element);
				bufferStatic.addElement(element);

			default: throw('ActorRender - actorType $actorType not implemented yet!');
		}
	}
	
	public inline function removeActor(mapkey:Int) {
		var element = elemViewBuffer.get(mapkey);
		// if (element!=null) {
			bufferStatic.removeElement(element);
			elemViewBuffer.remove(mapkey);
		// }
	}

	// swaps the mapkeys if actor enters a new gridView
	public function actorChangeMapkey(oldMapkey:Int, newMapkey:Int) {
		var element = elemViewBuffer.get(oldMapkey);
		elemViewBuffer.remove(oldMapkey);
		elemViewBuffer.set(newMapkey, element);
	}

	// ---- actor moves ----

	// TODO: animation

	public function actorGoLeft(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		// var px = x*32 + scrollOffsetX;
		element.x -= 32;
		bufferStatic.updateElement(element);
	}
	public function actorGoRight(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.x += 32;
		bufferStatic.updateElement(element);
	}
	public function actorGoUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.y -= 32;
		bufferStatic.updateElement(element);
	}
	public function actorGoDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.y += 32;
		bufferStatic.updateElement(element);
	}





	// TODO
	public function updateActor(mapkey:Int, action:Int) { // TODO: action!
	}



	// ------- scrolling ----------

	public var scrollOffsetX:Int = 0;
	public var scrollOffsetY:Int = 0;
	static inline var RESET_AT_OFFSET:Int = 16384;
	
	public function scrollLeft() {
		if (display.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.x += RESET_AT_OFFSET;
			bufferStatic.update();
			display.xOffset -= RESET_AT_OFFSET;
		}
		display.xOffset += 32;		
	}

	public function scrollRight() {
		if (display.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.x -= RESET_AT_OFFSET;
			bufferStatic.update();
			display.xOffset += RESET_AT_OFFSET;
		}
		display.xOffset -= 32;	
	}

	public function scrollTop() {
		if (display.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.y += RESET_AT_OFFSET;
			bufferStatic.update();
			display.yOffset -= RESET_AT_OFFSET;
		}
		display.yOffset += 32;		
	}

	public function scrollBottom() {
		if (display.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.y -= RESET_AT_OFFSET;
			bufferStatic.update();
			display.yOffset += RESET_AT_OFFSET;
		}
		display.yOffset -= 32;
	}
	
}