package catpi.render;

import peote.view.PeoteView;

import catpi.render.cell.CellRender;
import catpi.render.actor.ActorRender;

class Render {

	//--------------- STATIC ---------------------------

	public static var peoteView:PeoteView;

	public static function init(peoteView:PeoteView, stepTime:Int = 0)
	{
		Render.peoteView = peoteView;

		// TODO: to make it more easy later to init them all together:
		
		// CellRender.init(peoteView);
		// ActorRender.init(peoteView, stepTime);
	}


}