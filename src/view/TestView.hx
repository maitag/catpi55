package view;

import automat.Cell.CellActor;
import haxe.Timer;
import util.Maze;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;

import automat.GridTestData;
import automat.Grid;
import automat.MultiGridView;
import automat.actor.*;

import util.Pos.xy as P;

import render.Render;
import render.RenderView;
import view.View;



class TestView extends Application
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
	var multiGridView:MultiGridView;
	var view:View;
	var grid:Grid;

	var actor = new Semmi("player");

	static inline var SIM_STEP_TIME:Int = 100;

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);

		
		var rootX:Int = 0;
		var rootY:Int = 0;
		var maxWidth = 40;
		var maxHeight = 30;
		var zoom = 0.620921323059155;
		
		Render.init(peoteView, SIM_STEP_TIME);

		// var renderView = new RenderView(0, 0, 800, 600);
		var renderView = new RenderView(0, 0, Std.int(maxWidth*32*zoom), Std.int(maxHeight*32*zoom));
		
		view = new View(renderView);
		view.zoom = zoom;


		grid = GridTestData.create3x3(); // GridTestData.createMaze(2,2);
		// GridTestData.traceGrid(grid, 64, 64);

		
		multiGridView = new MultiGridView(view, grid, rootX, rootY, maxWidth, maxHeight);
		// trace(multiGridView.gridViewCache);


		
		
		// ---- test SIMMULATION ---
		
		// spawn some haxe actors
		for (i in 0...17)new Haxe(grid, P(10+i*3,10));
		for (i in 0...9) new Haxe(grid, P(17+i*3,12));
		for (i in 0...9) new Haxe(grid, P(16+i*3,14));
		for (i in 0...9) new Haxe(grid, P(17+i*3,16));
		for (i in 0...9) new Haxe(grid, P(16+i*3,18));
		for (i in 0...9) new Haxe(grid, P(17+i*3,20));
		for (i in 0...9) new Haxe(grid, P(16+i*3,22));
		for (i in 0...9) new Haxe(grid, P(17+i*3,24));
		for (i in 0...9) new Haxe(grid, P(16+i*3,26));
		for (i in 0...9) new Haxe(grid, P(17+i*3,28));
		
		new Flixel("A",grid, P(62,27));
		new Flixel("B",grid, P(62,29));
		
		new Cross("C",grid, P(2,5));
		new Cross("C",grid, P(5,5));
		new Cross("C",grid, P(8,5));
		new Cross("C",grid, P(1,7));
		new Cross("C",grid, P(3,8));
		new Cross("C",grid, P(2,10));
		for (i in 0...17) new Cross("C",grid, P(1,12+i*3));

		for (i in 0...7) new EdgeBR3x3("E",grid, P(14+i,1+i));

		// ((hope will H E L P ;))
		new Lime("4theSIGNmajesties", grid, P(1,1));
		new OpenFL("flash for fantasy", grid, P(2,1));

		
		peoteView.start();		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	var deltaTimeSum:Int = SIM_STEP_TIME;

	override function update(deltaTime:Int):Void {
		if (grid==null) return;

		if (deltaTimeSum < SIM_STEP_TIME) {
			deltaTimeSum += deltaTime;
		}
		else 
		{
			deltaTimeSum -= SIM_STEP_TIME;

			grid.step(); grid.right.step();	grid.right.right.step();
			grid.bottom.step(); grid.bottom.right.step(); grid.bottom.right.right.step();
			grid.bottom.bottom.step(); grid.bottom.bottom.right.step(); grid.bottom.bottom.right.right.step();
			// spawn a new on if there is free space:
			if (grid.get(P(0,4)).actor == CellActor.EMPTY ) new Lime("", grid, P(0,4));
		}
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
		// if (deltaY<0) peoteView.zoom /= 1.1; else peoteView.zoom *= 1.1;
		if (deltaY<0) {
			if (view.zoom > 0.63) view.zoom /= 1.1;
		}			
		else view.zoom *= 1.1;
		// trace(view.zoom);
	}

	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		switch(keyCode) {

			// scroll the view
			case LEFT:
				if (multiGridView.canGrowLeft(false)) {
					multiGridView.scrollLeft();
					view.scrollLeft();
				}
			case RIGHT:
				if (multiGridView.canGrowRight(false)) {
					multiGridView.scrollRight();
					view.scrollRight();
				}
			case UP:
				if (multiGridView.canGrowTop(false)) {
					multiGridView.scrollTop();
					view.scrollTop();
				}
			case DOWN:
				if (multiGridView.canGrowBottom(false)) {
					multiGridView.scrollBottom();
					view.scrollBottom();
				}
			
			// move the actor
			case A:
				if (actor.freeLeft()) {
					actor.goLeft();
				}
			case D:
				if (actor.freeRight()) {
					actor.goRight();
				}
			case W:
				if (actor.freeUp()) {
					actor.goUp();
				}
			case S:
				if (actor.freeDown()) {
					actor.goDown();
				}
			case Q:
				if (actor.freeLeftUp()) {
					actor.goLeftUp();
				}
			case Y:
				if (actor.freeLeftDown()) {
					actor.goLeftDown();
				}
			case E:
				if (actor.freeRightUp()) {
					actor.goRightUp();
				}
			case C:
				if (actor.freeRightDown()) {
					actor.goRightDown();
				}
	

			default:
		}
	}	
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
