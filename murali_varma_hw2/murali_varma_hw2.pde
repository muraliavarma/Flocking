//constants
final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 800;
final int CONTROLS_WIDTH = 100;

final int REFLECT_MODE = 0;
final int TOROIDAL_MODE = 1;

final int CLEAR_SCREEN_EVERY_DRAW_CYCLE = 0;
final int FADE_BACKGROUND_EVERY_DRAW_CYCLE = 1;

final int NUM_CREATURES = 10;

int edgeBehavior = TOROIDAL_MODE;
int backgroundClearingBehavior = FADE_BACKGROUND_EVERY_DRAW_CYCLE;

Creature[] creatures;

void setup() {
	size(SCREEN_WIDTH + CONTROLS_WIDTH, SCREEN_HEIGHT);
	background(0);
	stroke(100);

	initCreatures();
}

void drawBackground() {
	if (backgroundClearingBehavior == FADE_BACKGROUND_EVERY_DRAW_CYCLE) {
		fill(0,10);
		// rectMode(CORNER);
		rect(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
	}
}

void initCreatures() {
	creatures = new Creature[NUM_CREATURES];
	for (int i = 0; i < NUM_CREATURES; i++) {
		creatures[i] = new Creature();
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
			
		}
	}
};
