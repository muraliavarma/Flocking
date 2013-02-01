final float FLOCK_CENTERING_RADIUS = 0.2;

HashMap flockCenterGrid;

void initNeighborGrids() {
	flockCenterGrid = new HashMap();
}

void computeNeighborGrids() {
	//use active forces and compute separate neighbor grids for each force
	float radius = FLOCK_CENTERING_RADIUS;
	flockCenterGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = int(creatures[i].posX/radius) + "," + int(creatures[i].posY/radius);
		ArrayList val = (ArrayList)flockCenterGrid.get(key);
		if (val != null) {
			val.add(i);
		}
		else {
			flockCenterGrid.put(key, new ArrayList());
		}
	}

}