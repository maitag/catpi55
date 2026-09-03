package catpi.render.actor;

import catpi.render.actor.simple.ElemSimple;
import haxe.ds.Vector;
import haxe.ds.IntMap;

import peote.view.PeoteView;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.TextureConfig;

import catpi.asset.Util;
import catpi.asset.Sheet;

import catpi.render.RenderView;
import catpi.render.ActorRenderType;
import catpi.render.ActorRenderConfig;
import catpi.render.actor.simple.ProgSimple;

class ActorRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;
	public static var textures:Array<Texture>;

	public static var stepTime:Float = 0.0;

	public static var config:Vector<ActorElemConfig>;
	public static var renderTypeSheets:Map<ActorRenderType, Array<Int>>;
	public static var maxActions:Int;

	public static function init(peoteView:PeoteView, stepTime:Int, sheets:Array<Sheet>, config:ActorRenderConfig) {
		ActorRender.peoteView = peoteView;
		ActorRender.stepTime = stepTime / 860; // <- TODO
		loadTextures(sheets);

		var c = config.toConfigVector(sheets);
		ActorRender.config = c.config;
		ActorRender.renderTypeSheets = c.renderTypeSheets;
		ActorRender.maxActions = c.maxActions;
	}

	public static function loadTextures(sheets:Array<Sheet>) {

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		textures = Util.loadTextures(sheets, textureConfig, false);
	}
	//--------------------------------------------------

	var display:ActorDisplay;

	var progSimple:ProgSimple;
	// var prog1x1:Prog1x1Simple; // for 1x1 actor shapes and tilesheets

	var elemViewBuffer:IntMap<ActorElem>;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return display.zoom;
	inline function set_zoom(z:Float):Float return display.zoom = z;

	// -------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		// TODO: only for what is in usage by config
		var usedPrograms = new Array<Program>();
		for (renderType => sheets in renderTypeSheets)
		{
			var usedTextures = new Array<Texture>();
			for (sheet in sheets) usedTextures.push(textures[sheet]);
			usedPrograms.push(
				switch (renderType) {
					case SIMPLE: progSimple = new ProgSimple(usedTextures, 1024, 512);
					case ANIM: null; // progAnim = ...
				}
			);
		}

		display = new ActorDisplay(x, y, width, height, usedPrograms);
		peoteView.addDisplay(display);
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewBuffer = new IntMap<ActorElem>();
	}
	// public function purgeView() {}

	public inline function addActor(x:Int, y:Int, mapkey:Int, actorType:Int) {
		var px = x * RenderView.cellWidth + scrollOffsetX;
		var py = y * RenderView.cellHeight + scrollOffsetY;

		// TODO: add animation-ACTIONS !
		var conf = config.get(actorType * maxActions); // TODO: + actionType
		var element = switch(conf.renderType) {
			case SIMPLE: new ElemSimple(conf.tileStart, conf.sheetNr, px, py, conf.width, conf.height);
			case ANIM: null; // <-TODO
		} 
		elemViewBuffer.set(mapkey, element);
		element.add();
	}
	
	public inline function removeActor(mapkey:Int) {
		// trace("remove", mapkey);
		var element = elemViewBuffer.get(mapkey);
		// if (element!=null) {
			element.remove();
			elemViewBuffer.remove(mapkey);
		// }
	}

	// swaps the mapkeys if actor enters a new gridView
	public function actorChangeMapkey(oldMapkey:Int, newMapkey:Int) {
		// trace("actorChangeMapkey", oldMapkey, newMapkey);
		var element = elemViewBuffer.get(oldMapkey);
		elemViewBuffer.remove(oldMapkey);
		elemViewBuffer.set(newMapkey, element);
	}

	// ---- actor moves ----

	// TODO: animation

	public function actorGoLeft(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeft(peoteView.time, stepTime*time);
	}
	public function actorGoRight(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRight(peoteView.time, stepTime*time);
	}
	public function actorGoUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goUp(peoteView.time, stepTime*time);
	}
	public function actorGoDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goDown(peoteView.time, stepTime*time);
	}

	public function actorGoLeftUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeftUp(peoteView.time, stepTime*time);
	}
	public function actorGoLeftDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goLeftDown(peoteView.time, stepTime*time);
	}
	public function actorGoRightUp(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRightUp(peoteView.time, stepTime*time);
	}
	public function actorGoRightDown(mapkey:Int, time:Int) {
		var element = elemViewBuffer.get(mapkey);
		element.goRightDown(peoteView.time, stepTime*time);
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
			progSimple.buffer.update();
			display.xOffset -= RESET_AT_OFFSET;
		}
		display.xOffset += RenderView.cellWidth;		
	}

	public function scrollRight() {
		if (display.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.x -= RESET_AT_OFFSET;
			progSimple.buffer.update();
			display.xOffset += RESET_AT_OFFSET;
		}
		display.xOffset -= RenderView.cellWidth;	
	}

	public function scrollTop() {
		if (display.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.y += RESET_AT_OFFSET;
			progSimple.buffer.update();
			display.yOffset -= RESET_AT_OFFSET;
		}
		display.yOffset += RenderView.cellHeight;		
	}

	public function scrollBottom() {
		if (display.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			for (element in elemViewBuffer) element.y -= RESET_AT_OFFSET;
			progSimple.buffer.update();
			display.yOffset += RESET_AT_OFFSET;
		}
		display.yOffset -= RenderView.cellHeight;
	}
	
}