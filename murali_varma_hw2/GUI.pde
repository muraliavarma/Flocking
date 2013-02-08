void drawGUI() {
	drawText(20, "# Boids: " + NUM_CREATURES);
	drawText(50, "Flock Centering: " + (flockCenteringForce?"on":"off"));
	drawText(70, "Velocity Matching: " + (velocityMatchingForce?"on":"off"));
	drawText(90, "Collisions: " + (collisionAvoidanceForce?"on":"off"));
	drawText(110, "Wandering: " + (wanderingForce?"on":"off"));
	drawText(140, "Trail Length: " + (backgroundAlpha == 0?"Full":(backgroundAlpha == 255?"None":"Half")));
}

void drawText(float y, String text) {
	text(text, SCREEN_WIDTH + 5, y);
}