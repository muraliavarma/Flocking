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

	void init() {
		posX = random(1);
		posY = random(1);
		velX = 10 * WANDERING_WEIGHT * (1 - random(2));
		velY = 10 * WANDERING_WEIGHT * (1 - random(2));

		neighborsFC = new ArrayList();
		neighborsCA = new ArrayList();		
	}

	void draw() {
		fill (255);
		// arc(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY, radius, radius, 0, 2 * PI);
		float s = 10;	//radius of the circuscribing circle of this isosceles triangle
		pushMatrix();
		translate(SCREEN_WIDTH * posX, SCREEN_HEIGHT * posY);
		rotate(PI/2 + atan2(velY, velX));
		triangle(0, -s, -s * 0.707, s * 0.707, s * 0.707, s * 0.707);
		translate(-SCREEN_WIDTH * posX, -SCREEN_HEIGHT * posY);
		popMatrix();
	}

	void update() {
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

	float distSqTo(int j) {
		Creature other = creatures[j];
		return distSqTo(other.posX, other.posY);
	}

	float distSqTo(float x, float y) {
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

	void applyForces() {
		forceX = 0;
		forceY = 0;

		//apply the 4 forces to the creature and update its x and y velocities

		if (mousePressed) {
			//so that particles do not cluster too much during mouse press attraction
			COLLISION_AVOIDANCE_WEIGHT = 0.01;
		}
		else {
			COLLISION_AVOIDANCE_WEIGHT = 0.0035;
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
				Creature neighbor = creatures[int(neighborsFC.get(i).toString())];
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
				Creature neighbor = creatures[int(neighborsCA.get(i).toString())];
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
				Creature neighbor = creatures[int(neighborsVM.get(i).toString())];
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
			float x = (1.0 * mouseX)/SCREEN_WIDTH;
			float y = (1.0 * mouseY)/SCREEN_HEIGHT;
			int sign = mouseMode == ATTRACT_MODE ? -1 : 1;
			float distSq = distSqTo(x, y);
			if (distSq < MOUSE_RADIUS * MOUSE_RADIUS) {
				float weight = min(1/(sqrt(distSq) + MOUSE_EPSILON), 20);
				forceX += sign * MOUSE_WEIGHT * (posX - x) * weight;
				forceY += sign * MOUSE_WEIGHT * (posY - y) * weight;
			}
		}
	}

	ArrayList getNeighbors(float radius, HashMap grid) {
		return getNearestNeighbors(idx, radius, grid);
	}
};
