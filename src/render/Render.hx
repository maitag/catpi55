package render;

import lime.graphics.Image;

import peote.view.intern.Util;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

import render.cell.CellDisplay;
import render.cell.CellElemAnim;
import render.cell.CellElemStatic;

class Render {

	var peoteView:PeoteView;

	//----------------------------------------------------

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;
	

	}


}