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

final int REFLECT_MODE = 0;
final int TOROIDAL_MODE = 1;

final int NUM_CREATURES = 100;

final float EPSILON = 0.001f;

int edgeBehavior = REFLECT_MODE;
int backgroundAlpha = 100;	//0 for full trail, 255 for no trail

//flock centering, velocity matching, collision avoidance, wandering force
boolean flockCenteringForce = true;
boolean velocityMatchingForce = true;
boolean collisionAvoidanceForce = true;
boolean wanderingForce = true;

public void setup() {
	size(SCREEN_WIDTH + CONTROLS_WIDTH, SCREEN_HEIGHT);
	background(0);
	stroke(100);

	initNeighborGrids();
	initCreatures();
}

public void drawBackground() {
	fill(0,backgroundAlpha);
	rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
	fill(0);	//draw controls without any alpha value so that ball trails will not be drawn in the control area
	rect(SCREEN_WIDTH,0,CONTROLS_WIDTH,SCREEN_HEIGHT);
}

public void initCreatures() {
	creatures = new Creature[NUM_CREATURES];
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i] = new Creature(i);
	}
}

public void drawCreatures() {
	fill(255);
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
	drawBackground();
	computeNeighborGrids();
	updateCreatures();
	drawCreatures();
}

public void keyPressed() {
	//simulation
	if (key == 'q') {
		noLoop();
	}
	else if(key == 'w') {
		noLoop();
		redraw();
	}
	else {
		loop();
	}

	//forces
	if (key == '4') {
		wanderingForce = !wanderingForce;
	}
}
Creature[] creatures;

class Creature {
	int idx;

	float posX;
	float posY;

	float velX;
	float velY;

	float forceX;
	float forceY;

	float radius = 10;

	ArrayList neighbors;

	Creature(int i) {
		idx = i;
		posX = random(1);
		posY = random(1);

		neighbors = new ArrayList();
	}

	public void draw() {
		fill (255);
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}

	public void update() {
		neighbors = getNeighbors(FLOCK_CENTERING_RADIUS);
		applyForces();
		velX += forceX;
		velY += forceY;

		//clamp velocities
		velX = max(-0.001f, min(velX, 0.001f));
		velY = max(-0.001f, min(velY, 0.001f));

		posX += velX;
		posY += velY;

		if (edgeBehavior == TOROIDAL_MODE) {
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
		else {
			//reflect mode
			if (posX > 1 || posX < 0) {
				velX *= -1;
				posX += 2 * velX;	//to compensate for creature having gone out of screen
			}
			if (posY > 1 || posY < 0) {
				velY *= -1;
				posY += 2 * velY;
			}
		}
	}

	public void applyForces() {
		forceX = 0;
		forceY = 0;

		//apply the 4 forces to the creature and update its x and y velocities
		if (wanderingForce) {
			forceX = 0.0002f - random(0.0004f);
			forceY = 0.0002f - random(0.0004f);
		}

		if (flockCenteringForce) {
			float weightSum = 0;
			float fx = 0;
			float fy = 0;
			for (int i = 0; i < neighbors.size(); i++) {
				Creature neighbor = creatures[PApplet.parseInt(neighbors.get(i).toString())];
				float weight = 1/(distSq(idx, neighbor.idx) + EPSILON);
				weightSum += weight;
				fx += weight * (neighbor.posX - posX);
				fy += weight * (neighbor.posY - posY);
			}
			weightSum *= 100;
			if (weightSum != 0) {
				forceX += fx/weightSum;
				forceY += fy/weightSum;
			}
		}
	}

	public ArrayList getNeighbors(float radius) {
		return getNearestNeighbors(idx, radius);
	}
};

final float FLOCK_CENTERING_RADIUS = 0.2f;

HashMap flockCenterGrid;

public void initNeighborGrids() {
	flockCenterGrid = new HashMap();
}

public void computeNeighborGrids() {
	//use active forces and compute separate neighbor grids for each force
	float radius = FLOCK_CENTERING_RADIUS;
	flockCenterGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = PApplet.parseInt(creatures[i].posX/radius) + "," + PApplet.parseInt(creatures[i].posY/radius);
		ArrayList val = (ArrayList)flockCenterGrid.get(key);
		if (val == null) {
			flockCenterGrid.put(key, new ArrayList());
		}
		((ArrayList)flockCenterGrid.get(key)).add(i);
	}
}

public ArrayList getNearestNeighbors(int idx, float radius) {
	ArrayList ret = new ArrayList();
	int x = PApplet.parseInt(creatures[idx].posX/radius);
	int y = PApplet.parseInt(creatures[idx].posY/radius);

	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			//this is valid only for reflecting walls
			if (x + i < 0 || y + j < 0 || x + i > 1.0f/radius || y + j > 1.0f/radius) {
				continue;
			}
			ArrayList cellCreatures = (ArrayList)flockCenterGrid.get((x + i) + "," + (y + j));
			if (cellCreatures == null) {
				continue;
			}
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[PApplet.parseInt(cellCreatures.get(k).toString())];
				if (cellCreature.idx == idx) {
					continue;
				}
				float diffX = cellCreature.posX - creatures[idx].posX;
				float diffY = cellCreature.posY - creatures[idx].posY;
				if (diffX * diffX + diffY * diffY <= FLOCK_CENTERING_RADIUS * FLOCK_CENTERING_RADIUS) {
					ret.add(cellCreature.idx);
				}
			}
		}
	}
	return ret;
}

public float distSq(int i, int j) {
	Creature creatureI = creatures[i];
	Creature creatureJ = creatures[j];
	return (creatureI.posX - creatureJ.posX) * (creatureI.posX - creatureJ.posX) + (creatureI.posY - creatureJ.posY) * (creatureI.posY - creatureJ.posY);
}

//DEBUG stuff

public void printGrid(int radius) {
	for (int i = 0; i <= 1.0f/radius; i++) {
		for (int j = 0; j <= 1.0f/radius; j++) {
			ArrayList cellCreatures = (ArrayList)flockCenterGrid.get(i + "," + j);
			if (cellCreatures == null) {
				continue;
			}
			String items = "";
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[PApplet.parseInt(cellCreatures.get(k).toString())];
				items += cellCreature.idx + ", ";
			}
			println("x = " + i + ", y = " + j + ": " + items);
		}
	}
	println("---");
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "murali_varma_hw2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
