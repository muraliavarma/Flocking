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
			//this is valid only for reflecting walls
			if (x + i < 0 || y + j < 0 || x + i > 1.0/radius || y + j > 1.0/radius) {
				continue;
			}
			ArrayList cellCreatures = (ArrayList)grid.get((x + i) + "," + (y + j));
			if (cellCreatures == null) {
				continue;
			}
			for (int k = 0; k < cellCreatures.size(); k++) {
				Creature cellCreature = creatures[int(cellCreatures.get(k).toString())];
				if (cellCreature.idx == idx) {
					continue;
				}
				float diffX = cellCreature.posX - creatures[idx].posX;
				float diffY = cellCreature.posY - creatures[idx].posY;
				if (diffX * diffX + diffY * diffY <= radius * radius) {
					ret.add(cellCreature.idx);
				}
			}
		}
	}
	return ret;
}

float distSq(int i, int j) {
	Creature creatureI = creatures[i];
	Creature creatureJ = creatures[j];
	return (creatureI.posX - creatureJ.posX) * (creatureI.posX - creatureJ.posX) + (creatureI.posY - creatureJ.posY) * (creatureI.posY - creatureJ.posY);
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