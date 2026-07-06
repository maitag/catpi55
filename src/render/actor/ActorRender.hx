package render.actor;

import haxe.ds.IntMap;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.TextureConfig;
import peote.view.Load;

import automat.actor.ActorType;

// TODO
// import asset.generated.Actors as ActorAsset;
// import asset.generated.Actors.TileID as ActorTileID;
// import asset.generated.Actors.AnimID as AnimID;

class ActorRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;
	public static var texture:Texture;

	public static function init(peoteView:PeoteView) {
		ActorRender.peoteView = peoteView;
		loadTextures();
	}

	public static function loadTextures() {
		// TODO
		/*var sheet = ActorAsset.sheets[0];

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
			tilesX: sheet.tilesX,
			tilesY: sheet.tilesY
		};

		texture = new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig);
		
		Load.image( "assets/" + sheet.name,
			true,
			function (image:Image) {
				texture.setData(image);				
			}
		);
		*/
	}

	//----------------------------------------------------

	public var actorDisplay:ActorDisplay;

	var actorBufferStatic:Buffer<ActorElemStatic>;
	var actorBufferAnim:Buffer<ActorElemAnim>;

	var elemViewMap:IntMap<ActorElemStatic>;

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		actorBufferStatic = new Buffer<ActorElemStatic>(1024, 512);
		actorBufferAnim = new Buffer<ActorElemAnim>(1024, 512);

		actorDisplay = new ActorDisplay(x, y, width, height, actorBufferStatic, actorBufferAnim, texture);
		peoteView.addDisplay(actorDisplay);
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewMap = new IntMap<ActorElemStatic>();
	}
	// public function purgeView() {}

	public inline function addActor(x:Int, y:Int, mapkey:Int, actorType:ActorType) {
		var px = x*32 + scrollOffsetX;
		var py = y*32 + scrollOffsetY;
		switch (actorType) {
			case STONE1x1:
				// TODO
				// var element = new ActorElemStatic(ActorTileID.STONE1x1, px, py, 32, 32);
				// elemViewMap.set(mapkey, element);
				// actorBufferStatic.addElement(element);

			default:
		}
	}
	
	public inline function removeActor(mapkey:Int) {
		var element = elemViewMap.get(mapkey);
		// if (element!=null) {
			actorBufferStatic.removeElement(element);
			// TODO: is this need?
			// elemViewMap.remove(mapkey);
			// elemViewMap.set(mapkey, null);
		// }
	}

	public function updateActor(mapkey:Int, action:Int) { // TODO: action!
		// TODO
	}



	// ------- scrolling ----------

	public var scrollOffsetX:Int = 0;
	public var scrollOffsetY:Int = 0;
	static inline var RESET_AT_OFFSET:Int = 16384;
	
	public function scrollLeft() {
		if (actorDisplay.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			// for (i in 0...(elemViewMap.sizeX * elemViewMap.sizeY)) {
				// var element = elemViewMap.data.get(i);
				// if (element!=null) element.x += RESET_AT_OFFSET;
			// }
			actorBufferStatic.update();
			actorDisplay.xOffset -= RESET_AT_OFFSET;
		}

		actorDisplay.xOffset += 32;		
	}

	public function scrollRight() {
		if (actorDisplay.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			// for (i in 0...(elemViewMap.sizeX * elemViewMap.sizeY)) {
				// var element = elemViewMap.data.get(i);
				// if (element!=null) element.x -= RESET_AT_OFFSET;
			// }
			actorBufferStatic.update();
			actorDisplay.xOffset += RESET_AT_OFFSET;
		}

		actorDisplay.xOffset -= 32;	
	}

	public function scrollTop() {
		if (actorDisplay.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			// for (i in 0...elemViewMap.data.length) {
			// 	var element = elemViewMap.data.get(i);
			// 	if (element!=null) element.y += RESET_AT_OFFSET;
			// }
			actorBufferStatic.update();
			actorDisplay.yOffset -= RESET_AT_OFFSET;
		}

		actorDisplay.yOffset += 32;		
	}

	public function scrollBottom() {
		if (actorDisplay.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			// for (i in 0...elemViewMap.data.length) {
			// 	var element = elemViewMap.data.get(i);
			// 	if (element!=null) element.y -= RESET_AT_OFFSET;
			// }
			actorBufferStatic.update();
			actorDisplay.yOffset += RESET_AT_OFFSET;
		}

		actorDisplay.yOffset -= 32;
	}
	
}