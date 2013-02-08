void keyPressed() {
	//simulation
	if (key == ' ') {
		isLoop = !isLoop;
		draw();
	}

	if (isLoop) {
		loop();
	}
	else {
		noLoop();
	}
	
	if(key == '.' && !isLoop) {
		redraw();
	}

	//commands
	if (key == 's' || key == 'S') {
		clearBackground();
		for (int i = 0; i < NUM_CREATURES; i++) {
			creatures[i].init();
		}
	}

	if (key == 'p' || key == 'P') {
		if (backgroundAlpha == 10) {
			//if half trail, make it no trail
			backgroundAlpha = 255;
		}
		else if (backgroundAlpha == 255) {
			//if no trail, make it full trail
			backgroundAlpha = 0;
		}
		else {
			//if full trail (between 1 and 254), make it half trail
			backgroundAlpha = 10;
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

	if (key == 'e') {
		if (edgeBehavior == TOROIDAL_MODE) {
			edgeBehavior = REFLECT_MODE;
		}
		else {
			edgeBehavior = TOROIDAL_MODE;
		}
	}

	if (key == 'b') {
		if (boidShape == TRIANGLE_BOID) {
			boidShape = CIRCLE_BOID;
		}
		else {
			boidShape = TRIANGLE_BOID;
		}
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
		println("Flock Centering: " + (flockCenteringForce?"on":"off") +
			", Velocity matching: " + (velocityMatchingForce?"on":"off") +
			", Collisions: " + (collisionAvoidanceForce?"on":"off") +
			", Wandering: " + (wanderingForce?"on":"off"));
	}
}

void mousePressed() {
	
}