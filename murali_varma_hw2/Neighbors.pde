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

ArrayList getNearestNeighbors(int idx, float radius) {
	ArrayList ret = new ArrayList();
	int x = int(creatures[idx].posX/radius);
	int y = int(creatures[idx].posY/radius);

	//this is valid only for reflecting walls
	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			if (x + i < 0 || y + j < 0 || x + i >= 1.0/radius || y + j >= 1.0/radius) {
				continue;
			}
			ArrayList cellCreatures = (ArrayList)flockCenterGrid.get((x + i) + "," + (y + j));
			if (cellCreatures == null) {
				continue;
			}
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[int(cellCreatures.get(k).toString())];
				float diffX = cellCreature.posX - creatures[idx].posX;
				float diffY = cellCreature.posY - creatures[idx].posY;
				if (diffX * diffX + diffY * diffY <= FLOCK_CENTERING_RADIUS * FLOCK_CENTERING_RADIUS) {
					ret.add(cellCreature.idx);
				}
			}
		}
	}
	return ret;
}