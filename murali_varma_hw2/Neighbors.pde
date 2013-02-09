HashMap flockCenterGrid;
HashMap collisionAvoidanceGrid;
HashMap velocityMatchingGrid;

void initNeighborGrids() {
	flockCenterGrid = new HashMap();
	collisionAvoidanceGrid = new HashMap();
	velocityMatchingGrid = new HashMap();
}

void computeNeighborGrids() {
	//use active forces and compute separate neighbor grids for each force
	float radius;

	radius = FLOCK_CENTERING_RADIUS;
	flockCenterGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = int(creatures[i].posX/radius) + "," + int(creatures[i].posY/radius);
		ArrayList val = (ArrayList)flockCenterGrid.get(key);
		if (val == null) {
			flockCenterGrid.put(key, new ArrayList());
		}
		((ArrayList)flockCenterGrid.get(key)).add(i);
	}

	radius = COLLISION_AVOIDANCE_RADIUS;
	collisionAvoidanceGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = int(creatures[i].posX/radius) + "," + int(creatures[i].posY/radius);
		ArrayList val = (ArrayList)collisionAvoidanceGrid.get(key);
		if (val == null) {
			collisionAvoidanceGrid.put(key, new ArrayList());
		}
		((ArrayList)collisionAvoidanceGrid.get(key)).add(i);
	}

	radius = VELOCITY_MATCHING_RADIUS;
	velocityMatchingGrid.clear();
	for (int i = 0; i < NUM_CREATURES; i++) {
		String key = int(creatures[i].posX/radius) + "," + int(creatures[i].posY/radius);
		ArrayList val = (ArrayList)velocityMatchingGrid.get(key);
		if (val == null) {
			velocityMatchingGrid.put(key, new ArrayList());
		}
		((ArrayList)velocityMatchingGrid.get(key)).add(i);
	}
}

ArrayList getNearestNeighbors(int idx, float radius, HashMap grid) {
	ArrayList ret = new ArrayList();
	int x = int(creatures[idx].posX/radius);
	int y = int(creatures[idx].posY/radius);

	for (int i = -1; i <= 1; i++) {
		for (int j = -1; j <= 1; j++) {
			int newX = x + i;
			int newY = y + j;
			if (edgeBehavior == REFLECT_MODE) {
				//this is valid only for reflecting walls
				if (newX < 0 || newY < 0 || newX > 1.0/radius || newY > 1.0/radius) {
					continue;
				}
			}
			else {
				if (newX < 0) {
					newX = newX + 1;
				}
				if (newY < 0) {
					newY = newY + 1;
				}
				if (newX > 1.0/radius) {
					newX = int(newX - 1.0/radius);
				}
				if (newY > 1.0/radius) {
					newY = int(newY - 1.0/radius);
				}

			}
			ArrayList cellCreatures = (ArrayList)grid.get(newX + "," + newY);
			if (cellCreatures == null) {
				continue;
			}
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[int(cellCreatures.get(k).toString())];
				if (cellCreature.idx == idx) {
					continue;
				}
				// float diffX = cellCreature.posX - creatures[idx].posX;
				// float diffY = cellCreature.posY - creatures[idx].posY;
				if (cellCreature.distSqTo(idx) <= radius * radius) {
					ret.add(cellCreature.idx);
				}
			}
		}
	}
	return ret;
}

//DEBUG stuff

void printGrid(int radius) {
	for (int i = 0; i <= 1.0/radius; i++) {
		for (int j = 0; j <= 1.0/radius; j++) {
			ArrayList cellCreatures = (ArrayList)flockCenterGrid.get(i + "," + j);
			if (cellCreatures == null) {
				continue;
			}
			String items = "";
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[int(cellCreatures.get(k).toString())];
				items += cellCreature.idx + ", ";
			}
			println("x = " + i + ", y = " + j + ": " + items);
		}
	}
	println("---");
}
