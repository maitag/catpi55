package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Color;


import assets.Pipeline;
import assets.PipelineTools;

class ElemAnim implements Element
{
	// position in pixel
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;
	
	// rotation around pivot point
	@rotation public var r:Float;
	
	// pivot x (rotation offset)
	@pivotX public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY public var py:Int = 0;
	
	// color (RGBA)
	@color public var c:Color = 0xffffffff;
	
	// z-index
	@zIndex public var z:Int = 0;

	// texture unit (sheet index!)
	@texUnit public var sheetIndex:Int=0;

	// @texSlot public var slot:Int = 0;

	// animatable tile-number into sheet
	@anim("Tile") @texTile public var tileIndex:Int = 0;

	public static var buffer:Buffer<ElemAnim>;
	

	public function new(x:Int, y:Int, tileName:String) {
		this.x = x;
		this.y = y;
		// tile = tiles.get(tileName);
		// w = tile.width;
		// h = tile.height;
		// sheetIndex = tile.sheetIndex;
	}

	public function play(animName:String, startTime:Float, duration:Float) {
		// var anim = tile.anim.get(animName);
		// animTile(anim.start, anim.end);
		timeTileStart = startTime;
		timeTileDuration = duration;
	}
}

class TestAssets extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try start(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var buffer:Buffer<ElemAnim>;
	var display:Display;
	var program:Program;

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);
		display   = new Display(0,0, window.width, window.height, Color.RED1);
		peoteView.addDisplay(display);
		
		buffer  = new Buffer<ElemAnim>(100);
		program = new Program(buffer);
		program.blendEnabled = true;

		display.addProgram(program);
		
		program.setMultiTexture(PipelineTools.loadTextures(Pipeline.sheets), "custom");

		// trace(Pipeline.tile(haxeLogo).anim(cubicRotate).start);		
		// var logo = Pipeline.tile(haxeLogo);
		// trace( logo.anim(sphereRotate).end );
		// trace( Pipeline.tile(haxeLogo).anim("sphereToCubic").end );


		for (tileID in TileID)
		{
			trace(TileID.names[tileID]);

			var tile = Pipeline.tile(tileID);

			for (animID in tile.animID)
			{
				// trace(animID);
				trace("  "+ AnimID.names[animID], tile.anim(animID).start, tile.anim(animID).end);
			}
		}
		

	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	
	override function update(deltaTime:Int):Void {
		// for game-logic update
	}
	
	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		
		
	// override function onPreloadComplete():Void {} // access embeded assets from here

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (deltaY<0) peoteView.zoom /= 1.1;
		else peoteView.zoom *= 1.1;
	}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
