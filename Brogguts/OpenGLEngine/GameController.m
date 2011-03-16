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
#pragma mark Scene storage 

enum kSceneStorageGlobals {
    kSceneStorageGlobalName,
    kSceneStorageGlobalBaseCamp,
    kSceneStorageGlobalWidthCells,
    kSceneStorageGlobalHeightCells,
    kSceneStorageGlobalSmallBrogguts,
    kSceneStorageGlobalAIController,
    kSceneStorageGlobalMediumBroggutArray,
    kSceneStorageGlobalObjectArray,
};

enum kSceneStorageIndexs {
	kSceneStorageIndexTypeID, // - object type ID
	kSceneStorageIndexID, // - object ID
	kSceneStorageIndexPath, // - Current path
	kSceneStorageIndexAlliance, // - Alliance
	kSceneStorageIndexRotation, // - Rotation
	kSceneStorageIndexTraveling, // - isTraveling
	kSceneStorageIndexEndLoc, // - ^^ end location
	kSceneStorageIndexCurrentLoc, // - Current location
	kSceneStorageIndexHull, // - Current Hull
	kSceneStorageIndexControlledShip, // - isControlledShip
	kSceneStorageIndexMining, // - if mining
	kSceneStorageIndexMiningLoc, // - mining location
	kSceneStorageIndexCargo, // - broggut cargo
};

NSString* kBaseCampFileName = @"BaseCampSaved.plist";
NSString* kSavedScenesFileName = @"SavedScenesList.plist";
NSString* kNewMapScenesFileName = @"NewMapScenesList.plist";

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

- (BOOL)doesFilenameExistInDocuments:(NSString*)filename {
    NSString* filePath = [self documentsPathWithFilename:filename];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (fileExists) {
		return YES;
	} else {
        return NO;
    }
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

- (void)placeInitialFilesInDocumentsFolder {
    NSString* oldFilePath = [[NSBundle mainBundle] pathForResource:@"NewMapScenesList" ofType:@"plist"];
    NSArray* tempMapPlist = [NSArray arrayWithContentsOfFile:oldFilePath];
    if (tempMapPlist) {
        for (NSString* mapName in tempMapPlist) {
            NSString* mapNamePath = [[NSBundle mainBundle] pathForResource:mapName ofType:@"plist"];
            NSArray* mapArray = [NSArray arrayWithContentsOfFile:mapNamePath];
            if (mapArray) {
                NSString* newFileName = [mapName stringByAppendingString:@".plist"];
                [mapArray writeToFile:[self documentsPathWithFilename:newFileName] atomically:YES];
            }
        }
        NSString* newFilePath = [self documentsPathWithFilename:kNewMapScenesFileName];
        [tempMapPlist writeToFile:newFilePath atomically:YES];  
    }
    
    if (![self doesFilenameExistInDocuments:kSavedScenesFileName]) {
        NSArray* newArray = [[NSArray alloc] init];
        NSString* path = [self documentsPathWithFilename:kSavedScenesFileName];
        [newArray writeToFile:path atomically:YES];
        [newArray release];
    }
    
    if (![self doesFilenameExistInDocuments:kBaseCampFileName]) {
        [self createInitialBaseCampLevel];
    }
}

- (void)createBlankSceneWithWidthCells:(int)width withHeightCells:(int)height withName:(NSString*)name {
    NSString* sceneTitle = name;
	BOOL isBaseCamp = NO;
	int widthCells = width;
	int heightCells = height;
	int numberOfSmallBrogguts = 0;
	
	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:sceneTitle atIndex:kSceneStorageGlobalName];
	[plistArray insertObject:[NSNumber numberWithBool:isBaseCamp] atIndex:kSceneStorageGlobalBaseCamp];
	[plistArray insertObject:[NSNumber numberWithInt:widthCells] atIndex:kSceneStorageGlobalWidthCells];
	[plistArray insertObject:[NSNumber numberWithInt:heightCells] atIndex:kSceneStorageGlobalHeightCells];
	[plistArray insertObject:[NSNumber numberWithInt:numberOfSmallBrogguts] atIndex:kSceneStorageGlobalSmallBrogguts];
    NSArray* tempArray = [[NSArray alloc] init];
    [plistArray insertObject:tempArray atIndex:kSceneStorageGlobalAIController];
    [tempArray release];
    
    NSMutableArray* broggutArray = [[NSMutableArray alloc] initWithCapacity:widthCells * heightCells];
	for (int j = 0; j < heightCells; j++) {
		for (int i = 0; i < widthCells; i++) {
			int straightIndex = i + (j * widthCells);
			NSMutableArray* thisBroggutInfo = [[NSMutableArray alloc] init];
			NSNumber* broggutValue;
			NSNumber* broggutAge;
            broggutValue = [NSNumber numberWithInt:-1];
            broggutAge = [NSNumber numberWithInt:0];
			[thisBroggutInfo insertObject:broggutValue atIndex:0];
			[thisBroggutInfo insertObject:broggutAge atIndex:1];
			[broggutArray insertObject:thisBroggutInfo atIndex:straightIndex];
			[thisBroggutInfo release];
		}
	}
	[plistArray insertObject:broggutArray atIndex:kSceneStorageGlobalMediumBroggutArray];
	[broggutArray release];
    
    NSMutableArray* finalObjectArray = [[NSMutableArray alloc] init];
    [plistArray insertObject:finalObjectArray atIndex:kSceneStorageGlobalObjectArray];
    [finalObjectArray release];
    NSString* fileName = [name stringByAppendingString:@".plist"];
	NSString* filePath = [self documentsPathWithFilename:fileName];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the empty Scene!");
	}
	[plistArray release];
}

- (void)createInitialBaseCampLevel {
	NSString* sceneTitle = @"Base Camp";
	BOOL isBaseCamp = YES;
	int widthCells = 64;
	int heightCells = 48;
	int numberOfSmallBrogguts = 500;
	
	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:sceneTitle atIndex:kSceneStorageGlobalName];
	[plistArray insertObject:[NSNumber numberWithBool:isBaseCamp] atIndex:kSceneStorageGlobalBaseCamp];
	[plistArray insertObject:[NSNumber numberWithInt:widthCells] atIndex:kSceneStorageGlobalWidthCells];
	[plistArray insertObject:[NSNumber numberWithInt:heightCells] atIndex:kSceneStorageGlobalHeightCells];
	[plistArray insertObject:[NSNumber numberWithInt:numberOfSmallBrogguts] atIndex:kSceneStorageGlobalSmallBrogguts];
    NSArray* tempArray = [[NSArray alloc] init];
    [plistArray insertObject:tempArray atIndex:kSceneStorageGlobalAIController];
    [tempArray release];
	
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
	[plistArray insertObject:broggutArray atIndex:kSceneStorageGlobalMediumBroggutArray];
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
		int objectCurrentCargo = 0;
		
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:kSceneStorageIndexTypeID];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectID] atIndex:kSceneStorageIndexID];
		[thisStructureArray insertObject:objectCurrentPath atIndex:kSceneStorageIndexPath];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:kSceneStorageIndexAlliance];
		[thisStructureArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:kSceneStorageIndexRotation];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:kSceneStorageIndexTraveling];
		[self insertCGPoint:objectEndLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexEndLoc];
		[self insertCGPoint:objectCurrentLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexCurrentLoc];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:kSceneStorageIndexHull];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:kSceneStorageIndexControlledShip];
		[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:kSceneStorageIndexMining];
		[self insertCGPoint:objectMiningLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexMiningLoc];
		[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentCargo] atIndex:kSceneStorageIndexCargo];
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
		int objectCurrentCargo = 0;
		
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:kSceneStorageIndexTypeID];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectID] atIndex:kSceneStorageIndexID];
		[thisCraftArray insertObject:objectCurrentPath atIndex:kSceneStorageIndexPath];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:kSceneStorageIndexAlliance];
		[thisCraftArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:kSceneStorageIndexRotation];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:kSceneStorageIndexTraveling];
		[self insertCGPoint:objectEndLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexEndLoc];
		[self insertCGPoint:objectCurrentLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexCurrentLoc];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:kSceneStorageIndexHull];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:kSceneStorageIndexControlledShip];
		[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:kSceneStorageIndexMining];
		[self insertCGPoint:objectMiningLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexMiningLoc];
		[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentCargo] atIndex:kSceneStorageIndexCargo];
		[finalObjectArray addObject:thisCraftArray];
		[thisCraftArray release];
		[objectCurrentPath release];
	}
	
	// Create a bunch of enemies to try to kill
	for (int i = 0; i < 100; i++) {
        for (int j = 0; j < 1; j++) {
            NSMutableArray* thisCraftArray = [[NSMutableArray alloc] init];
            
            int objectTypeID = kObjectTypeCraft;
            int objectID = kObjectCraftAntID;
            NSArray* objectCurrentPath = [[NSArray alloc] init]; // NIL for now
            int objectAlliance = kAllianceEnemy;
            float objectRotation = 360 * RANDOM_MINUS_1_TO_1();
            BOOL objectIsTraveling = NO;
            CGPoint objectEndLocation = CGPointMake((100 + j) * COLLISION_CELL_WIDTH / 2, (i + 5) * COLLISION_CELL_HEIGHT / 2);
            CGPoint objectCurrentLocation = objectEndLocation;
            int objectCurrentHull = -1; // Means full
            BOOL objectIsControlledShip = NO;
            BOOL objectIsMining = NO;
            CGPoint objectMiningLocation = CGPointZero;
            int objectCurrentCargo = 0;
            
            [thisCraftArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:kSceneStorageIndexTypeID];
            [thisCraftArray insertObject:[NSNumber numberWithInt:objectID] atIndex:kSceneStorageIndexID];
            [thisCraftArray insertObject:objectCurrentPath atIndex:kSceneStorageIndexPath];
            [thisCraftArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:kSceneStorageIndexAlliance];
            [thisCraftArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:kSceneStorageIndexRotation];
            [thisCraftArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:kSceneStorageIndexTraveling];
            [self insertCGPoint:objectEndLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexEndLoc];
            [self insertCGPoint:objectCurrentLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexCurrentLoc];
            [thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:kSceneStorageIndexHull];
            [thisCraftArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:kSceneStorageIndexControlledShip];
            [thisCraftArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:kSceneStorageIndexMining];
            [self insertCGPoint:objectMiningLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexMiningLoc];
            [thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentCargo] atIndex:kSceneStorageIndexCargo];
            [finalObjectArray addObject:thisCraftArray];
            [thisCraftArray release];
            [objectCurrentPath release];
        }
    }
	
	[plistArray insertObject:finalObjectArray atIndex:kSceneStorageGlobalObjectArray];
    [finalObjectArray release];
	NSString* filePath = [self documentsPathWithFilename:kBaseCampFileName];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the Base Camp Scene!");
	}
	[plistArray release];
}

- (BOOL)saveCurrentSceneWithFilename:(NSString*)filename allowOverwrite:(BOOL)overwrite {
    if ([self doesFilenameExistInDocuments:filename] && !overwrite) {
        NSLog(@"Scene filename: %@, already exists", filename);
        return NO;
    }
	
	NSString* sceneTitle = currentScene.sceneName;
	BOOL isBaseCamp = currentScene.isBaseCamp;
	int widthCells = currentScene.widthCells;
	int heightCells = currentScene.heightCells;
	int numberOfSmallBrogguts = currentScene.numberOfSmallBrogguts;

	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:sceneTitle atIndex:kSceneStorageGlobalName];
	[plistArray insertObject:[NSNumber numberWithBool:isBaseCamp] atIndex:kSceneStorageGlobalBaseCamp];
	[plistArray insertObject:[NSNumber numberWithInt:widthCells] atIndex:kSceneStorageGlobalWidthCells];
	[plistArray insertObject:[NSNumber numberWithInt:heightCells] atIndex:kSceneStorageGlobalHeightCells];
	[plistArray insertObject:[NSNumber numberWithInt:numberOfSmallBrogguts] atIndex:kSceneStorageGlobalSmallBrogguts];
    NSArray* tempArray = [[NSArray alloc] init];
    [plistArray insertObject:tempArray atIndex:kSceneStorageGlobalAIController];
    [tempArray release];
	
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
	[plistArray insertObject:broggutArray atIndex:kSceneStorageGlobalMediumBroggutArray];
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
			BOOL objectIsMining = NO; // Since it is a structure
			CGPoint objectMiningLocation = CGPointZero;
			int objectCurrentCargo = 0;
			
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:kSceneStorageIndexTypeID];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectID] atIndex:kSceneStorageIndexID];
			[thisStructureArray insertObject:objectCurrentPath atIndex:kSceneStorageIndexPath];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:kSceneStorageIndexAlliance];
			[thisStructureArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:kSceneStorageIndexRotation];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:kSceneStorageIndexTraveling];
			[self insertCGPoint:objectEndLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexEndLoc];
			[self insertCGPoint:objectCurrentLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexCurrentLoc];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:kSceneStorageIndexHull];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:kSceneStorageIndexControlledShip];
			[thisStructureArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:kSceneStorageIndexMining];
			[self insertCGPoint:objectMiningLocation intoArray:thisStructureArray atIndex:kSceneStorageIndexMiningLoc];
			[thisStructureArray insertObject:[NSNumber numberWithInt:objectCurrentCargo] atIndex:kSceneStorageIndexCargo];
			if (objectID == kObjectStructureBaseStationID) {
				[finalObjectArray insertObject:thisStructureArray atIndex:0];
			} else {
				[finalObjectArray addObject:thisStructureArray];
			}
			[thisStructureArray release];
			[objectCurrentPath release];
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
			CGPoint objectMiningLocation = [thisCraft miningLocation];
			int objectCurrentCargo = [thisCraft attributePlayerCurrentCargo];
			if (thisCraft.movingAIState == kMovingAIStateMining) {
				objectIsMining = YES;
			}
            
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectTypeID] atIndex:kSceneStorageIndexTypeID];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectID] atIndex:kSceneStorageIndexID];
			[thisCraftArray insertObject:objectCurrentPath atIndex:kSceneStorageIndexPath];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectAlliance] atIndex:kSceneStorageIndexAlliance];
			[thisCraftArray insertObject:[NSNumber numberWithFloat:objectRotation] atIndex:kSceneStorageIndexRotation];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsTraveling] atIndex:kSceneStorageIndexTraveling];
			[self insertCGPoint:objectEndLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexEndLoc];
			[self insertCGPoint:objectCurrentLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexCurrentLoc];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentHull] atIndex:kSceneStorageIndexHull];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsControlledShip] atIndex:kSceneStorageIndexControlledShip];
			[thisCraftArray insertObject:[NSNumber numberWithBool:objectIsMining] atIndex:kSceneStorageIndexMining];
			[self insertCGPoint:objectMiningLocation intoArray:thisCraftArray atIndex:kSceneStorageIndexMiningLoc];
			[thisCraftArray insertObject:[NSNumber numberWithInt:objectCurrentCargo] atIndex:kSceneStorageIndexCargo];
			[finalObjectArray addObject:thisCraftArray];
			[thisCraftArray release];
			[objectCurrentPath release];
		}
	}
	
	[plistArray insertObject:finalObjectArray atIndex:kSceneStorageGlobalObjectArray];
    [finalObjectArray release];
    NSString* fileNameAlone = [filename stringByDeletingPathExtension];
    NSString* fileNameExt = [fileNameAlone stringByAppendingString:@".plist"];
	NSString* filePath = [self documentsPathWithFilename:fileNameExt];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the current Scene!");
        [plistArray release];
        return NO;
	}
    if (!currentScene.isBaseCamp) {
        [self addFilenameToSceneFileList:filename];
    }
    [plistArray release];
    return YES;
}

- (BroggutScene*)sceneWithFilename:(NSString*)filename {
    NSString* fileNameExt = [filename stringByAppendingString:@".plist"];
	NSString* filePath = [self documentsPathWithFilename:fileNameExt];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	if (!fileExists) {
		NSLog(@"Scene '%@' not found", filename);
		return nil;
	}
	
	NSArray* array = [[NSArray alloc] initWithContentsOfFile:filePath];
	BroggutScene* newScene;
	
	// First four objects in the array are as follows:
	NSString* sceneName = [array objectAtIndex:kSceneStorageGlobalName];                            // 0: NSString - Name of the scene/level
	BOOL baseCamp = [[array objectAtIndex:kSceneStorageGlobalBaseCamp] boolValue];                  // 1: BOOL - BaseCamp
	int cellsWide = [[array objectAtIndex:kSceneStorageGlobalWidthCells] intValue];                 // 2: int - Width (in cells) of the map
	int cellsHigh = [[array objectAtIndex:kSceneStorageGlobalHeightCells] intValue];				// 3: int - Height (in cells) of the map
	int numberOfSmallBrogguts = [[array objectAtIndex:kSceneStorageGlobalSmallBrogguts] intValue];	// 4: int - Number of small brogguts to be created
	NSArray* broggutArray = [array objectAtIndex:kSceneStorageGlobalMediumBroggutArray];			// 6: NSArray - the information for all of the medium brogguts
	NSArray* objectArray = [array objectAtIndex:kSceneStorageGlobalObjectArray];					// 7: NSArray - " " objects
    NSArray* AIArray = [array objectAtIndex:kSceneStorageGlobalAIController];                       // 8: NSArray - AI Controller information;
    (void)AIArray;
	
	CGRect fullMapRect = CGRectMake(0, 0, COLLISION_CELL_WIDTH * cellsWide, COLLISION_CELL_HEIGHT * cellsHigh);
	CGRect visibleRect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
    
    newScene = [[BroggutScene alloc] initWithScreenBounds:visibleRect withFullMapBounds:fullMapRect withName:sceneName];
    self.currentScene = newScene;
    self.currentScene.isBaseCamp = baseCamp;
    
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
		int objectTypeID = [[currentObjectInfo objectAtIndex:kSceneStorageIndexTypeID] intValue];
		int objectID = [[currentObjectInfo objectAtIndex:kSceneStorageIndexID] intValue];
		// NSArray* objectCurrentPath = [currentObjectInfo objectAtIndex:kSceneStorageIndexPath];
		int objectAlliance = [[currentObjectInfo objectAtIndex:kSceneStorageIndexAlliance] intValue];
		float objectRotation = [[currentObjectInfo objectAtIndex:kSceneStorageIndexRotation] floatValue];
		BOOL objectIsTraveling = [[currentObjectInfo objectAtIndex:kSceneStorageIndexTraveling] boolValue];
		CGPoint objectEndLocation = [self getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexEndLoc];
		CGPoint objectCurrentLocation = [self getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexCurrentLoc];
		int objectCurrentHull = [[currentObjectInfo objectAtIndex:kSceneStorageIndexHull] intValue];
		BOOL objectIsControlledShip = [[currentObjectInfo objectAtIndex:kSceneStorageIndexControlledShip] boolValue];
		BOOL objectIsMining = [[currentObjectInfo objectAtIndex:kSceneStorageIndexMining] boolValue];
		CGPoint objectMiningLocation = [self getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexMiningLoc];
		int objectCurrentCargo = [[currentObjectInfo objectAtIndex:kSceneStorageIndexCargo] intValue];
		
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
						[newScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
						if (newStructure.objectAlliance == kAllianceFriendly) {
							newScene.homeBaseLocation = objectEndLocation;
						}
						if (newStructure.objectAlliance == kAllianceEnemy) {
							newScene.enemyBaseLocation = objectEndLocation;
						}
                        [newStructure release];
						break;
					}
					case kObjectStructureBlockID: {
						BlockStructureObject* newStructure = [[BlockStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                        [newStructure release];
						break;
					}
					case kObjectStructureTurretID: {
						TurretStructureObject* newStructure = [[TurretStructureObject alloc]
															   initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                        [newStructure release];
						break;
					}
					case kObjectStructureRadarID: {
						RadarStructureObject* newStructure = [[RadarStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                        [newStructure release];
						break;
					}
					case kObjectStructureFixerID: {
						FixerStructureObject* newStructure = [[FixerStructureObject alloc]
															  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newStructure setObjectAlliance:objectAlliance];
						[newStructure setObjectLocation:objectCurrentLocation];
						[newStructure setCurrentHull:objectCurrentHull];
						[newScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                        [newStructure release];
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
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
						if (objectIsMining) {
							[newCraft tryMiningBroggutsWithCenter:objectMiningLocation];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftMothID: {
						MothCraftObject* newCraft = [[MothCraftObject alloc]
													 initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftBeetleID: {
						BeetleCraftObject* newCraft = [[BeetleCraftObject alloc]
													   initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
							[newScene setCameraLocation:objectEndLocation];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftMonarchID: {
						MonarchCraftObject* newCraft = [[MonarchCraftObject alloc]
														initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftCamelID: {
						CamelCraftObject* newCraft = [[CamelCraftObject alloc]
                                                      initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
						if (objectIsMining) {
							[newCraft tryMiningBroggutsWithCenter:objectMiningLocation];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftRatID: {
						RatCraftObject* newCraft = [[RatCraftObject alloc]
                                                    initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftSpiderID: {
						SpiderCraftObject* newCraft = [[SpiderCraftObject alloc]
                                                       initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
                        [newCraft release];
						break;
					}
					case kObjectCraftEagleID: {
						EagleCraftObject* newCraft = [[EagleCraftObject alloc]
                                                      initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
						[newCraft setObjectAlliance:objectAlliance];
						[newCraft setObjectRotation:objectRotation];
						[newCraft setObjectLocation:objectCurrentLocation];
						[newCraft setCurrentHull:objectCurrentHull];
						[newCraft addCargo:objectCurrentCargo];
						[newScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
						if (objectIsControlledShip) {
							[newScene addControlledCraft:newCraft];
						}
                        [newCraft release];
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

- (void)addFilenameToSceneFileList:(NSString*)filename {
    if ([filename caseInsensitiveCompare:kBaseCampFileName] == NSOrderedSame) { // don't worry about this for basecamp saving
        return;
    }
    NSString* filePath = [self documentsPathWithFilename:kSavedScenesFileName];
    NSMutableArray* plistArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    
    BOOL duplicate = NO;
    for (NSString* other in plistArray) {
        if ([filename caseInsensitiveCompare:other] == NSOrderedSame) {
            duplicate = YES;
        }
    }
    if (!duplicate) {
        [plistArray addObject:filename];
    } else {
        NSLog(@"Filename already exists!");
    }
    
    if (![plistArray writeToFile:filePath atomically:YES]) {
        NSLog(@"Failed to saved the scene name: %@", filename);
    }
    [plistArray release];
}

- (void)transitionToSceneWithFileName:(NSString*)fileName {
    BroggutScene* scene = [gameScenes objectForKey:fileName];
    if (!scene) {
        BroggutScene* newScene = [self sceneWithFilename:fileName];
        [gameScenes setValue:newScene forKey:fileName];
        scene = newScene;
    }
    if (scene) {
        transitionName = fileName;
        if (isAlreadyInScene) { // If already in a scene, fade that one out
            isFadingSceneOut = YES;
            fadingRectAlpha = 0.0f;
        } else {
            // isAlreadyInScene = YES;
            [(OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate] startGLAnimation];
            currentScene = [gameScenes objectForKey:transitionName];
            [currentScene sceneDidAppear];
            isFadingSceneIn = YES;
            fadingRectAlpha = 1.0f;
        }
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
	
	CGPoint touchLocation = CGPointZero;
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		touchLocation.x = kPadScreenLandscapeWidth - aTouch.y;
		touchLocation.y = kPadScreenLandscapeHeight - aTouch.x;
	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
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
	fadingRectAlpha = 1.0f;
	currentScene = nil;
	isAlreadyInScene = NO;
	
	[self loadPlayerProfile];
    [self placeInitialFilesInDocumentsFolder];
	
	interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
	
	// Load the game scenes
	gameScenes = [[NSMutableDictionary alloc] init];
	
	/*
	 [[SoundSingleton sharedSoundSingleton] loadSoundWithKey:@"testSound" soundFile:@"testsound.wav"];
	 [[SoundSingleton sharedSoundSingleton] playSoundWithKey:@"testSound"];
	 */
	NSLog(@"INFO - GameController: Finished game initialization.");
}

@end
