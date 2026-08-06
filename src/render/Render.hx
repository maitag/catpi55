package render;

import peote.view.PeoteView;
import render.cell.CellRender;
import render.actor.ActorRender;

class Render {

	//--------------- STATIC ---------------------------

	public static var peoteView:PeoteView;

	public static function init(peoteView:PeoteView, stepTime:Int = 0)
	{
		Render.peoteView = peoteView;

		CellRender.init(peoteView);
		ActorRender.init(peoteView, stepTime);
	}


}