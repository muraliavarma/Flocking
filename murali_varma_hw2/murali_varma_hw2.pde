//constants
final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 800;
final int CONTROLS_WIDTH = 100;

final int NUM_CREATURES = 10;
final int REFLECT_MODE = 0;
final int TOROIDAL_MODE = 1;

Creature[] creatures;
int edge_behavior = TOROIDAL_MODE;

void setup() {
	size(SCREEN_WIDTH + CONTROLS_WIDTH, SCREEN_HEIGHT);
	fadeBackground();
	stroke(100);

	initCreatures();
}

void fadeBackground() {
	
}

void initCreatures() {
	creatures = new Creature[NUM_CREATURES];
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i] = new Creature();
	}
}

void drawCreatures() {
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
	background(100, 0.1);
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
		velX = 0.01 - random(0.02);
		velY = 0.01 - random(0.02);
	}

	void draw() {
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}

	void update() {
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
