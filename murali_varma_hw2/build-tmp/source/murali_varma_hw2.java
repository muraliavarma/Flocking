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

final int ATTRACT_MODE = 0;
final int REPEL_MODE = 1;

final int MIN_CREATURES = 1;
final int MAX_CREATURES = 100;

final float EPSILON = 0.00001f;
final float COLLISION_EPSILON = 0.001f;
final float MOUSE_EPSILON = 0.001f;

final float FLOCK_CENTERING_RADIUS = 0.3f;
final float COLLISION_AVOIDANCE_RADIUS = 0.05f;
final float VELOCITY_MATCHING_RADIUS = 0.1f;
final float MOUSE_RADIUS = 0.3f;

final float FLOCKING_CENTERING_WEIGHT = 0.00015f;
float COLLISION_AVOIDANCE_WEIGHT = 0.0035f;
final float VELOCITY_MATCHING_WEIGHT = 0.1f;
final float WANDERING_WEIGHT = 0.0001f;
final float MOUSE_WEIGHT = 0.0001f;

final float MIN_VELOCITY = -0.001f;
final float MAX_VELOCITY = 0.001f;

int NUM_CREATURES = 100;

boolean isLoop = true;
int edgeBehavior = TOROIDAL_MODE;
int mouseMode = ATTRACT_MODE;
int backgroundAlpha = 10;	//0 for full trail, 255 for no trail

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
	creatures = new Creature[MAX_CREATURES];
	for (int i = 0; i < MAX_CREATURES; i++) {
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

public void clearBackground() {
	int temp = backgroundAlpha;
	backgroundAlpha = 255;
	draw();
	backgroundAlpha = temp;
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

	ArrayList neighborsFC;
	ArrayList neighborsCA;
	ArrayList neighborsVM;

	Creature(int i) {
		idx = i;
		init();
	}

	public void init() {
		posX = random(1);
		posY = random(1);
		velX = 10 * WANDERING_WEIGHT * (1 - random(2));
		velY = 10 * WANDERING_WEIGHT * (1 - random(2));

		neighborsFC = new ArrayList();
		neighborsCA = new ArrayList();		
	}

	public void draw() {
		fill (255);
		// arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
		float s = 10;	//radius of the circuscribing circle of this isosceles triangle
		pushMatrix();
		translate(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY);
		rotate(PI/2 + atan2(velY, velX));
		triangle(0, -s, -s * 0.707f, s * 0.707f, s * 0.707f, s * 0.707f);
		translate(-SCREEN_WIDTH * posX, -SCREEN_HEIGHT * posY);
		popMatrix();
	}

	public void update() {
		neighborsFC = getNeighbors(FLOCK_CENTERING_RADIUS, flockCenterGrid);
		neighborsCA = getNeighbors(COLLISION_AVOIDANCE_RADIUS, collisionAvoidanceGrid);
		neighborsVM = getNeighbors(VELOCITY_MATCHING_RADIUS, velocityMatchingGrid);
		applyForces();
		velX += forceX;
		velY += forceY;

		//clamp velocities
		velX = max(MIN_VELOCITY, min(velX, MAX_VELOCITY));
		velY = max(MIN_VELOCITY, min(velY, MAX_VELOCITY));

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

	public float distSqTo(int j) {
		Creature other = creatures[j];
		return distSqTo(other.posX, other.posY);
	}

	public float distSqTo(float x, float y) {
		float diffX = abs(posX - x);
		if (edgeBehavior == TOROIDAL_MODE) {
			diffX = min(diffX, 1 - diffX);
		}
		float diffY = abs(posY - y);
		if (edgeBehavior == TOROIDAL_MODE) {
			diffY = min(diffY, 1 - diffY);
		}

		return diffX * diffX + diffY * diffY;		
	}

	public void applyForces() {
		forceX = 0;
		forceY = 0;

		//apply the 4 forces to the creature and update its x and y velocities

		if (mousePressed) {
			COLLISION_AVOIDANCE_WEIGHT = 0.01f;
		}
		else {
			COLLISION_AVOIDANCE_WEIGHT = 0.0035f;
		}
		if (wanderingForce) {
			forceX = WANDERING_WEIGHT * (1 - random(2));
			forceY = WANDERING_WEIGHT * (1 - random(2));
		}

		if (flockCenteringForce) {
			float weightSum = 0;
			float fx = 0;
			float fy = 0;
			for (int i = 0; i < neighborsFC.size(); i++) {
				Creature neighbor = creatures[PApplet.parseInt(neighborsFC.get(i).toString())];
				float weight = 1/(sqrt(distSqTo(neighbor.idx)) + EPSILON);
				weightSum += weight;
				fx += weight * (neighbor.posX - posX);
				fy += weight * (neighbor.posY - posY);
			}
			weightSum /= FLOCKING_CENTERING_WEIGHT;
			if (weightSum != 0) {
				forceX += fx/weightSum;
				forceY += fy/weightSum;
			}
		}

		if (collisionAvoidanceForce) {
			float weightSum = 0;
			float fx = 0;
			float fy = 0;
			for (int i = 0; i < neighborsCA.size(); i++) {
				Creature neighbor = creatures[PApplet.parseInt(neighborsCA.get(i).toString())];
				float weight = 1/(sqrt(distSqTo(neighbor.idx)) + COLLISION_EPSILON);
				weightSum += weight;
				fx += weight * (posX - neighbor.posX);
				fy += weight * (posY - neighbor.posY);
			}
			weightSum /= COLLISION_AVOIDANCE_WEIGHT;
			if (weightSum != 0) {
				forceX += fx/weightSum;
				forceY += fy/weightSum;
			}
		}

		if (velocityMatchingForce) {
			float weightSum = 0;
			float fx = 0;
			float fy = 0;
			for (int i = 0; i < neighborsVM.size(); i++) {
				Creature neighbor = creatures[PApplet.parseInt(neighborsVM.get(i).toString())];
				float weight = 1;
				weightSum += weight;
				fx += weight * (neighbor.velX - velX);
				fy += weight * (neighbor.velY - velY);
			}
			weightSum /= VELOCITY_MATCHING_WEIGHT;
			if (weightSum != 0) {
				forceX += fx/weightSum;
				forceY += fy/weightSum;
			}
		}

		if (mousePressed) {
			float x = (1.0f * mouseX)/SCREEN_WIDTH;
			float y = (1.0f * mouseY)/SCREEN_HEIGHT;
			int sign = mouseMode == ATTRACT_MODE ? -1 : 1;
			float distSq = distSqTo(x, y);
			if (distSq < MOUSE_RADIUS * MOUSE_RADIUS) {
				float weight = min(1/(sqrt(distSq) + MOUSE_EPSILON), 20);
				forceX += sign * MOUSE_WEIGHT * (posX - x) * weight;
				forceY += sign * MOUSE_WEIGHT * (posY - y) * weight;
			}
		}
	}

	public ArrayList getNeighbors(float radius, HashMap grid) {
		return getNearestNeighbors(idx, radius, grid);
	}
};

public void keyPressed() {
	//simulation
	if (key == ' ') {
		isLoop = !isLoop;
	}

	if (isLoop) {
		loop();
	}
	
	if(key == '.' || !isLoop) {
		noLoop();
		redraw();
		isLoop = false;
	}

	//commands
	if (key == 's' || key == 'S') {
		clearBackground();
		for (int i = 0; i < NUM_CREATURES; i++) {
			creatures[i].init();
		}
	}

	if (key == 'p' || key == 'P') {
		if (backgroundAlpha == 255) {
			//if no trail, make it full trail
			backgroundAlpha = 0;
		}
		else {
			//if some trail (between 1 and 254), make it no trail
			backgroundAlpha = 255;
		}
	}

	if (key == 'c' || key == 'C') {
		clearBackground();
	}

	if (key == '=' || key == '+') {
		NUM_CREATURES = min(NUM_CREATURES+1, MAX_CREATURES);
		//reinit this newly added creature
		creatures[NUM_CREATURES-1].init();
	}
	if (key == '-' || key == '_') {
		NUM_CREATURES = max(NUM_CREATURES-1, MIN_CREATURES);
	}

	if (key == 'a' || key == 'A') {
		mouseMode = ATTRACT_MODE;
	}
	if (key == 'r' || key == 'R') {
		mouseMode = REPEL_MODE;
	}

	//forces
	if (key == '1') {
		flockCenteringForce = !flockCenteringForce;
	}
	if (key == '2') {
		velocityMatchingForce = !velocityMatchingForce;
	}
	if (key == '3') {
		collisionAvoidanceForce = !collisionAvoidanceForce;
	}
	if (key == '4') {
		wanderingForce = !wanderingForce;
	}

	if (key >= '1' && key <= '4') {
		println("Centering: " + (flockCenteringForce?"on":"off") +
			", Velocity matching: " + (velocityMatchingForce?"on":"off") +
			", Collisions: " + (collisionAvoidanceForce?"on":"off") +
			", Wandering: " + (wanderingForce?"on":"off"));
	}
}
HashMap flockCenterGrid;
HashMap collisionAvoidanceGrid;
HashMap velocityMatchingGrid;

public void initNeighborGrids() {
	flockCenterGrid = new HashMap();
	collisionAvoidanceGrid = new HashMap();
	velocityMatchingGrid = new HashMap();
}

public void computeNeighborGrids() {
	//use active forces and compute separate neighbor grids for each force
	float radius;

	radius = FLOCK_CENTERING_RADIUS;
	flockCenterGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = PApplet.parseInt(creatures[i].posX/radius) + "," + PApplet.parseInt(creatures[i].posY/radius);
		ArrayList val = (ArrayList)flockCenterGrid.get(key);
		if (val == null) {
			flockCenterGrid.put(key, new ArrayList());
		}
		((ArrayList)flockCenterGrid.get(key)).add(i);
	}

	radius = COLLISION_AVOIDANCE_RADIUS;
	collisionAvoidanceGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = PApplet.parseInt(creatures[i].posX/radius) + "," + PApplet.parseInt(creatures[i].posY/radius);
		ArrayList val = (ArrayList)collisionAvoidanceGrid.get(key);
		if (val == null) {
			collisionAvoidanceGrid.put(key, new ArrayList());
		}
		((ArrayList)collisionAvoidanceGrid.get(key)).add(i);
	}

	radius = VELOCITY_MATCHING_RADIUS;
	velocityMatchingGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = PApplet.parseInt(creatures[i].posX/radius) + "," + PApplet.parseInt(creatures[i].posY/radius);
		ArrayList val = (ArrayList)velocityMatchingGrid.get(key);
		if (val == null) {
			velocityMatchingGrid.put(key, new ArrayList());
		}
		((ArrayList)velocityMatchingGrid.get(key)).add(i);
	}
}

public ArrayList getNearestNeighbors(int idx, float radius, HashMap grid) {
	ArrayList ret = new ArrayList();
	int x = PApplet.parseInt(creatures[idx].posX/radius);
	int y = PApplet.parseInt(creatures[idx].posY/radius);

	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			//this is valid only for reflecting walls
			if (x + i < 0 || y + j < 0 || x + i > 1.0f/radius || y + j > 1.0f/radius) {
				continue;
			}
			ArrayList cellCreatures = (ArrayList)grid.get((x + i) + "," + (y + j));
			if (cellCreatures == null) {
				continue;
			}
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[PApplet.parseInt(cellCreatures.get(k).toString())];
				if (cellCreature.idx == idx) {
					continue;
				}
				// float diffX = cellCreature.posX - creatures[idx].posX;
				// float diffY = cellCreature.posY - creatures[idx].posY;
				if (cellCreature.distSqTo(idx) <= radius * radius) {
					ret.add(cellCreature.idx);
				}
			}
		}
	}
	return ret;
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
