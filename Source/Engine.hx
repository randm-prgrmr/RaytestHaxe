import nme.Assets;
import nme.events.Event;
import nme.display.Sprite;
import Math;
import nme.Lib;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;

class Game {
	public var posX = 2.25;
	public var posY = 2.25;
	public var dirX = 0.4328;//-1;
    public var dirY = 0.9015;//0
	public var planeX = 0.5950;//0
    public var planeY = -0.2857;//0.66
	public var w = 640;
    public var h = 480;
	
	public var sprites:Array<Sprite>;
	//-----------------------------
    public var colors:Array<Int>;
	public var worldmap:Array<Array<Int>>;
	
	public function new() {
		worldmap = [
			[1, 1, 1, 1, 1, 1, 1, 1],
			[1, 2, 0, 0, 0, 3, 3, 1],
			[1, 0, 0, 0, 0, 0, 2, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 0, 0, 0, 0, 0, 0, 1],
			[1, 4, 0, 0, 0, 0, 5, 1],
			[1, 1, 1, 1, 1, 1, 1, 1]];
		colors = [0x000000, 0x800000, 0x2080C4, 0x000080, 0x00C0C0, 0xC0C000];
		h = 480;//nme.Lib.current.stage.stageHeight;
        w = 640;//nme.Lib.current.stage.stageWidth;
		}
	}
    
class Renderer extends Sprite{
    var game:Game;
	public function new() {
		super();
		game = new Game();        
	}
	
	public function rotate(pointa:Array<Float>, angle:Int){
		var angle = angle * .0174; //degrees to radians
		var x = pointa[0] * Math.cos(angle) - pointa[1] * Math.sin(angle);
		var y = pointa[0] * Math.sin(angle) + pointa[1] * Math.cos(angle);
		return [x, y];
	}
	public function vsum(v1:Array<Float>, v2:Array<Float>) {
			return [v1[0] + v2[0], v1[1] + v2[1]];
		}

	public function render(keydown:Int) {//update frame
		graphics.clear();
		while ( this.numChildren > 0 ) { this.removeChildAt(0); }
		
		//var bmapd:BitmapData = new BitmapData( 640,480, false , 0x000000 );

		//INPUT HANDLING
		if (keydown == 39) {
			var newdir = rotate([game.dirX, game.dirY], -2);	
			game.dirX = newdir[0];
			game.dirY = newdir[1];
			
			var newdir = rotate([game.planeX, game.planeY], -2);	
			game.planeX = newdir[0];
			game.planeY = newdir[1];
		}	
		if (keydown == 37) {
			var newdir = rotate([game.dirX, game.dirY], 2);	
			game.dirX = newdir[0];
			game.dirY = newdir[1];
			
			var newdir = rotate([game.planeX, game.planeY], 2);	
			game.planeX = newdir[0];
			game.planeY = newdir[1];
		}	
		if (keydown == 38) {
			var newpos = vsum([game.posX, game.posY], [game.dirX * .08, game.dirY * .08]);
			game.posX = newpos[0];
			game.posY = newpos[1];
		}
		if (keydown == 40) {
			var newpos = vsum([game.posX, game.posY], [game.dirX * -.08, game.dirY * -.08]);
			game.posX = newpos[0];
			game.posY = newpos[1];
		}
		
		//draw black sky
			var line = new Sprite();
			line.graphics.beginFill(0x000000, 1);
			//line.graphics.drawRect(0,0, game.w, game.h/2);
			line.graphics.drawRect(0, 0, 640, 240);
			this.addChild(line);		
		//draw floor
			var line = new Sprite();
			line.graphics.beginFill(0x555555, 1);
			//line.graphics.drawRect(0, game.h/2, game.w, game.h);
			line.graphics.drawRect(0, 240, 640, 480);
			this.addChild(line);
		
		var col = 0;
		for (col in 0...game.w){
			//calculate ray position and direction
			//       x-coord in camera space
			var cameraX = 2 * col / game.w - 1;//#NEW FLOAT
			var rayPosX = game.posX;
			var rayPosY = game.posY;
			var rayDirX = game.dirX + game.planeX * cameraX;
			var rayDirY = game.dirY + game.planeY * cameraX; // + .0000000001#*NEW
			//which map grid square we are in
			var mapX = Std.int(rayPosX); 
			var mapY = Std.int(rayPosY);
			//length of ray form current position to next x or y side
			var sideDistX = 0.0; 
			var sideDistY = 0.0;
			//length of ray from one x or y side to next x or y side
			if (rayDirX == 0) { rayDirX = 0.000001; }
			if (rayDirY == 0) { rayDirY = 0.000001; }
			
			var deltaDistX = Math.sqrt(1.0 + (rayDirY * rayDirY) / (rayDirX * rayDirX));//#.0 i change
			var deltaDistY = Math.sqrt(1.0 + (rayDirX * rayDirX) / (rayDirY * rayDirY));
			var perpWallDist = 0.0;
			//'-----------------------------------'
			//what direction to step in x or y (either +1 or -1)
			var stepX = 0;
			var stepY = 0;
			var hit = 0;  //#was there a wall hit?
			var side = 0; //#was a NS or EW wall hit?
			var drawStart = 0;
			var drawEnd = 0;
			
			if(rayDirX < 0){
				stepX = -1;
				sideDistX = (rayPosX - mapX) * deltaDistX;
			}
			else{
				stepX = 1;
				sideDistX = (mapX + 1.0 - rayPosX) * deltaDistX;
			}
			if(rayDirY < 0){
				stepY = -1;
				sideDistY = (rayPosY - mapY) * deltaDistY;
			}
			else{
				stepY = 1;
				sideDistY = (mapY + 1.0 - rayPosY) * deltaDistY;
			}
			//#digital differential analysis
			while(hit == 0){
				//jump to next map square OR in x-dir OR in y-dir
				if (sideDistX < sideDistY){
					sideDistX += deltaDistX;
					mapX += stepX;
					side = 0;
				}
				else{
					sideDistY += deltaDistY;
					mapY += stepY;
					side = 1;
				}
				if (game.worldmap[mapX][mapY] > 0){
					hit = 1;
				}
			}
			//#Calculate distance projected on camera direction (oblique distance will give fisheye effect!)
			if(side == 0){
				perpWallDist = Math.abs((mapX - rayPosX + (1 - stepX) / 2) / rayDirX);//.0
			}
			else{
				perpWallDist = Math.abs((mapY - rayPosY + (1 - stepY) / 2) / rayDirY);// #.0
			}
			
			if (perpWallDist == 0) {
				perpWallDist = 0.000001;
			}
			//#Calculate height of line to draw on screen
			var lineHeight = Math.abs(Std.int(game.h / perpWallDist));
			//#calculate lowest and highest pixel to fill in current stripe]
			var drawStart = -lineHeight / 2 + game.h / 2;//#*NEW .0
			var drawEnd = lineHeight / 2 + game.h / 2;//#*NEW .0
			if (drawStart < 0) { drawStart = 0;}
			if (drawEnd >= game.h) { drawEnd = game.h - 1; }
			////////////////////////////////////////////////////////////
			//#calculate value of wallX
			var wallX = 0.0;// #where exactly the wall was hit
			if (side == 1){
				wallX = rayPosX + ((mapY - rayPosY + (1 - stepY) / 2) / rayDirY) * rayDirX;
			}
			else{
				wallX = rayPosY + ((mapX - rayPosX + (1 - stepX) / 2) / rayDirX) * rayDirY;
			}
			wallX -= Math.floor((wallX));
			/////////////DRAW THE "3D" WALLS/////////////////////
			var color = game.colors[game.worldmap[mapX][mapY]];
			if (side == 1) { color = Std.int(color / 2.0); }
			
			var line = new Sprite();
			line.graphics.beginFill(color, 1);
			line.graphics.drawRect(col, drawStart, 1, drawEnd-drawStart);
			this.addChild(line);
			
			//testing whether bitmap drawing is faster
			/*bmapd.fillRect(new Rectangle(col, drawStart, 1, drawEnd-drawStart), color);
			var setBitmap:Bitmap = new Bitmap(bmapd);			
			this.addChild( setBitmap );
			//----------
			var background : nme.display.Bitmap;
			g.clear();
			g.beginBitmapFill(background.bitmapData, true, true);
			g.drawRect(0, 0, 640, 480);
			g.endFill();
			*/
			
		}//end col loop

	}//end renderer method
}//close Render class