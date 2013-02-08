void keyPressed() {
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
			", Collisions: " + (velocityMatchingForce?"on":"off") +
			", Velocity matching: " + (collisionAvoidanceForce?"on":"off") +
			", Wandering: " + (wanderingForce?"on":"off"));
	}
}
