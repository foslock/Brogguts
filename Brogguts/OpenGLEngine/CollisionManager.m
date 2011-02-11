//
//  CollisionManager.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollisionManager.h"
#import "CollidableObject.h"

@implementation CollisionManager

- (void)dealloc {
	if (cellHashTable) {
		for (int i = 0; i < numberOfRows * numberOfColumns; i++) {
			ObjectIDArray* array = &(cellHashTable[i]);
			if (array->objectIDArray) {
				free(array->objectIDArray);
			}
		}
		free(cellHashTable);
	}
	if (gridVertexArray)
		free(gridVertexArray);
	
	// free broggut array
	if (broggutArray) {
		free(broggutArray->array);
		free(broggutArray);
	}
	
	[bufferNearbyObjects release];
	[objectTable release];
	[super dealloc];
}

- (id)initWithContainingRect:(CGRect)bounds WithCellWidth:(float)width withHeight:(float)height {
#ifndef COLLISIONS
	return nil;
#endif
	self = [super init];
	if (self) {
		fullMapBounds = bounds;
		cellWidth = width;
		cellHeight = height;
		numberOfColumns = ceil(bounds.size.width / width);
		numberOfRows = ceil(bounds.size.height / height);
		int totalCellCount = numberOfRows * numberOfColumns;
		cellHashTable = malloc( totalCellCount * sizeof(*cellHashTable) );
		for (int i = 0; i < totalCellCount; i++) {
			ObjectIDArray* tempObjectArray = &(cellHashTable[i]);
			tempObjectArray->objectIDArray = malloc(INITIAL_HASH_CAPACITY * sizeof(int));
			tempObjectArray->arrayCount = 0; // Set the initial count
			tempObjectArray->arrayCapacity = INITIAL_HASH_CAPACITY; // Set the initial capacity
		}
		objectTable = [[NSMutableDictionary alloc] initWithCapacity:100];
		bufferNearbyObjects = [[NSMutableArray alloc] initWithCapacity:100];
#ifdef BROGGUTS
		broggutArray = malloc( sizeof(*broggutArray) );
		int countWide = ceilf(bounds.size.width / MEDIUM_BROGGUT_SIDE_LENGTH);
		int countHigh = ceilf(bounds.size.height / MEDIUM_BROGGUT_SIDE_LENGTH);
		broggutArray->bWidth = countWide;
		broggutArray->bHeight = countHigh;
		broggutArray->array = malloc( countWide * countHigh * sizeof(*(broggutArray->array)) );
		for (int i = 0; i < countWide * countHigh; i++) {
			MediumBroggut* broggut = &broggutArray->array[i];
			broggut->broggutID = i;
			broggut->broggutValue = -1;
		}
#endif
#ifdef GRID
		// Fill the vertex array for the grid
		gridVertexArray = calloc( 4 * (numberOfColumns + numberOfRows + 2), sizeof(*gridVertexArray) );
		currentGridScale = 1.0f;
		[self remakeGridVertexArrayWithScale:currentGridScale];
#endif
	}
	return self;
}

// Broggut array methods

- (MediumBroggut*)broggutForLocation:(CGPoint)location {
	int xIndex = CLAMP(floorf(location.x / MEDIUM_BROGGUT_SIDE_LENGTH), 0, broggutArray->bWidth - 1);
	int yIndex = CLAMP(floorf(location.y / MEDIUM_BROGGUT_SIDE_LENGTH), 0, broggutArray->bHeight - 1);
	int indexOfLocation = xIndex + (yIndex * broggutArray->bWidth);
	
	MediumBroggut* broggut = &broggutArray->array[indexOfLocation];
	return broggut;
}

- (int)getBroggutIDatLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutForLocation:location];
	return broggut->broggutID;
}

- (BOOL)isLocationOccupiedByBroggut:(CGPoint)location {
	MediumBroggut* broggut = [self broggutForLocation:location];
	if (broggut->broggutValue != -1) {
		return YES;
	}
	return NO;
}

- (int)getBroggutValueAtLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutForLocation:location];
	return broggut->broggutValue;
}

- (int)getBroggutValueWithID:(int)brogID {
	if (brogID >= (broggutArray->bWidth * broggutArray->bHeight)) {
		NSLog(@"Invalid BROGGUT ID");
		return -1;
	}
	MediumBroggut* broggut = &broggutArray->array[brogID];
	return broggut->broggutValue;
}

- (void)setBroggutValue:(int)newValue withID:(int)brogID {
	if (brogID >= (broggutArray->bWidth * broggutArray->bHeight)) {
		NSLog(@"Invalid BROGGUT ID");
		return;
	}
	MediumBroggut* broggut = &broggutArray->array[brogID];
	broggut->broggutValue = newValue;
}

- (void)remakeGridVertexArrayWithScale:(float)scale {
#ifdef GRID
	int i = 0;
	// This inserts the vertical lines into first half of the vertex array
	for (i = 0; i < numberOfColumns + 1; i++) { // Columns index
		if (i == 0) {
			continue;
		}
		int currentIndex = i * 4;
		gridVertexArray[currentIndex] = i * cellWidth * scale;					// X1
		gridVertexArray[currentIndex+1] = fullMapBounds.origin.y * scale;		// Y1
		gridVertexArray[currentIndex+2] = i * cellWidth * scale;				// X2
		gridVertexArray[currentIndex+3] = fullMapBounds.size.height * scale;	// Y2
	}
	
	// This inserts the horizontal lines into second half of the vertex array
	for (int j = 0; j < numberOfRows + 1; j++) { // Rows index
		if (j == 0) {
			continue;
		}
		int currentIndex = (i * 4) + (j * 4);
		gridVertexArray[currentIndex] = fullMapBounds.origin.x * scale;		// X1
		gridVertexArray[currentIndex+1] = j * cellHeight * scale;			// Y1
		gridVertexArray[currentIndex+2] = fullMapBounds.size.width * scale;	// X2
		gridVertexArray[currentIndex+3] = j * cellHeight * scale;			// Y2
	}
#endif
}

- (void)addCollidableObject:(CollidableObject*)object {
	int UID = object.uniqueObjectID;
	object.isCheckedForCollisions = YES;
	
	if ([objectTable objectForKey:[NSNumber numberWithInt:UID]] != nil) {
		NSLog(@"ERROR - Duplicate ObjectID in Collision Manager");
		return; //Already added this object
	} else {
		[objectTable setObject:object forKey:[NSNumber numberWithInt:UID]];
	}
	
	// Index of the object's location in the hash table
	int indexOfLocation = [self getIndexForLocation:object.objectLocation];
	
	ObjectIDArray* tempObjectArray = &(cellHashTable[indexOfLocation]);
	int currentArrayCount = tempObjectArray->arrayCount;
	int currentArrayCapacity = tempObjectArray->arrayCapacity;
	
	if (currentArrayCount < currentArrayCapacity) { // Making sure the count is less than the capacity
													// Array already exists, add to it
		tempObjectArray->objectIDArray[currentArrayCount] = UID;
		tempObjectArray->arrayCount += 1;
	} else {
		// RESIZE THE ARRAY
		NSLog(@"Resizing index: %i, from %i to %i", indexOfLocation, currentArrayCapacity, (currentArrayCapacity + INITIAL_HASH_CAPACITY));
		tempObjectArray->objectIDArray = realloc(tempObjectArray->objectIDArray,
												 (currentArrayCapacity + INITIAL_HASH_CAPACITY) * sizeof(int) );
		tempObjectArray->arrayCapacity = (currentArrayCapacity + INITIAL_HASH_CAPACITY);
	}
}

// Only used internally with objects that have been added to the dictionary
- (void)addCollidableObjectWithID:(int)objectID {
	CollidableObject* currentObject = [objectTable objectForKey:[NSNumber numberWithInt:objectID]];
	if (!currentObject) {
		NSLog(@"ERROR - The objectID does not exist in the table");
		return; // Object with that ID does not exist in the table
	}
	// Index of the object's location in the hash table
	int indexOfLocation = [self getIndexForLocation:currentObject.objectLocation];
	
	ObjectIDArray* tempObjectArray = &(cellHashTable[indexOfLocation]);
	int currentArrayCount = tempObjectArray->arrayCount;
	int currentArrayCapacity = tempObjectArray->arrayCapacity;
	
	if (currentArrayCount < currentArrayCapacity) { // Making sure the count is less than the capacity
													// Array already exists, add to it
		tempObjectArray->objectIDArray[currentArrayCount] = objectID;
		tempObjectArray->arrayCount += 1;
	} else {
		// RESIZE THE ARRAY
		NSLog(@"Resizing index: %i, from %i to %i", indexOfLocation, currentArrayCapacity, (currentArrayCapacity + INITIAL_HASH_CAPACITY));
		tempObjectArray->objectIDArray = realloc(tempObjectArray->objectIDArray,
												 (currentArrayCapacity + INITIAL_HASH_CAPACITY) * sizeof(int) );
		tempObjectArray->arrayCapacity = (currentArrayCapacity + INITIAL_HASH_CAPACITY);
	}
}

- (void)removeCollidableObject:(CollidableObject*)object {
	int UID = object.uniqueObjectID;
	
	if (![objectTable objectForKey:[NSNumber numberWithInt:UID]]) {
		NSLog(@"ERROR - The objectID you're trying to remove does not exist in the table");
		return; // Already removed this object, or wasn't added
	} else {
		[objectTable removeObjectForKey:[NSNumber numberWithInt:UID]];
	}
	
}

- (void)putNearbyObjectsToID:(int)objectID intoArray:(NSMutableArray*)array {
	CollidableObject* currentObject = [objectTable objectForKey:[NSNumber numberWithInt:objectID]];
	[self putNearbyObjectsToLocation:currentObject.objectLocation intoArray:array];
}

- (void)putNearbyObjectsToLocation:(CGPoint)location intoArray:(NSMutableArray*)nearbyObjectArray {
	for (int cell = 0; cell < 9; cell++) { // Goes through every adjacent cell as well as the containing
		CGPoint cellLocation;
		if (cell / 3 == 0) { // Bottom row
			cellLocation = CGPointMake(location.x + (cellWidth * (cell - 1)), location.y - cellHeight);
		}
		if (cell / 3 == 1) { // Middle row
			cellLocation = CGPointMake(location.x + (cellWidth * (cell - 4)), location.y);
		}
		if (cell / 3 == 2) { // Top row
			cellLocation = CGPointMake(location.x + (cellWidth * (cell - 7)), location.y + cellHeight);
		}
		
		// Check to make sure none of the points are negative
		if (cellLocation.x < 0.0f || cellLocation.y < 0.0f) {
			continue;
		}
		
		int index = [self getIndexForLocation:cellLocation];
		ObjectIDArray* nearbyObjects = &(cellHashTable[index]); // Get the array with all nearby objects
		int count = nearbyObjects->arrayCount;
		// CONVERT INTO NSARRAY
		for (int i = 0; i < count; i++) {
			int currentID = nearbyObjects->objectIDArray[i]; // Get the current objectIndexID
			CollidableObject* obj = [objectTable objectForKey:[NSNumber numberWithInt:currentID]];
			if (obj)
				[nearbyObjectArray addObject:obj];
		}
	}
}

- (void)updateAllObjectsInTableInScreenBounds:(CGRect)bounds {
	// Keep the dictionary, but set all hash table counts to 0
	
	for (int i = 0; i < numberOfColumns * numberOfRows; i++) {
		ObjectIDArray* nearbyObjects = &(cellHashTable[i]);
		nearbyObjects->arrayCount = 0;
	}
	
	NSEnumerator *enumerator = [objectTable objectEnumerator];
	CollidableObject* currentObject;
	
	while ((currentObject = [enumerator nextObject])) {
		if (!CGRectContainsPoint(bounds, currentObject.objectLocation))
			continue;
		// This function is used for updating, not adding new objects
		[self addCollidableObjectWithID:currentObject.uniqueObjectID];
	}
}

- (void)processAllCollisionsWithScreenBounds:(CGRect)bounds {
	if (CHECK_ONLY_OBJECTS_ONSCREEN) {
		// Only check collisions with objects that are currently in the passed CGRect
		CGPoint currentCellLocation;
		float screenWidth = bounds.size.width;
		float screenHeight = bounds.size.height;
		int screenCellsTall = ceil(screenHeight / cellHeight);
		int screenCellsWide = ceil(screenWidth / cellWidth);
		for (int i = 0; i < screenCellsTall; i++) {
			for (int j = 0; j < screenCellsWide; j++) {
				[bufferNearbyObjects removeAllObjects];
				currentCellLocation = CGPointMake(bounds.origin.x + (j * cellWidth),
												  bounds.origin.y + (i * cellHeight));
				[self putNearbyObjectsToLocation:currentCellLocation intoArray:bufferNearbyObjects];
				for (int k = 0; k < [bufferNearbyObjects count]; k++) {
					CollidableObject* obj1 = [bufferNearbyObjects objectAtIndex:k];
					for (int l = k + 1; l < [bufferNearbyObjects count]; l++) {
						CollidableObject* obj2 = [bufferNearbyObjects objectAtIndex:l];
						if (obj1 == obj2) {
							continue;
						}
						if (CircleIntersectsCircle(obj1.boundingCircle, obj2.boundingCircle)) {
							[obj1 collidedWithOtherObject:obj2];
							[obj2 collidedWithOtherObject:obj1];
						}
					}
				}
			}
		}
	} else {
		// Go through the "cellHashTable" and check for collisions between objects that share a cell (and bordering cells)
		[bufferNearbyObjects removeAllObjects];
		NSEnumerator *enumerator = [objectTable objectEnumerator];
		CollidableObject* currentObject;
		while ((currentObject = [enumerator nextObject])) {
			// Check collisions for objects near the currentObject
			[self putNearbyObjectsToID:currentObject.uniqueObjectID intoArray:bufferNearbyObjects];
			for (int i = 0; i < [bufferNearbyObjects count]; i++) {
				CollidableObject* obj1 = [bufferNearbyObjects objectAtIndex:i];
				for (int j = i + 1; j < [bufferNearbyObjects count]; j++) {
					CollidableObject* obj2 = [bufferNearbyObjects objectAtIndex:j];
					if (obj1 == obj2) {
						continue;
					}
					if (CircleIntersectsCircle(obj1.boundingCircle, obj2.boundingCircle)) {
						[obj1 collidedWithOtherObject:obj2];
						[obj2 collidedWithOtherObject:obj1];
					}
				}
			}
		}
	}
}

- (void)drawCellGridAtPoint:(CGPoint)center withScale:(float)scale withScroll:(Vector2f)scroll withAlpha:(float)alpha {
#ifdef GRID
	if (scale != currentGridScale) {
		[self remakeGridVertexArrayWithScale:scale];
		currentGridScale = scale;
	}
	
	// Disable the color array and switch off texturing
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glPushMatrix();
	
	float xOffset = center.x - ((fullMapBounds.size.width / 2) * scale) + scroll.x;
	float yOffset = center.y - ((fullMapBounds.size.height / 2) * scale) + scroll.y;
	glTranslatef(- xOffset + 1, - yOffset + 1, 0.0f);
	glColor4f(1.0f, 1.0f, 1.0f, alpha);
	glVertexPointer(2, GL_FLOAT, 0, gridVertexArray);
	glDrawArrays(GL_LINES, 0, 2 * (numberOfColumns + numberOfRows + 2));
	
	glPopMatrix();
	// Switch the color array back on and enable textures.  This is the default state
	// for our game engine
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
#endif
}

- (int)getIndexForLocation:(CGPoint)location {
	int xIndex = CLAMP(floorf(location.x / cellWidth), 0, numberOfColumns - 1);
	int yIndex = CLAMP(floorf(location.y / cellHeight), 0, numberOfRows - 1);
	
	int indexOfLocation = xIndex + (yIndex * numberOfColumns);
	
	return indexOfLocation;
}

@end
