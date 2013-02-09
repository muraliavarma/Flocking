void drawGUI() {
	drawText(20, "(+/-) # Boids: " + NUM_CREATURES);
	drawText(50, "(1) Flock Centering: " + (flockCenteringForce?"on":"off"));
	drawText(70, "(2) Velocity Matching: " + (velocityMatchingForce?"on":"off"));
	drawText(90, "(3) Collisions: " + (collisionAvoidanceForce?"on":"off"));
	drawText(110, "(4) Wandering: " + (wanderingForce?"on":"off"));
	drawText(140, "(p) Trail Length: " + (backgroundAlpha == 0?"Full":(backgroundAlpha == 255?"None":"Half")));
	drawText(160, "(a/r) Mouse mode: " + (mouseMode == ATTRACT_MODE?"Attraction":"Repulsion"));
	// drawText(200, "(e) Edge Behavior: " + (edgeBehavior == TOROIDAL_MODE?"Toroidal":"Reflect"));
	drawText(190, "(b) Boid Shape: " + (boidShape == CIRCLE_BOID?"Circle":"Triangle"));
	drawText(230, "(c) Clear paths");
	drawText(250, "(s) Scatter boids");
	drawText(300, "(Space) Simulation is " + (isLoop?"playing":"paused"));
	if (!isLoop) {
		drawText(320, "(.) Go to next timestep");
	}
}

void drawText(float y, String text) {
	text(text, SCREEN_WIDTH + 5, y);
}