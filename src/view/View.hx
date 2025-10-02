package view;

import peote.view.PeoteView;

import automat.Viewer;
import render.Render;

class View {

	public var peoteView:PeoteView;
	
	public var width:Int = 0;
	public var height:Int = 0;

	public var viewer:Viewer; // this will be the server into network!

	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		var render = new Render(peoteView);

	}

}