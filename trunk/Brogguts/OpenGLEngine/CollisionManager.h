//
//  CollisionManager.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/9/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

enum BroggutEdgeValues {
	kMediumBroggutEdgeLeft,
	kMediumBroggutEdgeUp,
	kMediumBroggutEdgeRight,
	kMediumBroggutEdgeDown,
	kMediumBroggutEdgeNone,
};

@class BroggutObject;
@class BroggutGenerator;
@class TextObject;
@class TouchableObject;
@class BroggutScene;

typedef struct Object_ID_Array {
	int* objectIDArray; // Array of objects in that cell
	int arrayCount;		// Number of objects in the array
	int arrayCapacity;	// The Capacity of the array
} ObjectIDArray;

typedef struct Medium_Broggut {
	int broggutID;		// This is the unique broggut ID, empty or not, all spots have this
	CGPoint broggutLocation;	// Center of this medium broggut, used for pathfinding
	int broggutValue;	// This is the number of brogguts in this broggut cell, if -1, then spot is empty
	int broggutAge;		// The rarity of the broggut (0 - young, 1 - old, 2 - ancient)
	int broggutEdge;	// If the broggut is on the edge of a large broggut
} MediumBroggut;

typedef struct Broggut_Array {
	MediumBroggut* array;	// This is the 1D->2D mapped array of medium brogguts
	int bWidth;				// This is the number of cells wide the array is
	int bHeight;			// This is the number of cells high the array is
	int broggutCount;		// The number of medium brogguts in the array (values != -1)
} BroggutArray;

typedef struct Path_Node {
	struct Path_Node* parentNode;	// Parent node, used in path finding
	BOOL isOpen;					// YES if the node is currently free and travellable
	BOOL isBuildingLocation;		// YES if there is a building currently moving to that location
	float distanceToDest;			// Approximate distance to the final point in the path, CONSIDER INVALID WHEN STARTING NEW PATH
	float distanceFromStart;		// Approximate distance from the start point of the path, CONSIDER INVALID WHEN STARTING NEW PATH
	float totalDistance;			// Cost of this node in the path
	int currentList;				// The list that the path node is currently on
	CGPoint nodeLocation;
} PathNode;

enum PathNodeListTypes {
	kPathNodeListNone,
	kPathNodeListOpen,
	kPathNodeListClosed,
};

typedef struct Path_Node_Queue {
	PathNode** nodeQueue;
	int nodeCount;
} PathNodeQueue;

@class CollidableObject;

#define INITIAL_HASH_CAPACITY 4			// Initial capacity of each cell for UIDs
#define INITIAL_TABLE_CAPACITY 100		// Initial capacity of the table holding all CollidableObjects
#define COLLISION_DETECTION_FREQ 3		// How many frames to wait to check collisions (0 - every frame, 1 - every other, 2 every second, etc.)
#define RADIAL_EFFECT_CHECK_FREQ 3		// " " to check radial effects
#define RADIAL_EFFECT_MAX_COUNT 10      // Maximum number of objects to check for radial effects
#define MEDIUM_BROGGUT_IMAGE_COUNT 5   // Number of different textures to use for the medium brogguts

@interface CollisionManager : NSObject {
    BroggutScene* currentScene;         // Reference to the current scene
    
    
	NSMutableDictionary* objectTable;	// This keeps tracks of all objects that have been added, indexed by their UID
	NSMutableArray* objectTableValues;	// This array is kept so enumeration is easy through the dictionary, updated whenever an object
										// is added to the dictionary.
	
	NSMutableArray* radialAffectedObjects;	// Array of structures that should be checked for objects in their radius
    NSMutableArray* radialObjectsQueue;     // Queue of objects that need to be checked for radial effects
    int startingRadialIndex;                // Index of object that should be added to the radial queue next
	
	ObjectIDArray* cellHashTable;		// Table that contains an array for each cell on the screen, index is the location "hashed"
										// and the contents is an array of UIDs for each object in that cell
	
	NSMutableArray* bufferNearbyObjects;// Buffer that will be used during loops to store nearby objects
	CGRect fullMapBounds;				// The entire map rectangle
	float* gridVertexArray;				// Vertexes of the grid if we want to draw it
	Scale2f currentGridScale;			// The scale of the grid
	float cellWidth;					// The width of a cell dividing the rect
	float cellHeight;					// The height " "
	int numberOfColumns;				// Number of cell columns
	int numberOfRows;					// Number of cell rows
	
	TextObject* valueTextObject;		// Text object that shows the medium broggut value
	BOOL isShowingValueText;			// Boolean about if the text is showing
	
	BroggutArray* broggutArray;			// A 1D array of brogguts mapped to 2D
	BroggutGenerator* generator;		// The generator the makes the medium brogguts
    NSMutableArray* mediumBroggutImageArrayYoung;   // Array of the images that will be used for the young medium brogguts
    NSMutableArray* mediumBroggutImageArrayOld;   // Array of the images that will be used for the young medium brogguts
    NSMutableArray* mediumBroggutImageArrayAncient;   // Array of the images that will be used for the young medium brogguts
	
	// Path finding array of nodes
	PathNode* pathNodeArray;			// A 1D array of pathnodes mapped to 2D
	PathNodeQueue pathNodeQueueOpen;	// A queue that can contain path nodes (the open list)
	PathNodeQueue pathNodeQueueClosed;	// A queue that can contain path nodes (the closed list)
}

@property (nonatomic, assign) BroggutScene* currentScene;
@property (nonatomic, assign) BOOL isShowingValueText;

- (id)initWithContainingRect:(CGRect)bounds WithCellWidth:(float)width withHeight:(float)height;

- (void)remakeGenerator;

- (BroggutScene*)currentScene;
- (BroggutArray*)broggutArray;
- (MediumBroggut*)broggutCellForLocation:(CGPoint)location;
- (int)getBroggutIDatLocation:(CGPoint)location;
- (CGPoint)getBroggutLocationForID:(int)brogid;
- (CGRect)getBroggutRectForID:(int)brogid;
- (BOOL)isLocationOccupiedByBroggut:(CGPoint)location;
- (CGPoint)getLocationOfClosestMediumBroggutToPoint:(CGPoint)location;
- (int)getBroggutValueAtLocation:(CGPoint)location;
- (int)getBroggutValueWithID:(int)brogID;
- (void)setBroggutValue:(int)newValue withID:(int)brogID isRemote:(BOOL)remote;

- (void)updateMediumBroggutAtLocation:(CGPoint)location;
- (void)updateMediumBroggutEdgeAtLocation:(CGPoint)location;
- (void)updateAllMediumBroggutsEdges;
- (void)addMediumBroggut;
- (void)removeMediumBroggutWithID:(int)brogID;
- (void)renderMediumBroggutsInScreenBounds:(CGRect)bounds withScrollVector:(Vector2f)scroll;
- (void)drawValidityRectForLocation:(CGPoint)location forMining:(BOOL)forMining;

- (void)addRadialAffectedObject:(TouchableObject*)obj;
- (void)removeRadialAffectedObject:(TouchableObject*)obj;
- (void)processAllEffectRadii;

- (void)remakeGridVertexArrayWithScale:(Scale2f)scale;

- (BOOL)isLineOpenFromLocation:(CGPoint)startLoc toLocation:(CGPoint)endLoc;
- (void)setPathNodeIsOpen:(BOOL)open atLocation:(CGPoint)location;
- (BOOL)isPathNodeOpenAtLocation:(CGPoint)location;
- (PathNode*)pathNodeForRow:(int)row forColumn:(int)col;
- (NSArray*)pathFrom:(CGPoint)fromLocation to:(CGPoint)toLocation allowPartial:(BOOL)partial isStraight:(BOOL)straight;

- (void)addCollidableObject:(CollidableObject*)object;
- (void)removeCollidableObject:(CollidableObject*)object;
- (BOOL)collisionOccuredBetween:(CollidableObject*)object andOther:(CollidableObject*)other;

- (void)putNearbyObjectsToID:(int)objectID intoArray:(NSMutableArray*)array;
- (void)putNearbyObjectsToLocation:(CGPoint)location intoArray:(NSMutableArray*)array;
- (BroggutObject*)closestSmallBroggutToLocation:(CGPoint)location;

- (void)updateAllObjectsInTableInScreenBounds:(CGRect)bounds;
- (void)processAllCollisionsWithScreenBounds:(CGRect)bounds;

- (int)getIndexForLocation:(CGPoint)location;

- (void)drawCellGridAtPoint:(CGPoint)center withScale:(Scale2f)scale withScroll:(Vector2f)scroll withAlpha:(float)alpha;

@end
