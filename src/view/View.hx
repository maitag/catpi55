package view;

import peote.view.PeoteView;

import automat.GridView;
import render.Render;

 // this will be later handled by Remote-Client in peote-net!
class View {

	public var peoteView:PeoteView;
	
	public var width:Int = 0;
	public var height:Int = 0;

	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		// TODO: disable testrenderings!
		// var render = new Render(peoteView);

	}


	// TODO: adding the sync functions from automat->GridView
	

}