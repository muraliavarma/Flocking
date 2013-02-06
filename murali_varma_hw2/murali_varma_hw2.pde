//constants
final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 800;
final int CONTROLS_WIDTH = 100;

final int REFLECT_MODE = 0;
final int TOROIDAL_MODE = 1;

final int NUM_CREATURES = 100;

final float EPSILON = 0.01;

final float FLOCK_CENTERING_RADIUS = 0.1;
final float COLLISION_AVOIDANCE_RADIUS = 0.05;
final float VELOCITY_MATCHING_RADIUS = 0.1;

final float FLOCKING_CENTERING_WEIGHT = 0.0001;
final float COLLISION_AVOIDANCE_WEIGHT = 0.001;
final float VELOCITY_MATCHING_WEIGHT = 0.1;
final float WANDERING_WEIGHT = 0.0002;

int edgeBehavior = TOROIDAL_MODE;
int backgroundAlpha = 10;	//0 for full trail, 255 for no trail

//flock centering, velocity matching, collision avoidance, wandering force
boolean flockCenteringForce = true;
boolean velocityMatchingForce = true;
boolean collisionAvoidanceForce = true;
boolean wanderingForce = true;

void setup() {
	size(SCREEN_WIDTH + CONTROLS_WIDTH, SCREEN_HEIGHT);
	background(0);
	stroke(100);

	initNeighborGrids();
	initCreatures();
}

void drawBackground() {
	fill(0,backgroundAlpha);
	rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
	fill(0);	//draw controls without any alpha value so that ball trails will not be drawn in the control area
	rect(SCREEN_WIDTH,0,CONTROLS_WIDTH,SCREEN_HEIGHT);
}

void initCreatures() {
	creatures = new Creature[NUM_CREATURES];
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i] = new Creature(i);
	}
}

void drawCreatures() {
	fill(255);
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i].draw();
	}
}

void updateCreatures() {
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i].update();
	}
}

void draw() {
	drawBackground();
	computeNeighborGrids();
	updateCreatures();
	drawCreatures();
}

void clearBackground() {
	int temp = backgroundAlpha;
	backgroundAlpha = 255;
	draw();
	backgroundAlpha = temp;
}

void keyPressed() {
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
}