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

	void draw() {
		fill (255);
		arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
	}

	void update() {
		neighbors = getNeighbors(FLOCK_CENTERING_RADIUS);
		applyForces();
		velX += forceX;
		velY += forceY;
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
		forceX = 0;
		forceY = 0;

		//apply the 4 forces to the creature and update its x and y velocities
		if (wanderingForce) {
			forceX = 0.0002 - random(0.0004);
			forceY = 0.0002 - random(0.0004);
		}
	}

	ArrayList getNeighbors(float radius) {
		return getNearestNeighbors(idx, radius);
	}
};
