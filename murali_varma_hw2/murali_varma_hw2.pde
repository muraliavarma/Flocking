
int SCREEN_WIDTH = 800;
int SCREEN_HEIGHT = 800;
int NUM_CREATURES = 10;

Creature[] creatures;

void setup() {
	size(SCREEN_WIDTH, SCREEN_HEIGHT);
	background(0);
	stroke(100);

	initCreatures();
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

void draw() {
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
	}

	void draw() {
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}
};
