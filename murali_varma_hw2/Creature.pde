Creature[] creatures;

class Creature {
	int idx;

	float posX;
	float posY;

	float velX;
	float velY;

	float radius = 10;

	ArrayList neighbors;

	Creature(int i) {
		idx = i;
		posX = random(1);
		posY = random(1);
		velX = 0.001 - random(0.002);
		velY = 0.001 - random(0.002);

		neighbors = new ArrayList();
	}

	void draw() {
		if (idx == 0) {
			println (neighbors);
			arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, FLOCK_CENTERING_RADIUS * SCREEN_WIDTH, FLOCK_CENTERING_RADIUS * SCREEN_HEIGHT, 0, 2 * PI);
		}
		if (idx == 0) {
			fill (100, 0, 0);
		}
		else if (neighbors.contains(0)) {
			fill (0, 100, 0);
		}
		else {
			fill (255);
		}
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}

	void update() {
		neighbors = getNeighbors(FLOCK_CENTERING_RADIUS);
		applyForces();
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

	void applyForces() {
		//apply the 3 forces to the creature and update its x and y velocities

	}

	ArrayList getNeighbors(float radius) {
		return getNearestNeighbors(idx, radius);
	}
};
