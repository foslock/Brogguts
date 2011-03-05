//
//  GameController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameController.h"
#import "SoundSingleton.h"
#import "OpenGLEngineAppDelegate.h"
#import "BroggutScene.h"
#import "BaseCampScene.h"
#import "CollisionManager.h"
#import "PlayerProfile.h"
#import "StructureObject.h"
#import "CraftObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"
#import "BitmapFont.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private) 
// Initializes OpenGL
- (void)initGameController;

@end

static GameController* sharedGameController = nil;

@implementation GameController

@synthesize currentPlayerProfile;
@synthesize currentScene, transitionName;
@synthesize gameScenes;
@synthesize eaglView;
@synthesize interfaceOrientation;
@synthesize isFadingSceneIn, isFadingSceneOut;

#pragma mark -
#pragma mark Singleton implementation

+ (GameController *)sharedGameController
{
	@synchronized (self) {
		if (sharedGameController == nil) {
			[[self alloc] init];
		}
	}
	
	return sharedGameController;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedGameController == nil) {
			sharedGameController = [super allocWithZone:zone];
			return sharedGameController;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // This is sooo not zero
}


#pragma mark -
#pragma mark Public implementation

- (void)dealloc {
	[[SoundSingleton sharedSoundSingleton] shutdownSoundManager];
	[currentScene release];
    [gameScenes release];
	[transitionName release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self != nil) {
		// Initialize the game
        [self initGameController];
    }
    return self;
}

- (void)loadPlayerProfile {
	NSLog(@"INFO - GameController: Loading previous player profile.");
	NSString* path = [self documentsPathWithFilename:@"playerprofile.data"];
	NSDictionary* rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];    
	[self setCurrentPlayerProfile:[rootObject valueForKey:@"Profile"]];
	if (!currentPlayerProfile) {
		NSLog(@"INFO - GameController: No previous player profile, creating a brand new profile.");
		currentPlayerProfile = [[PlayerProfile alloc] init];
	}
}

- (void)savePlayerProfile {
	NSLog(@"INFO - GameController: Saving current player profile.");
	NSString* path = [self documentsPathWithFilename:@"playerprofile.data"];
	NSMutableDictionary* rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:currentPlayerProfile forKey:@"Profile"];
	if (![NSKeyedArchiver archiveRootObject:rootObject toFile:path]){
		NSLog(@"INFO - GameController: Saving failed.");
	}
}

- (NSString*)documentsPathWithFilename:(NSString*)filename {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
	NSString* filePath = [documentsDirectory stringByAppendingPathComponent:filename];
	return filePath;
}

- (void)insertCGPoint:(CGPoint)point intoArray:(NSMutableArray*)array atIndex:(int)index {
	NSMutableArray* newPointArray = [[NSMutableArray alloc] init];
	[newPointArray insertObject:[NSNumber numberWithFloat:point.x] atIndex:0];
	[newPointArray insertObject:[NSNumber numberWithFloat:point.y] atIndex:1];
	[array insertObject:newPointArray atIndex:index];
	[newPointArray release];
}

- (CGPoint)getCGPointFromArray:(NSArray*)array atIndex:(int)index {
	NSArray* pointArray = [array objectAtIndex:index];
	NSNumber* xNum = [pointArray objectAtIndex:0];
	NSNumber* yNum = [pointArray objectAtIndex:1];
	return CGPointMake([xNum floatValue], [yNum floatValue]);
}

- (void)createInitialBaseCampLevel {
	NSString* sceneTitle = @"Base Camp";
	BOOL isBaseCamp = YES;
	int widthCells = 64;
	int heightCells = 48;
	int numberOfSmallBrogguts = 500;
	
	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:sceneTitle atIndex:0];
	[plistArray insertObject:[NSNumber numberWithBool:isBaseCamp] atIndex:1];
	[plistArray insertObject:[NSNumber numberWithInt:widthCells] atIndex:2];
	[plistArray insertObject:[NSNumber numberWithInt:heightCells] atIndex:3];
	[plistArray insertObject:[NSNumber numberWithInt:numberOfSmallBrogguts] atIndex:4];
	
	// Save all the other crap, medium brogguts first
	NSMutableArray* broggutArray = [[NSMutableArray alloc] initWithCapacity:widthCells * heightCells];
	for (int j = 0; j < heightCells; j++) {
		for (int i = 0; i < widthCells; i++) {
			int straightIndex = i + (j * widthCells);
			NSMutableArray* thisBroggutInfo = [[NSMutableArray alloc] init];
			NSNumber* broggutValue;
			NSNumber* broggutAge;
			if (i > 17 && i < 47 && j > 14 && j < 34) {
				broggutValue = [NSNumber numberWithInt:600];
				broggutAge = [NSNumber numberWithInt:1];
			} else {
				broggutValue = [NSNumber numberWithInt:-1];
				broggutAge = [NSNumber numberWithInt:0];
			}			
			[thisBroggutInfo insertObject:broggutValue atIndex:0];
			[thisBroggutInfo insertObject:broggutAge atIndex:1];
			[broggutArray insertObject:thisBroggutInfo atIndex:straightIndex];
			[thisBroggutInfo release];
		}
	}
	[plistArray insertObject:broggutArray atIndex:5];
	[broggutArray release];
	
	// Save structures, namely the base stations
	NSMutableArray* finalObjectArray = [[NSMutableArray alloc] init];
	// Create the initial base station: 
	{
		NSMutableArray* thisStructureArray = [[NSMutableArray alloc] init];
		
		int objectTypeID = kObjectTypeStructure;
		int objectID = kObjectStructureBaseStationID;
		NSArray* objectCurrentPath = [[NSArray alloc] init]; // NIL for now
		int objectAlliance = kAllianceFriendly;
		float objectRotation = 0.0f;
		BOOL objectIsTraveling = NO;
		CGPoint objectEndLocation = CGPointMake(COLLISION_CELL_WIDTH / 2, COLLISION_CELL_HEIGHT / 2);
		CGPoint objectCurrentLocation = objectEndLocation;
		int objectCurrentHull = -1; // Means full
		BOOL objectIsControlledShip = NO;
		BOOL objectIsMining = NO;
		CGPoint objectMiningLocation = CGPointZero;
		
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:0];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectID] atIndex:1];
		[thisStructureArray insertObject:objectCurrentPath atIndex:2];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:3];
		[thisStructureArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:4];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:5];
		[self insertCGPoint:objectEndLocation intoArray:thisStructureArray atIndex:6];
		[self insertCGPoint:objectCurrentLocation intoArray:thisStructureArray atIndex:7];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:8];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:9];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:10];
		[self insertCGPoint:objectMiningLocation intoArray:thisStructureArray atIndex:11];
		if (objectID == kObjectStructureBaseStationID) {
			[finalObjectArray insertObject:thisStructureArray atIndex:0];
		} else {
			[finalObjectArray addObject:thisStructureArray];
		}
		[thisStructureArray release];
		[objectCurrentPath release];
	}
	
	// Create the initial ANT craft for the player: 
	{
		NSMutableArray* thisCraftArray = [[NSMutableArray alloc] init];
		
		int objectTypeID = kObjectTypeCraft;
		int objectID = kObjectCraftAntID;
		NSArray* objectCurrentPath = [[NSArray alloc] init]; // NIL for now
		int objectAlliance = kAllianceFriendly;
		float objectRotation = 0.0f;
		BOOL objectIsTraveling = NO;
		CGPoint objectEndLocation = CGPointMake(5 * COLLISION_CELL_WIDTH / 2, 5 * COLLISION_CELL_HEIGHT / 2);
		CGPoint objectCurrentLocation = objectEndLocation;
		int objectCurrentHull = -1; // Means full
		BOOL objectIsControlledShip = YES;
		BOOL objectIsMining = NO;
		CGPoint objectMiningLocation = CGPointZero;
		
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:0];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectID] atIndex:1];
		[thisCraftArray insertObject:objectCurrentPath atIndex:2];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:3];
		[thisCraftArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:4];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:5];
		[self insertCGPoint:objectEndLocation intoArray:thisCraftArray atIndex:6];
		[self insertCGPoint:objectCurrentLocation intoArray:thisCraftArray atIndex:7];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:8];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:9];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:10];
		[self insertCGPoint:objectMiningLocation intoArray:thisCraftArray atIndex:11];
		[finalObjectArray addObject:thisCraftArray];
		[thisCraftArray release];
		[objectCurrentPath release];
	}
	
	[plistArray insertObject:finalObjectArray atIndex:6];
	NSString* filePath = [self documentsPathWithFilename:@"BaseCampSaved.plist"];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the Base Camp Scene!");
	}
	[plistArray release];
}

- (void)saveCurrentSceneWithFilename:(NSString*)filename {
	// Format for saved scenes:
	//
	// ----
	// Propert List format
	// ----
	// index - type - description
	//
	// 0 - NSString - Scene title/name
	// 1 - NSNumber (BOOL) - Whether the scene is base camp or not
	// 2 - NSNumber (int) - The width of the scene (in units of cells, not pixels)
	// 3 - NSNumber (int) - Height in cells
	// 4 - NSNumber (int) - Number of small brogguts floating in scene
	// 5 - NSArray - Broggut cell array, containing information about each cell's broggut (or lack of)
	// 6 - NSArray - Object array, containing information about both structures and crafts
	//
	//
	
	
	NSString* sceneTitle = currentScene.sceneName;
	BOOL isBaseCamp = YES;
	int widthCells = currentScene.widthCells;
	int heightCells = currentScene.heightCells;
	int numberOfSmallBrogguts = currentScene.numberOfSmallBrogguts;
	
	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:sceneTitle atIndex:0];
	[plistArray insertObject:[NSNumber numberWithBool:isBaseCamp] atIndex:1];
	[plistArray insertObject:[NSNumber numberWithInt:widthCells] atIndex:2];
	[plistArray insertObject:[NSNumber numberWithInt:heightCells] atIndex:3];
	[plistArray insertObject:[NSNumber numberWithInt:numberOfSmallBrogguts] atIndex:4];
	
	// Save all the other crap, medium brogguts first
	NSMutableArray* broggutArray = [[NSMutableArray alloc] initWithCapacity:widthCells * heightCells];
	for (int j = 0; j < heightCells; j++) {
		for (int i = 0; i < widthCells; i++) {
			float currentX = (i * COLLISION_CELL_WIDTH) + (COLLISION_CELL_WIDTH / 2);
			float currentY = (j * COLLISION_CELL_HEIGHT) + (COLLISION_CELL_HEIGHT / 2);
			CGPoint currentPoint = CGPointMake(currentX, currentY);
			int straightIndex = i + (j * widthCells);
			NSMutableArray* thisBroggutInfo = [[NSMutableArray alloc] init];
			MediumBroggut* broggut = [[currentScene collisionManager] broggutCellForLocation:currentPoint]; 
			NSNumber* broggutValue = [NSNumber numberWithInt:broggut->broggutValue];
			NSNumber* broggutAge = [NSNumber numberWithInt:broggut->broggutAge];
			[thisBroggutInfo insertObject:broggutValue atIndex:0];
			[thisBroggutInfo insertObject:broggutAge atIndex:1];
			[broggutArray insertObject:thisBroggutInfo atIndex:straightIndex];
			[thisBroggutInfo release];
		}
	}
	[plistArray insertObject:broggutArray atIndex:5];
	[broggutArray release];
	
	// Save structures, namely the base stations
	NSMutableArray* finalObjectArray = [[NSMutableArray alloc] init];
	
	NSArray* currentObjectArray = [NSArray arrayWithArray:[currentScene touchableObjects]];
	for (int i = 0; i < [currentObjectArray count]; i++) {
		TouchableObject* object = [currentObjectArray objectAtIndex:i];
		if ([object isKindOfClass:[StructureObject class]]) {
			// It is a structure, so save it!
			NSMutableArray* thisStructureArray = [[NSMutableArray alloc] init];
			StructureObject* thisStructure = (StructureObject*)object;
			
			int objectTypeID = kObjectTypeStructure;
			int objectID = thisStructure.objectType;
			NSArray* objectCurrentPath = [[NSArray alloc] init]; // NIL for now
			int objectAlliance = thisStructure.objectAlliance;
			float objectRotation = thisStructure.objectRotation;
			BOOL objectIsTraveling = thisStructure.isTraveling;
			CGPoint objectEndLocation = thisStructure.objectLocation;
			CGPoint objectCurrentLocation = thisStructure.objectLocation;
			int objectCurrentHull = thisStructure.attributeHullCurrent;
			BOOL objectIsControlledShip = NO;
			BOOL objectIsMining = NO;
			CGPoint objectMiningLocation = CGPointZero;
			
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:0];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectID] atIndex:1];
			[thisStructureArray insertObject:objectCurrentPath atIndex:2];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:3];
			[thisStructureArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:4];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:5];
			[self insertCGPoint:objectEndLocation intoArray:thisStructureArray atIndex:6];
			[self insertCGPoint:objectCurrentLocation intoArray:thisStructureArray atIndex:7];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:8];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:9];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:10];
			[self insertCGPoint:objectMiningLocation intoArray:thisStructureArray atIndex:11];
			if (objectID == kObjectStructureBaseStationID) {
				[finalObjectArray insertObject:thisStructureArray atIndex:0];
			} else {
				[finalObjectArray addObject:thisStructureArray];
			}
			[objectCurrentPath release];
			[thisStructureArray release];
		}
	}
	
	// Save all craft next
	for (int i = 0; i < [currentObjectArray count]; i++) {
		TouchableObject* object = [currentObjectArray objectAtIndex:i];
		if ([object isKindOfClass:[CraftObject class]] && ![object isKindOfClass:[SpiderDroneObject class]]) {
			// It is a craft (and not a drone!) so save it!
			NSMutableArray* thisCraftArray = [[NSMutableArray alloc] init];
			CraftObject* thisCraft = (CraftObject*)object;
			
			int objectTypeID = kObjectTypeCraft;
			int objectID = thisCraft.objectType;
			NSArray* objectCurrentPath = [[NSArray alloc] init]; // Nothing in this array for now
			int objectAlliance = thisCraft.objectAlliance;
			float objectRotation = thisCraft.objectRotation;
			BOOL objectIsTraveling = thisCraft.isTraveling;
			CGPoint objectEndLocation = thisCraft.objectLocation;
			CGPoint objectCurrentLocation = thisCraft.objectLocation;
			int objectCurrentHull = thisCraft.attributeHullCurrent;
			BOOL objectIsControlledShip = thisCraft.isBeingControlled;
			BOOL objectIsMining = NO;
			CGPoint objectMiningLocation = CGPointZero;
			
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:0];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectID] atIndex:1];
			[thisCraftArray insertObject:objectCurrentPath atIndex:2];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:3];
			[thisCraftArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:4];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:5];
			[self insertCGPoint:objectEndLocation intoArray:thisCraftArray atIndex:6];
			[self insertCGPoint:objectCurrentLocation intoArray:thisCraftArray atIndex:7];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:8];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:9];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:10];
			[self insertCGPoint:objectMiningLocation intoArray:thisCraftArray atIndex:11];
			[finalObjectArray addObject:thisCraftArray];
			[thisCraftArray release];
		}
	}
	
	[plistArray insertObject:finalObjectArray atIndex:6];
	NSString* filePath = [self documentsPathWithFilename:filename];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the current Scene!");
	}
	[plistArray release];
}

- (BroggutScene*)sceneWithFilename:(NSString*)filename {
	NSString* filePath = [self documentsPathWithFilename:filename];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (!fileExists) {
		NSLog(@"Scene '%@' not found", filename);
		return nil;
	}
	
	NSArray* array = [[NSArray alloc] initWithContentsOfFile:filePath];
	BroggutScene* newScene;
	
	// First four objects in the array are as follows:
	NSString* sceneName = [array objectAtIndex:0];					// 0: NSString - Name of the scene/level
	BOOL baseCamp = [[array objectAtIndex:1] boolValue];			// 1: BOOL - BaseCamp
	int cellsWide = [[array objectAtIndex:2] intValue];				// 2: int - Width (in cells) of the map
	int cellsHigh = [[array objectAtIndex:3] intValue];				// 3: int - Height (in cells) of the map
	int numberOfSmallBrogguts = [[array objectAtIndex:4] intValue];	// 4: int - Number of small brogguts to be created
	NSArray* broggutArray = [array objectAtIndex:5];				// 6: NSArray - the information for all of the medium brogguts
	NSArray* objectArray = [array objectAtIndex:6];					// 7: NSArray - " " objects
	
	CGRect fullMapRect = CGRectMake(0, 0, COLLISION_CELL_WIDTH * cellsWide, COLLISION_CELL_HEIGHT * cellsHigh);
	CGRect visibleRect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
	
	if (baseCamp) {
		newScene = [[BroggutScene alloc] initWithScreenBounds:visibleRect withFullMapBounds:fullMapRect withName:sceneName];
	}
	// Array used to store locations where small brogguts should be created
	NSMutableArray* locationArray = [[NSMutableArray alloc] init];
	
	// Iterate through the broggut cell array
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			NSMutableArray* pointArray = [[NSMutableArray alloc] init];
			float currentX = (i * COLLISION_CELL_WIDTH) + (COLLISION_CELL_WIDTH / 2);
			float currentY = (j * COLLISION_CELL_HEIGHT) + (COLLISION_CELL_HEIGHT / 2);
			CGPoint currentPoint = CGPointMake(currentX, currentY);
			int straightIndex = i + (j * cellsWide);
			
			NSArray* currentBroggutInfo = [broggutArray objectAtIndex:straightIndex];
			MediumBroggut* broggut = [[newScene collisionManager] broggutCellForLocation:currentPoint]; 
			NSNumber* broggutValue = [currentBroggutInfo objectAtIndex:0];  // Value stored
			NSNumber* broggutAge = [currentBroggutInfo objectAtIndex:1];	// Age stored
			broggut->broggutValue = [broggutValue intValue];
			broggut->broggutAge = [broggutAge intValue];
			if ([broggutValue intValue] == -1) {
				[pointArray addObject:[NSNumber numberWithFloat:currentX]];
				[pointArray addObject:[NSNumber numberWithFloat:currentY]];
				[locationArray addObject:pointArray];
			} else {
				[[newScene collisionManager] addMediumBroggut];
				[[newScene collisionManager] setPathNodeIsOpen:NO atLocation:currentPoint];
			}
			[pointArray release];
		}
	}
	
	// Iterate through the object array
	for (int i = 0; i < [objectArray count]; i++) {
		NSArray* currentObjectInfo = [objectArray objectAtIndex:i];
		// Go through each object and create the appropriate object with the correct attributes
		// - object type ID
		int objectTypeID = [[currentObjectInfo objectAtIndex:0] intValue];
		// - object ID
		int objectID = [[currentObjectInfo objectAtIndex:1] intValue];
		// - Current path
		NSArray* objectCurrentPath = [currentObjectInfo objectAtIndex:2];
		// - Alliance
		int objectAlliance = [[currentObjectInfo objectAtIndex:3] intValue];
		// - Rotation
		float objectRotation = [[currentObjectInfo objectAtIndex:4] floatValue];
		// - isTraveling
		BOOL objectIsTraveling = [[currentObjectInfo objectAtIndex:5] boolValue];
		// - ^^ end location
		CGPoint objectEndLocation = [self getCGPointFromArray:currentObjectInfo atIndex:6];
		// - Current location
		CGPoint objectCurrentLocation = [self getCGPointFromArray:currentObjectInfo atIndex:7];
		// - Current Hull
		int objectCurrentHull = [[currentObjectInfo objectAtIndex:8] intValue];
		// - isControlledShip
		BOOL objectIsControlledShip = [[currentObjectInfo objectAtIndex:9] boolValue];
		// - if mining
		BOOL objectIsMining = [[currentObjectInfo objectAtIndex:10] boolValue];
		// - mining location
		CGPoint objectMiningLocation = [self getCGPointFromArray:currentObjectInfo atIndex:11];
		
		switch (objectTypeID) {
			case kObjectTypeStructure: {
				// Create structure for this iteration
				switch (objectID) {
					case kObjectStructureBaseStationID: {
						BaseStationStructureObject* newStructure = [[BaseStationStructureObject alloc]
																	initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:YES];
						if (newStructure.objectAlliance == kAllianceFriendly) {
							newScene.homeBaseLocation = objectEndLocation;
						}
						if (newStructure.objectAlliance == kAllianceEnemy) {
							newScene.enemyBaseLocation = objectEndLocation;
						}
						break;
					}
					case kObjectStructureBlockID: {
						BlockStructureObject* newStructure = [[BlockStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:YES];
						break;
					}
					case kObjectStructureTurretID: {
						TurretStructureObject* newStructure = [[TurretStructureObject alloc]
															   initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:YES];
						break;
					}
					case kObjectStructureRadarID: {
						RadarStructureObject* newStructure = [[RadarStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:YES];
						break;
					}
					case kObjectStructureFixerID: {
						FixerStructureObject* newStructure = [[FixerStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:YES];
						break;
					}
					default:
						NSLog(@"Invalid Structure ID provided <%i>", objectID);
						break;
				}
			}
				break;
			case kObjectTypeCraft: {
				// Create craft for this iteration
				switch (objectID) {
					case kObjectCraftAntID: {
						AntCraftObject* newCraft = [[AntCraftObject alloc]
													initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftMothID: {
						MothCraftObject* newCraft = [[MothCraftObject alloc]
													 initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftBeetleID: {
						BeetleCraftObject* newCraft = [[BeetleCraftObject alloc]
													   initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftMonarchID: {
						MonarchCraftObject* newCraft = [[MonarchCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftCamelID: {
						CamelCraftObject* newCraft = [[CamelCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftRatID: {
						RatCraftObject* newCraft = [[RatCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftSpiderID: {
						SpiderCraftObject* newCraft = [[SpiderCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					case kObjectCraftEagleID: {
						EagleCraftObject* newCraft = [[EagleCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newCraft withColliding:YES];
						if (objectIsControlledShip) {
							[newScene setControllingShip:newCraft];
							[newScene setCameraLocation:newCraft.objectLocation];
							[newScene setMiddleOfVisibleScreenToCamera];
						}
						break;
					}
					default:
						NSLog(@"Invalid Craft ID provided <%i>", objectID);
						break;
				} // End switch for specific craft
			} // End Case for craft type
				break;
			default:
				NSLog(@"Invalid object type ID read in (%i)", objectTypeID);
				break;
		} // End switch for object type
	} // Loop ending
	
	[newScene addSmallBrogguts:numberOfSmallBrogguts inBounds:fullMapRect withLocationArray:locationArray]; // Add the small brogguts
	
	[[newScene collisionManager] remakeGenerator];
	[[newScene collisionManager] updateAllMediumBroggutsEdges];
	[locationArray release];
	[array release];
	return [newScene autorelease];
}

- (void)transitionToSceneWithName:(NSString*)sceneName {
	transitionName = sceneName;
	if (currentScene) { // If already in a scene, fade that one out
		isFadingSceneOut = YES;
		fadingRectAlpha = 0.0f;
	} else {
		currentScene = [gameScenes objectForKey:transitionName];
		isFadingSceneIn = YES;
		fadingRectAlpha = 1.0f;
	}
}

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
	if (isFadingSceneIn) {
		if (fadingRectAlpha > 0.0f) {
			fadingRectAlpha -= FADING_RECT_ALPHA_RATE;
		} else {
			isFadingSceneIn = NO;
			fadingRectAlpha = 0.0f;
		}
	}
	
	if (isFadingSceneOut) {
		if (fadingRectAlpha < 1.0f) {
			fadingRectAlpha += FADING_RECT_ALPHA_RATE;
		} else {
			isFadingSceneOut = NO;
			currentScene = [gameScenes objectForKey:transitionName];
			isFadingSceneIn = YES; // If fading out, set fading in to yes
			fadingRectAlpha = 1.0f;
		}
	}
	[currentPlayerProfile updateProfile];
	[currentScene updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
	[currentScene renderScene];
	if (isFadingSceneIn || isFadingSceneOut) {
		enablePrimitiveDraw();
		glColor4f(0.0f, 0.0f, 0.0f, fadingRectAlpha);
		CGRect bounds = [currentScene visibleScreenBounds];
		CGRect fullRect = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
		drawFilledRect(fullRect, Vector2fZero);
		disablePrimitiveDraw();
	}
}


#pragma mark -
#pragma mark Orientation adjustment

- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch inScreenBounds:(CGRect)bounds {
	
	CGPoint touchLocation;
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		touchLocation.x = kPadScreenLandscapeWidth - aTouch.y;
		touchLocation.y = kPadScreenLandscapeHeight - aTouch.x;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		touchLocation.x = aTouch.y;
		touchLocation.y = aTouch.x;
	}
	
	// Adjust for the scrolling, as this is just a location in the viewport
	touchLocation.x += bounds.origin.x;
	touchLocation.y += bounds.origin.y;
	
	return touchLocation;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameController (Private)

- (void)initGameController {
	
	NSLog(@"INFO - GameController: Starting game initialization.");
	
	isFadingSceneIn = NO;
	isFadingSceneOut = NO;
	fadingRectAlpha = 0.0f;
	currentScene = nil;
	
	[self loadPlayerProfile];
	
	interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
	
	
	
	// Load the game scenes
	gameScenes = [[NSMutableDictionary alloc] init];
	BroggutScene *scene = [self sceneWithFilename:@"SavedScene.plist"];
	if (!scene) {
		[self createInitialBaseCampLevel];
		scene = [self sceneWithFilename:@"BaseCampSaved.plist"];
	}
	
	[gameScenes setValue:scene forKey:@"BaseCamp"];
	
	// Set the starting scene for the game
	[self transitionToSceneWithName:@"BaseCamp"];
	
	/*
	 [[SoundSingleton sharedSoundSingleton] loadSoundWithKey:@"testSound" soundFile:@"testsound.wav"];
	 [[SoundSingleton sharedSoundSingleton] playSoundWithKey:@"testSound"];
	 */
	NSLog(@"INFO - GameController: Finished game initialization.");
}

@end
