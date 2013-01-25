import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class murali_varma_hw2 extends PApplet {

//constants
final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 800;
final int CONTROLS_WIDTH = 100;

final int NUM_CREATURES = 10;
final int REFLECT_MODE = 0;
final int TOROIDAL_MODE = 1;

Creature[] creatures;
int edge_behavior = TOROIDAL_MODE;

public void setup() {
	size(SCREEN_WIDTH + CONTROLS_WIDTH, SCREEN_HEIGHT);
	background(0);
	stroke(100);

	initCreatures();
}

public void initCreatures() {
	creatures = new Creature[NUM_CREATURES];
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i] = new Creature();
	}
}

public void drawCreatures() {
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i].draw();
	}
}

public void updateCreatures() {
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i].update();
	}
}

public void draw() {
	background(100, 0.1f);
	updateCreatures();
	drawCreatures();
}

class Creature {
	float posX;
	float posY;

	float velX;
	float velY;

	float radius = 10;

	Creature() {
		posX = random(1);
		posY = random(1);
		velX = 0.01f - random(0.02f);
		velY = 0.01f - random(0.02f);
	}

	public void draw() {
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}

	public void update() {
		posX += velX;
		posY += velY;

		if (edge_behavior == TOROIDAL_MODE) {
			if (posX > 1) {
				posX = 0;
			}
			if (posY > 1) {
				posY = 0;
			}
			if (posX < 0) {
				posX = 1;
			}
			if (posY < 0) {
				posY = 1;
			}

		}
	}
};
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "murali_varma_hw2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
