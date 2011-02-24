//
//  CollisionManager.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollisionManager.h"
#import "CollidableObject.h"
#import "GameController.h"
#import "BroggutObject.h"
#import "BroggutGenerator.h"
#import "TextObject.h"

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
	[valueTextObject release];
	[generator release];
	[bufferNearbyObjects release];
	[objectTableValues release];
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
		cellHashTable = (ObjectIDArray*)malloc( totalCellCount * sizeof(*cellHashTable) );
		for (int i = 0; i < totalCellCount; i++) {
			ObjectIDArray* tempObjectArray = &(cellHashTable[i]);
			tempObjectArray->objectIDArray = (int*)malloc(INITIAL_HASH_CAPACITY * sizeof(int));
			tempObjectArray->arrayCount = 0; // Set the initial count
			tempObjectArray->arrayCapacity = INITIAL_HASH_CAPACITY; // Set the initial capacity
		}
		objectTable = [[NSMutableDictionary alloc] initWithCapacity:INITIAL_TABLE_CAPACITY];
		objectTableValues = [[NSMutableArray alloc] initWithCapacity:INITIAL_TABLE_CAPACITY];
		bufferNearbyObjects = [[NSMutableArray alloc] initWithCapacity:INITIAL_TABLE_CAPACITY];
		
		valueTextObject = [[TextObject alloc]
						   initWithFontID:kFontBlairID Text:@"" withLocation:CGPointMake(0, 0) withDuration:-1.0f];
		isShowingValueText = NO;
#ifdef BROGGUTS
		broggutArray = (BroggutArray*)malloc( sizeof(*broggutArray) );
		int countWide = ceilf(bounds.size.width / COLLISION_CELL_WIDTH);
		int countHigh = ceilf(bounds.size.height / COLLISION_CELL_HEIGHT);
		broggutArray->bWidth = countWide;
		broggutArray->bHeight = countHigh;
		broggutArray->broggutCount = 0;
		broggutArray->array = (MediumBroggut*)malloc( countWide * countHigh * sizeof(*(broggutArray->array)) );
		for (int i = 0; i < countWide * countHigh; i++) {
			MediumBroggut* broggut = &broggutArray->array[i];
			broggut->broggutID = i;
			broggut->broggutValue = -1;
			broggut->broggutAge = 0;
			broggut->broggutEdge = kMediumBroggutEdgeUp; // Default to drawing the broggut
		}
		generator = [[BroggutGenerator alloc] initWithWithBroggutArray:broggutArray];
#endif
#ifdef GRID
		// Fill the vertex array for the grid
		gridVertexArray = (float*)calloc( 4 * (numberOfColumns + numberOfRows + 2), sizeof(*gridVertexArray) );
		currentGridScale = Scale2fMake(1.0f, 1.0f);
		[self remakeGridVertexArrayWithScale:currentGridScale];
#endif
	}
	return self;
}

- (void)remakeGenerator {
	if (generator)
		[generator release];
	
	generator = [[BroggutGenerator alloc] initWithWithBroggutArray:broggutArray];
}

// Broggut array methods
#pragma mark -
#pragma mark Medium Brogguts

- (BroggutArray*)broggutArray {
	return broggutArray;
}

- (MediumBroggut*)broggutCellForLocation:(CGPoint)location {
	int xIndex = CLAMP(floorf(location.x / COLLISION_CELL_WIDTH), 0, broggutArray->bWidth - 1);
	int yIndex = CLAMP(floorf(location.y / COLLISION_CELL_HEIGHT), 0, broggutArray->bHeight - 1);
	int indexOfLocation = xIndex + (yIndex * broggutArray->bWidth);
	
	MediumBroggut* broggut = &broggutArray->array[indexOfLocation];
	return broggut;
}

- (int)getBroggutIDatLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutCellForLocation:location];
	return broggut->broggutID;
}

- (CGPoint)getBroggutLocationForID:(int)brogid {
	int xLoc = brogid % broggutArray->bWidth;
	int yLoc = brogid / broggutArray->bWidth;
	CGPoint newPoint = CGPointMake(xLoc * COLLISION_CELL_WIDTH + (COLLISION_CELL_WIDTH / 2),
								   yLoc * COLLISION_CELL_HEIGHT + (COLLISION_CELL_HEIGHT / 2));
	return newPoint;
}

- (CGRect)getBroggutRectForID:(int)brogid {
	int xLoc = brogid % broggutArray->bWidth;
	int yLoc = brogid / broggutArray->bWidth;
	CGRect newRect = CGRectMake(xLoc * COLLISION_CELL_WIDTH,
								 yLoc * COLLISION_CELL_HEIGHT,
								 COLLISION_CELL_WIDTH,
								 COLLISION_CELL_HEIGHT);
	return newRect;
}

- (BOOL)isLocationOccupiedByBroggut:(CGPoint)location {
	MediumBroggut* broggut = [self broggutCellForLocation:location];
	if (broggut->broggutValue != -1) {
		return YES;
	}
	return NO;
}

- (CGPoint)getLocationOfClosestMediumBroggutToPoint:(CGPoint)location {
	int cellsWide, cellsHigh;
	cellsWide = broggutArray->bWidth;
	cellsHigh = broggutArray->bHeight;
	CGPoint closestLocation;
	float currentDist = fullMapBounds.size.width + fullMapBounds.size.height; // The maximum possible distance (and then some)
	
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			int straightIndex = i + (j * cellsWide);
			CGPoint curLoc = [self getBroggutLocationForID:straightIndex];
			if ([self getBroggutValueAtLocation:curLoc] == -1) {
				continue;
			}
			if (GetDistanceBetweenPoints(location, curLoc) < currentDist) {
				currentDist = GetDistanceBetweenPoints(location, curLoc);
				closestLocation = curLoc;
			}
		}
	}
	return closestLocation;
}

- (int)getBroggutValueAtLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutCellForLocation:location];
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

- (void)addMediumBroggut {
	broggutArray->broggutCount += 1;
}

- (void)removeMediumBroggutWithID:(int)brogID {
	MediumBroggut* broggut = &broggutArray->array[brogID];
	broggut->broggutValue = -1;
	broggut->broggutAge = 0;
	broggut->broggutEdge = kMediumBroggutEdgeNone; // Default to drawing the broggut
	[self updateAllMediumBroggutsEdges];
}

- (void)updateMediumBroggutEdgeAtLocation:(CGPoint)location {
	CGPoint rightLoc = CGPointMake(location.x + COLLISION_CELL_WIDTH, location.y);
	CGPoint topLoc = CGPointMake(location.x, location.y + COLLISION_CELL_HEIGHT);
	CGPoint leftLoc = CGPointMake(location.x - COLLISION_CELL_WIDTH, location.y);
	CGPoint bottomLoc = CGPointMake(location.x, location.y - COLLISION_CELL_HEIGHT);
	MediumBroggut* middleBroggut = [self broggutCellForLocation:location];
	
	MediumBroggut* rightBroggut = [self broggutCellForLocation:rightLoc];
	MediumBroggut* topBroggut = [self broggutCellForLocation:topLoc];
	MediumBroggut* leftBroggut = [self broggutCellForLocation:leftLoc];
	MediumBroggut* bottomBroggut = [self broggutCellForLocation:bottomLoc];
	
	if (rightBroggut->broggutValue != -1 &&
		topBroggut->broggutValue != -1 &&
		leftBroggut->broggutValue != -1 &&
		bottomBroggut->broggutValue != -1) {
		// There a broggut on all sides
		middleBroggut->broggutEdge = kMediumBroggutEdgeNone;
	} else {
		middleBroggut->broggutEdge = kMediumBroggutEdgeUp; // TESTING, default to up
	}

}

- (void)updateAllMediumBroggutsEdges {
	int cellsWide = broggutArray->bWidth;
	int cellsHigh = broggutArray->bHeight;
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			int straightIndex = i + (j * cellsWide);
			MediumBroggut* broggut = &broggutArray->array[straightIndex];
			CGPoint currentPoint = CGPointMake(i * COLLISION_CELL_WIDTH, j * COLLISION_CELL_HEIGHT);
			if (broggut->broggutValue != -1) {
				[self updateMediumBroggutEdgeAtLocation:currentPoint];
			}
		}
	}
}

- (void)renderMediumBroggutsInScreenBounds:(CGRect)bounds withScrollVector:(Vector2f)scroll {
	int cellsWide, cellsHigh;
	cellsWide = broggutArray->bWidth;
	cellsHigh = broggutArray->bHeight;
	enablePrimitiveDraw();
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			int straightIndex = i + (j * cellsWide);
			MediumBroggut* broggut = &broggutArray->array[straightIndex];
			if (broggut->broggutValue != -1) {
				// There is a broggut here, so render it!
				CGPoint currentPoint = CGPointMake(i * COLLISION_CELL_WIDTH, j * COLLISION_CELL_HEIGHT);
				CGRect rectBounds = CGRectMake(currentPoint.x, currentPoint.y, COLLISION_CELL_WIDTH, COLLISION_CELL_HEIGHT);
				if (!CGRectIntersectsRect(bounds, rectBounds)) {
					continue;
				}
				if (broggut->broggutEdge == kMediumBroggutEdgeNone) {
					glColor4f(1.0f, 1.0f, 1.0f, 0.2f);
					drawFilledRect(rectBounds, scroll);
					continue;
				}
				
				float* mediumBroggutVerts;
				int count = [generator verticesOfMediumBroggutAtIndex:straightIndex intoArray:&mediumBroggutVerts];
				glColor4f(1.0f, 1.0f, 1.0f, 0.8f);
				drawLines(mediumBroggutVerts, count, scroll);
			}
		}
	}
	disablePrimitiveDraw();
}

- (void)drawValidityRectForLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutCellForLocation:location];
	if (broggut) {
		if (broggut->broggutValue != -1) {
			enablePrimitiveDraw();
			CGRect brogRect = [self getBroggutRectForID:broggut->broggutID];
			Vector2f scroll = [[[GameController sharedGameController] currentScene] scrollVectorFromScreenBounds];
			if (broggut->broggutEdge != kMediumBroggutEdgeNone) {
				// If over a broggut that is minable, draw a faded green box
				glColor4f(0.0f, 1.0f, 0.0f, 0.25f);
				drawFilledRect(brogRect, scroll);
			} else {
				// If over a broggut that is not minable, draw a faded red box
				glColor4f(1.0f, 0.0f, 0.0f, 0.25f);
				drawFilledRect(brogRect, scroll);
			}
			disablePrimitiveDraw();
		}
		// Or else don't draw any box
	}
}

- (void)showBroggutValueAtLocation:(CGPoint)location {
	MediumBroggut* broggut = [self broggutCellForLocation:location];
	if (isShowingValueText) {
		NSString* string = [NSString stringWithFormat:@"Bgs: %i",broggut->broggutValue];
		[valueTextObject setObjectText:string];
		[valueTextObject setIsHidden:NO];
	}
}

#pragma mark -
#pragma mark Grid

- (void)remakeGridVertexArrayWithScale:(Scale2f)scale {
#ifdef GRID
	int i = 0;
	// This inserts the vertical lines into first half of the vertex array
	for (i = 0; i < numberOfColumns + 1; i++) { // Columns index
		if (i == 0) {
			continue;
		}
		int currentIndex = i * 4;
		gridVertexArray[currentIndex] = i * cellWidth * scale.x;					// X1
		gridVertexArray[currentIndex+1] = fullMapBounds.origin.y * scale.y;			// Y1
		gridVertexArray[currentIndex+2] = i * cellWidth * scale.x;					// X2
		gridVertexArray[currentIndex+3] = fullMapBounds.size.height * scale.y;		// Y2
	}
	
	// This inserts the horizontal lines into second half of the vertex array
	for (int j = 0; j < numberOfRows + 1; j++) { // Rows index
		if (j == 0) {
			continue;
		}
		int currentIndex = (i * 4) + (j * 4);
		gridVertexArray[currentIndex] = fullMapBounds.origin.x * scale.x;		// X1
		gridVertexArray[currentIndex+1] = j * cellHeight * scale.y;				// Y1
		gridVertexArray[currentIndex+2] = fullMapBounds.size.width * scale.x;	// X2
		gridVertexArray[currentIndex+3] = j * cellHeight * scale.y;				// Y2
	}
#endif
}

- (void)drawCellGridAtPoint:(CGPoint)center withScale:(Scale2f)scale withScroll:(Vector2f)scroll withAlpha:(float)alpha {
#ifdef GRID
	if (scale.x != currentGridScale.x || scale.y != currentGridScale.y) {
		[self remakeGridVertexArrayWithScale:scale];
		currentGridScale = scale;
	}
	glPushMatrix();
	
	float xOffset = center.x - ((fullMapBounds.size.width / 2) * scale.x) + scroll.x;
	float yOffset = center.y - ((fullMapBounds.size.height / 2) * scale.y) + scroll.y;
	glTranslatef(- xOffset + 1, - yOffset + 1, 0.0f);
	glColor4f(1.0f, 1.0f, 1.0f, alpha);
	glVertexPointer(2, GL_FLOAT, 0, gridVertexArray);
	glDrawArrays(GL_LINES, 0, 2 * (numberOfColumns + numberOfRows + 2));
	
	glPopMatrix();
#endif
}


#pragma mark -
#pragma mark Collidable Objects

- (void)addCollidableObject:(CollidableObject*)object {
	int UID = object.uniqueObjectID;
	object.isCheckedForCollisions = YES;
	
	if ([objectTable objectForKey:[NSNumber numberWithInt:UID]] != nil) {
		NSLog(@"ERROR - Duplicate ObjectID in Collision Manager");
		return; //Already added this object
	} else {
		[objectTable setObject:object forKey:[NSNumber numberWithInt:UID]];
		[objectTableValues addObject:object];
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
		tempObjectArray->objectIDArray = (int*)realloc(tempObjectArray->objectIDArray,
													   (currentArrayCapacity + INITIAL_HASH_CAPACITY) * sizeof(int) );
		tempObjectArray->arrayCapacity = (currentArrayCapacity + INITIAL_HASH_CAPACITY);
	}
}

// Only used internally with objects that have been added to the dictionary
- (void)updateCollidableObjectWithID:(int)objectID {
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
		tempObjectArray->objectIDArray = (int*)realloc(tempObjectArray->objectIDArray,
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
		[objectTableValues removeObject:object];
	}
	
}

- (void)putNearbyObjectsToID:(int)objectID intoArray:(NSMutableArray*)array {
	CollidableObject* currentObject = [objectTable objectForKey:[NSNumber numberWithInt:objectID]];
	[self putNearbyObjectsToLocation:currentObject.objectLocation intoArray:array];
}

- (void)putNearbyObjectsToLocation:(CGPoint)location intoArray:(NSMutableArray*)nearbyObjectArray {
	[nearbyObjectArray retain];
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
	[nearbyObjectArray release];
}

- (BroggutObject*)closestSmallBroggutToLocation:(CGPoint)location {
	NSMutableArray* closeObjects = [[NSMutableArray alloc] init];
	[self putNearbyObjectsToLocation:location intoArray:closeObjects];
	float minDistance = fullMapBounds.size.width + fullMapBounds.size.height; // Largest distance possible (and some)
	BroggutObject* closestBroggut = nil;
	
	for (int i = 0; i < [closeObjects count]; i++) {
		// Check for closest small broggut
		BroggutObject* obj = [closeObjects objectAtIndex:i];
		if (obj.objectType == kObjectBroggutSmallID) {
			float currentDistance = GetDistanceBetweenPoints(obj.objectLocation, location);
			if (currentDistance < minDistance) {
				minDistance = currentDistance;
				closestBroggut = obj;
			}
		}
	}
	
	[closeObjects release];
	return closestBroggut;
}

#pragma mark -
#pragma mark Collision Management

- (void)updateAllObjectsInTableInScreenBounds:(CGRect)bounds {
	// Keep the dictionary, but set all hash table counts to 0
	
	for (int i = 0; i < numberOfColumns * numberOfRows; i++) {
		ObjectIDArray* nearbyObjects = &(cellHashTable[i]);
		nearbyObjects->arrayCount = 0;
	}
	
	for (int i = 0; i < [objectTableValues count]; i++) {
		CollidableObject* currentObject = [objectTableValues objectAtIndex:i];
		if (!CGRectContainsPoint(bounds, currentObject.objectLocation))
			continue;
		[self updateCollidableObjectWithID:currentObject.uniqueObjectID];
		currentObject.hasBeenCheckedForCollisions = NO; // Reset collision checks
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
						if ( obj1 == obj2) {
							continue;
						}
						if ( CircleIntersectsCircle(obj1.boundingCircle, obj2.boundingCircle) ) {
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
					if (obj1 == obj2 || obj1.hasBeenCheckedForCollisions || obj2.hasBeenCheckedForCollisions) {
						continue;
					}
					if (CircleIntersectsCircle(obj1.boundingCircle, obj2.boundingCircle)) {
						[obj1 collidedWithOtherObject:obj2];
					}
				}
			}
		}
	}
}

- (int)getIndexForLocation:(CGPoint)location {
	int xIndex = CLAMP(floorf(location.x / cellWidth), 0, numberOfColumns - 1);
	int yIndex = CLAMP(floorf(location.y / cellHeight), 0, numberOfRows - 1);
	
	int indexOfLocation = xIndex + (yIndex * numberOfColumns);
	
	return indexOfLocation;
}

@end
