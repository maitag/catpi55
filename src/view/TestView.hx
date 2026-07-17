package view;

import haxe.Timer;
import util.Maze;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;

import automat.GridTestData;
import automat.Grid;
import automat.GridView;
import automat.MultiGridView;
import automat.actor.*;
import automat.sim.SimEvent;
import automat.sim.SimEvent.SimEventType;

import util.Pos.xy as P;

import render.Render;
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

	var actor = new Stone2x2("player");

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);

		Render.init(peoteView);
		
		var grid:Grid = GridTestData.create3x3();
		// var grid:Grid = GridTestData.createMaze(2,2);
		// var grid:Grid = GridTestData.createMaze(50,50);
		
		// controllable actor
		actor.addToGrid(grid.right, P(5,4));

		var actor1 = new Stone1x1("Stone1x1");
		actor1.addToGrid(grid, P(1,1));

		var actor2 = new Stone1x2("Stone1x2");
		actor2.addToGrid(grid, P(2,1));

		var actor3 = new Stone2x2("Stone2x2");
		actor3.addToGrid(grid, P(3,1));


		var actor4 = new Stone2x2("Stone2x2");
		actor4.addToGrid(grid.right, P(0,0));
		
		// GridTestData.traceGrid(grid, 64, 64);
		
		var rootX:Int = 0;
		var rootY:Int = 0;

		var maxWidth = 40;
		var maxHeight = 30;

		view = new View(peoteView, 0, 0, 1280, 640);
		multiGridView = new MultiGridView(view, grid, rootX, rootY, maxWidth, maxHeight);

		view.zoom = 0.620921323059155;
		// trace(multiGridView.gridViewCache);
		// trace(new Maze(10,10).toString());


		// TODO:
		// actor1.tryFallDown();

		// -------- grid simmulation ----------
		grid.setSimEvent(new SimEvent(CELL_MOVE, P(1,1)), 0); // immediadly
		grid.setSimEvent(new SimEvent(CELL_EMPTY, P(3,4)), Grid.MAX_STEPS-1); // max delay time 

		// simmulate 10 timesteps
		/*
		for (i in 0...10) {
			trace('step $i');
			grid.step();
		}
		*/
		
		
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
