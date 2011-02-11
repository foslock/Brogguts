//
//  CollisionManager.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct Object_ID_Array {
	int* objectIDArray; // Array of objects in that cell
	int arrayCount;		// Number of objects in the array
	int arrayCapacity;	// The Capacity of the array
} ObjectIDArray;

typedef struct Medium_Broggut {
	int broggutID;		// This is the unique broggut ID, empty or not, all spots have this
	int broggutValue;	// This is the number of brogguts in this broggut cell, if -1, then spot is empty
} MediumBroggut;

typedef struct Broggut_Array {
	MediumBroggut* array;	// This is the 1D->2D mapped array of medium brogguts
	int bWidth;				// This is the number of cells wide the array is
	int bHeight;			// This is the number of cells high the array is
} BroggutArray;

@class CollidableObject;

#define MEDIUM_BROGGUT_SIDE_LENGTH 64.0f
#define INITIAL_HASH_CAPACITY 20 // Initial capacity of each cell for UIDs
#define INITIAL_TABLE_CAPACITY 100 // Initial capacity of the table holding all CollidableObjects
#define COLLISION_DETECTION_FREQ 3 // How many frames to wait to check collisions (0 - every frame, 1 - every other, 2 every second, etc.)
#define CHECK_ONLY_OBJECTS_ONSCREEN YES // Only perform collision detection for objects on screen

@interface CollisionManager : NSObject {
	NSMutableDictionary* objectTable;	// This keeps tracks of all objects that have been added, indexed by their UID
	ObjectIDArray* cellHashTable;		// Table that contains an array for each cell on the screen, index is the location "hashed"
										// and the contents is an array of UIDs for each object in that cell
	NSMutableArray* bufferNearbyObjects;// Buffer that will be used during loops to store nearby objects
	CGRect fullMapBounds;				// The entire map rectangle
	float* gridVertexArray;				// Vertexes of the grid if we want to draw it
	float currentGridScale;				// The scale of the grid
	float cellWidth;					// The width of a cell dividing the rect
	float cellHeight;					// The height " "
	int numberOfColumns;				// Number of cell columns
	int numberOfRows;					// Number of cell rows
	
	BroggutArray* broggutArray;			// A 2D array of brogguts
}

- (id)initWithContainingRect:(CGRect)bounds WithCellWidth:(float)width withHeight:(float)height;

- (MediumBroggut*)broggutForLocation:(CGPoint)location;
- (int)getBroggutIDatLocation:(CGPoint)location;
- (BOOL)isLocationOccupiedByBroggut:(CGPoint)location;
- (int)getBroggutValueAtLocation:(CGPoint)location;
- (int)getBroggutValueWithID:(int)brogID;
- (void)setBroggutValue:(int)newValue withID:(int)brogID;

- (void)remakeGridVertexArrayWithScale:(float)scale;

- (void)addCollidableObject:(CollidableObject*)object;
- (void)removeCollidableObject:(CollidableObject*)object;

- (void)putNearbyObjectsToID:(int)objectID intoArray:(NSMutableArray*)array;
- (void)putNearbyObjectsToLocation:(CGPoint)location intoArray:(NSMutableArray*)array;

- (void)updateAllObjectsInTableInScreenBounds:(CGRect)bounds;
- (void)processAllCollisionsWithScreenBounds:(CGRect)bounds;

- (int)getIndexForLocation:(CGPoint)location;

- (void)drawCellGridAtPoint:(CGPoint)center withScale:(float)scale withScroll:(Vector2f)scroll withAlpha:(float)alpha;

@end
