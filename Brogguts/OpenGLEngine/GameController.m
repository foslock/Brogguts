//
//  GameController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameController.h"
#import "OpenGLEngineAppDelegate.h"
#import "BroggutScene.h"
#import "BaseCampScene.h"
#import "CollisionManager.h"
#import "PlayerProfile.h"
#import "StructureObject.h"
#import "CraftObject.h"
#import "AntCraftObject.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private) 
// Initializes OpenGL
- (void)initGameController;

@end

static GameController* sharedGameController = nil;

@implementation GameController

@synthesize currentPlayerProfile;
@synthesize currentScene;
@synthesize gameScenes;
@synthesize eaglView;
@synthesize interfaceOrientation;

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
	[currentScene release];
    [gameScenes release];
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
	return [filePath retain];
}

- (void)createBaseCampLevel {
	int width = 128;
	int height = 96;
	
	NSMutableArray* plistArray = [[NSMutableArray alloc] init];
	[plistArray insertObject:[NSString stringWithFormat:@"Base Camp"] atIndex:0];
	[plistArray insertObject:[NSNumber numberWithBool:YES] atIndex:1];
	[plistArray insertObject:[NSNumber numberWithInt:width] atIndex:2];
	[plistArray insertObject:[NSNumber numberWithInt:height] atIndex:3];
	[plistArray insertObject:[NSNumber numberWithInt:500] atIndex:4];
	
	for (int j = 0; j < height; j++) {
		for (int i = 0; i < width; i++) {
			int straightIndex = i + (j * width);
			NSMutableArray* cellArray = [[NSMutableArray alloc] init];
			
			if (i == 1 && j == 13) { // Add the initial craft
				[cellArray insertObject:[NSNumber numberWithInt:kObjectTypeCraft] atIndex:0];
				[cellArray insertObject:[NSNumber numberWithInt:kObjectCraftAntID] atIndex:1];
				[cellArray insertObject:[NSNumber numberWithInt:kAllianceFriendly] atIndex:2];
				[cellArray insertObject:[NSNumber numberWithBool:YES] atIndex:3]; // Control this ship?
				[cellArray insertObject:[NSNumber numberWithFloat:0.0f] atIndex:4]; // Rotation
			} else if ( (i == 2 || i == 3) && j == 13) { // Add two other craft
				[cellArray insertObject:[NSNumber numberWithInt:kObjectTypeCraft] atIndex:0];
				[cellArray insertObject:[NSNumber numberWithInt:kObjectCraftAntID] atIndex:1];
				[cellArray insertObject:[NSNumber numberWithInt:kAllianceFriendly] atIndex:2];
				[cellArray insertObject:[NSNumber numberWithBool:NO] atIndex:3]; // Control this ship?
				[cellArray insertObject:[NSNumber numberWithFloat:135.0f] atIndex:4]; // Rotation
			} else if (i == 10 && j == 10) {
				[cellArray insertObject:[NSNumber numberWithInt:kObjectTypeCraft] atIndex:0];
				[cellArray insertObject:[NSNumber numberWithInt:kObjectCraftAntID] atIndex:1];
				[cellArray insertObject:[NSNumber numberWithInt:kAllianceEnemy] atIndex:2];
				[cellArray insertObject:[NSNumber numberWithBool:NO] atIndex:3]; // Control this ship?
				[cellArray insertObject:[NSNumber numberWithFloat:135.0f] atIndex:4]; // Rotation
			} else if (i == 0 && j == 13) { // Add the initial structure
				[cellArray insertObject:[NSNumber numberWithInt:kObjectTypeStructure] atIndex:0];
				[cellArray insertObject:[NSNumber numberWithInt:kObjectStructureBaseStationID] atIndex:1];
				[cellArray insertObject:[NSNumber numberWithInt:kAllianceFriendly] atIndex:2];
			} else if ((j > 9 && j < 16) && (i > 9 && i < 20)) { // Create some medium brogguts
				[cellArray insertObject:[NSNumber numberWithInt:kObjectTypeBroggut] atIndex:0];
				[cellArray insertObject:[NSNumber numberWithInt:kObjectBroggutMediumID] atIndex:1];
				int value = kBroggutYoungMediumMinValue + (arc4random() % (kBroggutYoungMediumMaxValue - kBroggutYoungMediumMinValue));
				[cellArray insertObject:[NSNumber numberWithInt:value] atIndex:2];
			} else {
				[cellArray insertObject:[NSNumber numberWithInt:-1] atIndex:0];
			}
			
			[plistArray insertObject:cellArray atIndex:straightIndex + 5];
			[cellArray release];
		}
	}
	
	NSString* filePath = [self documentsPathWithFilename:@"BaseCampSaved.plist"];
	if (![plistArray writeToFile:filePath atomically:YES]) {
		NSLog(@"Cannot save the new level!");
	};
	[plistArray release];
}

- (BroggutScene*)sceneFromLevelWithFilename:(NSString*)filename {
	NSString* filePath = [self documentsPathWithFilename:filename];
	if (!filePath) {
		NSLog(@"Scene '%@.plist' not found", filename);
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
	
	CGRect fullMapRect = CGRectMake(0, 0, COLLISION_CELL_WIDTH * cellsWide, COLLISION_CELL_HEIGHT * cellsHigh);
	CGRect visibleRect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
	
	if (baseCamp) {
		newScene = [[BroggutScene alloc] initWithScreenBounds:visibleRect withFullMapBounds:fullMapRect withName:sceneName];
		self.currentScene = newScene;
	}
	NSMutableArray* locationArray = [[NSMutableArray alloc] init];
	
	for (int j = 0; j < cellsHigh; j++) {
		for (int i = 0; i < cellsWide; i++) {
			NSMutableArray* pointArray = [[NSMutableArray alloc] init];
			float currentX = (i * COLLISION_CELL_WIDTH) + (COLLISION_CELL_WIDTH / 2);
			float currentY = (j * COLLISION_CELL_HEIGHT) + (COLLISION_CELL_HEIGHT / 2);
			CGPoint currentPoint = CGPointMake(currentX, currentY);
			int straightIndex = i + (j * cellsWide);
			
			NSArray* currentArray = [array objectAtIndex:straightIndex + 5];
			int idOfObject = [[currentArray objectAtIndex:0] intValue];
			int objectType = 0;
			// Make the potential pointers outside of switch
			MediumBroggut* broggut; 
			switch (idOfObject) {
				case (-1):
					// Nothing located in that cell
					broggut = [[newScene collisionManager] broggutCellForLocation:currentPoint];
					broggut->broggutValue = [[currentArray objectAtIndex:0] intValue];
					[pointArray addObject:[NSNumber numberWithFloat:currentX]];
					[pointArray addObject:[NSNumber numberWithFloat:currentY]];
					[locationArray addObject:pointArray];
					break;
				case kObjectTypeBroggut:
					// Change the broggut at that location to what's saved
					broggut = [[newScene collisionManager] broggutCellForLocation:currentPoint];
					broggut->broggutAge = [[currentArray objectAtIndex:1] intValue];
					broggut->broggutValue = [[currentArray objectAtIndex:2] intValue];
					if (broggut->broggutValue != -1) {
						[[newScene collisionManager] addMediumBroggut];
					}
					break;
				case kObjectTypeCraft:
					// Create a craft at that location with the appropriate type and rotation
					objectType = [[currentArray objectAtIndex:1] intValue];
					AntCraftObject* newCraft = [[AntCraftObject alloc]
											 initWithLocation:currentPoint isTraveling:NO];
					[newCraft setObjectAlliance:[[currentArray objectAtIndex:2] intValue]];
					[newCraft setObjectRotation:[[currentArray objectAtIndex:3] floatValue]];
					[newScene addTouchableObject:newCraft withColliding:YES];
					if ([[currentArray objectAtIndex:3] boolValue]) {
						[newScene setControllingShip:newCraft];
						[newScene setCameraLocation:newCraft.objectLocation];
						[newScene setMiddleOfVisibleScreenToCamera];
					}
					break;
				case kObjectTypeStructure:
					// Create a structure at that location with the appropriate type
					objectType = [[currentArray objectAtIndex:1] intValue];
					StructureObject* newStructure = [[StructureObject alloc]
													 initWithTypeID:objectType withLocation:currentPoint isTraveling:NO];
					[newStructure setObjectAlliance:[[currentArray objectAtIndex:2] intValue]];
					[newScene addTouchableObject:newStructure withColliding:YES];
					if (objectType == kObjectStructureBaseStationID) {
						newScene.homeBaseLocation = currentPoint;
					}
					break;
				default:
					break;
			}
			[pointArray release];
		}
	}
	
	[newScene addSmallBrogguts:numberOfSmallBrogguts inBounds:fullMapRect withLocationArray:locationArray]; // Add the small brogguts
	[[newScene collisionManager] remakeGenerator];
	[[newScene collisionManager] updateAllMediumBroggutsEdges];
	[locationArray release];
	[array release];
	return [newScene autorelease];
}

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
	[currentPlayerProfile updateProfile];
    [currentScene updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
    [currentScene renderScene];
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
	
	[self loadPlayerProfile];
	
	interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
	
	[self createBaseCampLevel];
	
	// Load the game scenes
    gameScenes = [[NSMutableDictionary alloc] init];
	BroggutScene *scene = [self sceneFromLevelWithFilename:@"BaseCampSaved.plist"];
	[gameScenes setValue:scene forKey:@"BaseCamp"];
    
    // Set the starting scene for the game
    currentScene = [gameScenes objectForKey:@"BaseCamp"];
	
    NSLog(@"INFO - GameController: Finished game initialization.");
}

@end
