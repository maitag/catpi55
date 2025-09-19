package render;


import peote.view.Element;
import peote.view.Color;

class ElemGas implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX public var x:Int=0;
	@posY public var y:Int=0;
	
	// size in pixel
	@sizeX public var w:Int=32;
	@sizeY public var h:Int=32;
		
	// color (RGBA)
	@color public var c:Color = Color.GREEN;
		
	public function new() {}
}
