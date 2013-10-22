import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.Lib;
import Engine; 

class RenderTest extends Sprite {
	var display:Renderer;
	var kdown:Int;
	public function new () {
		super();
		kdown = 1337;
		display = new Engine.Renderer(); 
		addChild(display);
		Lib.current.stage.addEventListener (KeyboardEvent.KEY_DOWN, key_DOWN);
		Lib.current.stage.addEventListener (KeyboardEvent.KEY_UP, key_UP);
		addEventListener (Event.ENTER_FRAME, gameloop);//move this into the new() of renderer
	}
	private function key_DOWN(event:KeyboardEvent) {
		kdown = event.keyCode;
		//trace(Std.string(kdown));
	}
	private function key_UP(event:KeyboardEvent) {
		kdown = 1337;
	}
	
	private function gameloop (event:Event):Void{
		display.render(kdown);
	}
}