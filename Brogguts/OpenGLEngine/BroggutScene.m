//
//  BroggutScene.m
//  Brogguts
//
//  Created by Foster Lockwood
//  Copyright 2009 Games in Dorms. All rights reserved.
//

#import "BroggutScene.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"
#import "GameCenterSingleton.h"
#import "SoundSingleton.h"
#import "BitmapFont.h"
#import "ParticleEmitter.h"
#import "GameCenterStructs.h"
#import "StarSingleton.h"
#import "CollisionManager.h"
#import "CollidableObject.h"
#import "BitmapFont.h"
#import "TouchableObject.h"
#import "TextObject.h"
#import "ControllableObject.h"
#import "SideBarController.h"
#import "BroggutObject.h"
#import "PlayerProfile.h"
#import "CraftObject.h"
#import "ParticleSingleton.h"
#import "CraftAndStructures.h"
#import "AIController.h"
#import "TextureSingleton.h"
#import "ExplosionObject.h"
#import "BuildingObject.h"
#import "EndMissionObject.h"
#import "NotificationObject.h"

NSString* kHelpMessagesTextArray[HELP_MESSAGE_COUNT] = {
    @"You must mine more Brogguts",
    @"You must refine more Metal",
    @"You must collect more Brogguts and Metal",
    @"You must build only in empty space",
    @"You've reached the maximum number of structures",
    @"You've reached the maximum number of craft",
    @"You must only mine brogguts on edges",
    @"Build more Blocks to allow more ships",
};

@implementation BroggutScene

@synthesize sceneName, sceneFileName, sceneType;
@synthesize collisionManager;
@synthesize cameraContainRect, cameraLocation;
@synthesize fullMapBounds, visibleScreenBounds;
@synthesize isShowingOverview, isBuildingStructure;
@synthesize commandingShip;
@synthesize homeBaseLocation, enemyBaseLocation, sideBar;
@synthesize fontArray, broggutCounter, metalCounter, supplyCounter;
@synthesize touchableObjects;
@synthesize widthCells, heightCells, numberOfSmallBrogguts;
@synthesize isMultiplayerMatch, isMissionOver;
@synthesize isShowingBuildingValues, currentBuildBroggutCost, currentBuildDragLocation, currentBuildMetalCost;
@synthesize numberOfRefineries, isAllowingCraft, isAllowingStructures;
@synthesize isShowingNotification, notification, numberOfEnemyShips, numberOfEnemyStructures;
@synthesize numberOfBlocks;

- (void)initializeWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName {
    // Grab an instance of the render manager
    sharedGameController = [GameController sharedGameController];
    sharedImageRenderSingleton = [ImageRenderSingleton sharedImageRenderSingleton];
    sharedSoundSingleton = [SoundSingleton sharedSoundSingleton];
    sharedGameCenterSingleton = [GameCenterSingleton sharedGCSingleton];
    sharedStarSingleton = [StarSingleton sharedStarSingleton];
    sharedParticleSingleton = [ParticleSingleton sharedParticleSingleton];
    // Clear the texture cache for each new scene
    // [[TextureSingleton sharedTextureSingleton] releaseAllTextures];
    
    if ([sharedGameCenterSingleton currentMatch]) {
        isMultiplayerMatch = YES;
    } else {
        isMultiplayerMatch = NO;
    }
    
    self.sceneName = sName;
    isAllowingSidebar = YES;
    isShowingBroggutCount = YES;
    isShowingMetalCount = YES;
    isShowingSupplyCount = YES;
    isAllowingOverview = YES;
    isAllowingCraft = YES;
    isAllowingStructures = YES;
    isMissionOver = NO;
    isBuildingStructure = NO;
    endMissionObject = [[EndMissionObject alloc] init];
    fadeBackgroundAlpha = 0.0f;
    didAddBrogguts = NO;
    renderableObjects = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
    renderableDestroyed = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
    touchableObjects = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
    textObjectArray = [[NSMutableArray alloc] initWithCapacity:INITIAL_OBJECT_CAPACITY];
    currentObjectsTouching = [[NSMutableDictionary alloc] initWithCapacity:11];
    currentObjectsHovering = [[NSMutableDictionary alloc] initWithCapacity:11];
    currentTouchesInSideBar = [[NSMutableDictionary alloc] initWithCapacity:11];
    collisionManager = [[CollisionManager alloc] initWithContainingRect:mapBounds WithCellWidth:COLLISION_CELL_WIDTH withHeight:COLLISION_CELL_HEIGHT];
    [collisionManager setCurrentScene:self];
    widthCells = mapBounds.size.width / COLLISION_CELL_WIDTH;
    heightCells = mapBounds.size.height / COLLISION_CELL_HEIGHT;
    visibleScreenBounds = screenBounds;
    fullMapBounds = mapBounds;
    cameraContainRect = CGRectInset(screenBounds, SCROLL_BOUNDS_X_INSET, SCROLL_BOUNDS_Y_INSET);
    cameraLocation = [self middleOfVisibleScreen];
    controlledShips = [[NSMutableArray alloc] init];
    selectionPointsOne = [[NSMutableArray alloc] init];
    selectionPointsTwo = [[NSMutableArray alloc] init];
    selectionTouchHashOne = -1;
    selectionTouchHashTwo = -1;
    isSelectingShips = NO;
    numberOfCurrentShips = 0;
    numberOfCurrentStructures = 0;
    numberOfSmallBrogguts = 0;
    numberOfRefineries = 0;
    numberOfBlocks = 0;
    currentBlocks = [[NSMutableArray alloc] initWithCapacity:2];
    currentRefineries = [[NSMutableArray alloc] initWithCapacity:4];
    numberOfEnemyShips = 0;
    numberOfEnemyStructures = 0;
    CGPoint helpMessagePoint = CGPointMake(kPadScreenLandscapeWidth / 2, 0.0f);
    helpMessageObject = [[TextObject alloc] initWithFontID:kFontBlairID Text:@"" withLocation:helpMessagePoint withDuration:-1.0f];
    [helpMessageObject setRenderLayer:kLayerHUDBottomLayer];
    messageTimer = 0.0f;
    isShowingMessageTimer = NO;
    isScreenShaking = NO;
    screenShakingAmount = 0.0f;
    /*
     if (!isMultiplayerMatch)
     enemyAIController = [[AIController alloc] initWithTouchableObjects:touchableObjects withPirate:isBaseCamp];
     */
    // Set up the sidebar
    sideBar = [[SideBarController alloc] initWithLocation:CGPointMake(-SIDEBAR_WIDTH, 0.0f) withWidth:SIDEBAR_WIDTH withHeight:screenBounds.size.height];
    
    // Set up the overview map variables
    isShowingOverview = NO;
    isFadingOverviewIn = NO;
    isFadingOverviewOut = NO;
    overviewAlpha = 0.0f;
    
    isShowingNotification = NO;
    
    // Set up fonts
    fontArray = [[NSMutableArray alloc] initWithCapacity:10];
    BitmapFont* gothic = [[BitmapFont alloc]
                          initWithFontImageNamed:@"gothic.png" controlFile:@"gothic" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
    [fontArray insertObject:gothic atIndex:kFontGothicID];
    BitmapFont* blair = [[BitmapFont alloc]
                         initWithFontImageNamed:@"blair.png" controlFile:@"blair" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
    [fontArray insertObject:blair atIndex:kFontBlairID];
    [gothic release];
    [blair release];
    
    NSString* brogCount = [NSString stringWithFormat:@"%i",[sharedGameController currentProfile].broggutCount];
    broggutCounter = [[TextObject alloc]
                      initWithFontID:kFontBlairID Text:brogCount withLocation:CGPointMake(kPadScreenLandscapeWidth - (64 * 5), visibleScreenBounds.size.height - 32) withDuration:-1.0f];
    [broggutCounter setScrollWithBounds:NO];
    [textObjectArray addObject:broggutCounter];
    
    NSString* metalCount = [NSString stringWithFormat:@"%i",[sharedGameController currentProfile].metalCount];
    metalCounter = [[TextObject alloc]
                    initWithFontID:kFontBlairID Text:metalCount withLocation:CGPointMake(kPadScreenLandscapeWidth - (64 * 3), visibleScreenBounds.size.height - 32) withDuration:-1.0f];
    [metalCounter setScrollWithBounds:NO];
    [textObjectArray addObject:metalCounter];
    
    NSString* supplyCount = [NSString stringWithFormat:@"%i/%i", numberOfCurrentShips, [self currentMaxShipSupply]];
    supplyCounter = [[TextObject alloc]
                    initWithFontID:kFontBlairID Text:supplyCount withLocation:CGPointMake(kPadScreenLandscapeWidth - 64, visibleScreenBounds.size.height - 32) withDuration:-1.0f];
    [supplyCounter setScrollWithBounds:NO];
    [textObjectArray addObject:supplyCounter];
    
    broggutIconImage = [[Image alloc] initWithImageNamed:@"broggutsicon.png" filter:GL_LINEAR];
    metalIconImage = [[Image alloc] initWithImageNamed:@"metalicon.png" filter:GL_LINEAR];
    supplyIconImage = [[Image alloc] initWithImageNamed:@"supplyicon.png" filter:GL_LINEAR];
    [broggutIconImage setRenderLayer:kLayerHUDTopLayer];
    [metalIconImage setRenderLayer:kLayerHUDTopLayer];
    [supplyIconImage setRenderLayer:kLayerHUDTopLayer];
    
    float width = [self getWidthForFontID:kFontBlairID withString:@"Wave: 00:00"];
    countdownTimer = [[TextObject alloc]
                      initWithFontID:kFontBlairID Text:@"" withLocation:CGPointMake(kPadScreenLandscapeWidth - (width + 16), kPadScreenLandscapeHeight - 72) withDuration:-1.0f];
    [countdownTimer setRenderLayer:kLayerHUDBottomLayer];
    [countdownTimer setScrollWithBounds:NO];
    [countdownTimer setFontColor:Color4fMake(0.9f, 0.1f, 0.1f, 1.0f)];
    [self addTextObject:countdownTimer];
    
    valueTextObject = [[TextObject alloc]
                       initWithFontID:kFontBlairID Text:@"" withLocation:CGPointZero withDuration:-1.0f];
    [self addTextObject:valueTextObject];
    [valueTextObject setIsTextHidden:YES];
    [valueTextObject setRenderLayer:kLayerTopLayer];
    isShowingValueText = NO;
    
    buildBroggutValue = [[TextObject alloc]
                         initWithFontID:kFontBlairID Text:@"" withLocation:CGPointZero withDuration:-1.0f];
    buildMetalValue = [[TextObject alloc]
                       initWithFontID:kFontBlairID Text:@"" withLocation:CGPointZero withDuration:-1.0f];
    [buildBroggutValue setRenderLayer:kLayerHUDTopLayer];
    [buildMetalValue setRenderLayer:kLayerHUDTopLayer];
    [self addTextObject:buildBroggutValue];
    [self addTextObject:buildMetalValue];
    isShowingBuildingValues = NO;
    currentBuildBroggutCost = 0;
    currentBuildMetalCost = 0;
    
    frameCounter = 0;
    
    cameraImage = [[Image alloc] initWithImageNamed:@"starTexture.png" filter:GL_LINEAR];
}

- (id)initWithFileName:(NSString*)filename wasLoaded:(BOOL)loaded {
    self = [super init];
    if (self) {
        // Get the game controller first
        sharedGameController = [GameController sharedGameController];
        [sharedGameController setJustMadeScene:self];
        
        self.sceneFileName = [NSString stringWithString:filename];
        NSString* fileNameExt = [filename stringByAppendingString:@".plist"];
        NSString* filePath = [sharedGameController documentsPathWithFilename:fileNameExt];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (!fileExists) {
            NSLog(@"Scene '%@' not found", filename);
            return nil;
        }
        
        NSArray* array = [[NSArray alloc] initWithContentsOfFile:filePath];
        
        // First four objects in the array are as follows:
        NSString* thisSceneName = [array objectAtIndex:kSceneStorageGlobalName];                            // 0: NSString - Name of the scene/level
        int thisSceneType = [[array objectAtIndex:kSceneStorageGlobalSceneType] intValue];                  // 1: int - scene type
        int cellsWide = [[array objectAtIndex:kSceneStorageGlobalWidthCells] intValue];                     // 2: int - Width (in cells) of the map
        int cellsHigh = [[array objectAtIndex:kSceneStorageGlobalHeightCells] intValue];                    // 3: int - Height (in cells) of the map
        int newNumberOfSmallBrogguts = [[array objectAtIndex:kSceneStorageGlobalSmallBrogguts] intValue];	// 4: int - Number of small brogguts to be created
        NSArray* broggutArray = [array objectAtIndex:kSceneStorageGlobalMediumBroggutArray];                // 6: NSArray - the information for all of the medium brogguts
        NSArray* objectArray = [array objectAtIndex:kSceneStorageGlobalObjectArray];                        // 7: NSArray - " " objects
        NSArray* AIArray = [array objectAtIndex:kSceneStorageGlobalAIController];                           // 8: NSArray - AI Controller information;
        NSNumber* broggutNumber = nil;
        NSNumber* metalNumber = nil;
        
        if ([AIArray count] != 0) {
            broggutNumber = [AIArray objectAtIndex:kSceneAIControllerBrogguts];
            metalNumber = [AIArray objectAtIndex:kSceneAIControllerMetal];
        }
        
        int currentBrogguts = 0;
        int currentMetal = 0;
        
        if (broggutNumber) {
            currentBrogguts = [broggutNumber intValue];
        }
        if (metalNumber) {
            currentMetal = [metalNumber intValue];
        }
        
        CGRect fullMapRect = CGRectMake(0, 0, COLLISION_CELL_WIDTH * cellsWide, COLLISION_CELL_HEIGHT * cellsHigh);
        CGRect visibleRect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
        
        // Initialize the entire scene, get it ready for adding objects
        sceneType = thisSceneType;
        [self initializeWithScreenBounds:visibleRect withFullMapBounds:fullMapRect withName:thisSceneName];
        
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
                MediumBroggut* broggut = [[self collisionManager] broggutCellForLocation:currentPoint]; 
                NSNumber* broggutValue = [currentBroggutInfo objectAtIndex:0];  // Value stored
                NSNumber* broggutAge = [currentBroggutInfo objectAtIndex:1];	// Age stored
                broggut->broggutAge = [broggutAge intValue];
                
                if (!loaded) {
                    if ([broggutValue intValue] != -1) {
                        switch ([broggutAge intValue]) {
                            case kBroggutMediumAgeYoung: {
                                int range = kBroggutYoungMediumMaxValue - kBroggutYoungMediumMinValue;
                                int rand = arc4random() % range;
                                broggut->broggutValue = kBroggutYoungMediumMinValue + rand;
                                break;
                            }
                            case kBroggutMediumAgeOld:{
                                int range = kBroggutOldMediumMaxValue - kBroggutOldMediumMinValue;
                                int rand = arc4random() % range;
                                broggut->broggutValue = kBroggutOldMediumMinValue + rand;
                                break;
                            }
                            case kBroggutMediumAgeAncient:{
                                int range = kBroggutAncientMediumMaxValue - kBroggutAncientMediumMinValue;
                                int rand = arc4random() % range;
                                broggut->broggutValue = kBroggutAncientMediumMinValue + rand;
                                break;
                            }
                            default:
                                broggut->broggutValue = [broggutValue intValue];
                                break;
                        }
                    } else {
                        broggut->broggutValue = [broggutValue intValue];
                    }
                } else {
                    broggut->broggutValue = [broggutValue intValue];
                }
                
                if ([broggutValue intValue] == -1) {
                    [pointArray addObject:[NSNumber numberWithFloat:currentX]];
                    [pointArray addObject:[NSNumber numberWithFloat:currentY]];
                    [locationArray addObject:pointArray];
                } else {
                    [[self collisionManager] addMediumBroggut];
                    [[self collisionManager] setPathNodeIsOpen:NO atLocation:currentPoint];
                }
                [pointArray release];
            }
        }
        
        [[self collisionManager] remakeGenerator];
        [[self collisionManager] updateAllMediumBroggutsEdges];
        
        // Iterate through the object array
        for (int i = 0; i < [objectArray count]; i++) {
            NSArray* currentObjectInfo = [objectArray objectAtIndex:i];
            // Go through each object and create the appropriate object with the correct attributes
            int objectTypeID = [[currentObjectInfo objectAtIndex:kSceneStorageIndexTypeID] intValue];
            int objectID = [[currentObjectInfo objectAtIndex:kSceneStorageIndexID] intValue];
            NSArray* path = [currentObjectInfo objectAtIndex:kSceneStorageIndexPath];
            NSArray* objectCurrentPath = [sharedGameController convertSavedPath:path];
            int objectAlliance = [[currentObjectInfo objectAtIndex:kSceneStorageIndexAlliance] intValue];
            float objectRotation = [[currentObjectInfo objectAtIndex:kSceneStorageIndexRotation] floatValue];
            BOOL objectIsTraveling = [[currentObjectInfo objectAtIndex:kSceneStorageIndexTraveling] boolValue];
            CGPoint objectEndLocation = [sharedGameController getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexEndLoc];
            CGPoint objectCurrentLocation = [sharedGameController getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexCurrentLoc];
            int objectCurrentHull = [[currentObjectInfo objectAtIndex:kSceneStorageIndexHull] intValue];
            BOOL objectIsControlledShip = [[currentObjectInfo objectAtIndex:kSceneStorageIndexControlledShip] boolValue];
            BOOL objectIsMining = [[currentObjectInfo objectAtIndex:kSceneStorageIndexMining] boolValue];
            CGPoint objectMiningLocation = [sharedGameController getCGPointFromArray:currentObjectInfo atIndex:kSceneStorageIndexMiningLoc];
            int objectCurrentCargo = [[currentObjectInfo objectAtIndex:kSceneStorageIndexCargo] intValue];
            
            switch (objectTypeID) {
                case kObjectTypeStructure: {
                    // Create structure for this iteration
                    switch (objectID) {
                        case kObjectStructureBaseStationID: {
                            BaseStationStructureObject* newStructure = [[BaseStationStructureObject alloc]
                                                                        initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            if (newStructure.objectAlliance == kAllianceFriendly) {
                                self.homeBaseLocation = objectEndLocation;
                            }
                            if (newStructure.objectAlliance == kAllianceEnemy) {
                                self.enemyBaseLocation = objectEndLocation;
                            }
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureBlockID: {
                            BlockStructureObject* newStructure = [[BlockStructureObject alloc]
                                                                  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureRefineryID: {
                            RefineryStructureObject* newStructure = [[RefineryStructureObject alloc]
                                                                     initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureCraftUpgradesID: {
                            CraftUpgradesStructureObject* newStructure = [[CraftUpgradesStructureObject alloc]
                                                                          initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureStructureUpgradesID: {
                            StructureUpgradesStructureObject* newStructure = [[StructureUpgradesStructureObject alloc]
                                                                              initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureTurretID: {
                            TurretStructureObject* newStructure = [[TurretStructureObject alloc]
                                                                   initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureRadarID: {
                            RadarStructureObject* newStructure = [[RadarStructureObject alloc]
                                                                  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                            [newStructure release];
                            break;
                        }
                        case kObjectStructureFixerID: {
                            FixerStructureObject* newStructure = [[FixerStructureObject alloc]
                                                                  initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newStructure setCurrentScene:self];
                            [newStructure setObjectAlliance:objectAlliance];
                            [newStructure setObjectLocation:objectCurrentLocation];
                            [newStructure setCurrentHull:objectCurrentHull];
                            [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
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
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
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
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
                            }
                            [newCraft release];
                            break;
                        }
                        case kObjectCraftBeetleID: {
                            BeetleCraftObject* newCraft = [[BeetleCraftObject alloc]
                                                           initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
                            }
                            [newCraft release];
                            break;
                        }
                        case kObjectCraftMonarchID: {
                            MonarchCraftObject* newCraft = [[MonarchCraftObject alloc]
                                                            initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
                            }
                            [newCraft release];
                            break;
                        }
                        case kObjectCraftCamelID: {
                            CamelCraftObject* newCraft = [[CamelCraftObject alloc]
                                                          initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
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
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
                            }
                            [newCraft release];
                            break;
                        }
                        case kObjectCraftSpiderID: {
                            SpiderCraftObject* newCraft = [[SpiderCraftObject alloc]
                                                           initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newCraft setCurrentScene:self];
                            for (int i = 0; i < SPIDER_NUMBER_OF_DRONES; i++) {
                                [newCraft addNewDroneToBay];
                            }
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
                            }
                            [newCraft release];
                            break;
                        }
                        case kObjectCraftEagleID: {
                            EagleCraftObject* newCraft = [[EagleCraftObject alloc]
                                                          initWithLocation:objectEndLocation isTraveling:objectIsTraveling];
                            [newCraft setCurrentScene:self];
                            [newCraft setObjectAlliance:objectAlliance];
                            [newCraft setObjectRotation:objectRotation];
                            [newCraft setObjectLocation:objectCurrentLocation];
                            [newCraft setCurrentHull:objectCurrentHull];
                            [newCraft addCargo:objectCurrentCargo];
                            if (!objectIsTraveling)
                                [newCraft followPath:objectCurrentPath isLooped:NO];
                            [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            // [self addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                            if (objectIsControlledShip) {
                                [self addControlledCraft:newCraft];
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
        
        [self addSmallBrogguts:newNumberOfSmallBrogguts inBounds:fullMapRect withLocationArray:locationArray]; // Add the small brogguts
        if (sceneType == kSceneTypeCampaign) {
            [[sharedGameController currentProfile] addBrogguts:currentBrogguts];
            [[sharedGameController currentProfile] addMetal:currentMetal];
        }
        [locationArray release];
        [array release];
    }
	return self;
}

- (void)dealloc {
	if (cameraImage) {
		[cameraImage release];
	}
    [broggutIconImage release];
    [metalIconImage release];
    [supplyIconImage release];
    [countdownTimer release];
    [notification release];
    [helpMessageObject release];
    [sceneFileName release];
    [currentBlocks release];
    [currentRefineries release];
    [buildBroggutValue release];
    [buildMetalValue release];
    [endMissionObject release];
    [enemyAIController release];
	[broggutCounter release];
	[metalCounter release];
    [supplyCounter release];
	[controlledShips release];
	[selectionPointsOne release];
	[selectionPointsTwo release];
	[sideBar release];
	[sceneName release];
	[fontArray release];
	[textObjectArray release];
	[currentTouchesInSideBar release];
	[currentObjectsTouching release];
	[currentObjectsHovering release];
	[renderableObjects release];
	[renderableDestroyed release];
	[touchableObjects release];
	[collisionManager release];
	[super dealloc];
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName {
	self = [super init];
	if (self) {
		[self initializeWithScreenBounds:screenBounds withFullMapBounds:mapBounds withName:sName];
    }
    return self;
}

- (void)sceneDidAppear {
    
    CGPoint nameLoc = CGPointMake((kPadScreenLandscapeWidth - [self getWidthForFontID:kFontGothicID withString:sceneName]) / 2,
                                  kPadScreenLandscapeHeight - 64);
    TextObject* nameObject = [[TextObject alloc] initWithFontID:kFontGothicID Text:sceneName withLocation:nameLoc withDuration:SCENE_NAME_OBJECT_TIME];
    [nameObject setScrollWithBounds:NO];
    [self addTextObject:nameObject];
    [nameObject release];
    
    if ([controlledShips count] != 0) {
        float averageX = 0.0f;
        float averageY = 0.0f;
        for (CraftObject* craft in controlledShips) {
            averageX += craft.objectLocation.x / ((float)[controlledShips count]);
            averageY += craft.objectLocation.y / ((float)[controlledShips count]);
        }
        CGPoint cameraPoint = CGPointMake(averageX, averageY);
        [self setCameraLocation:cameraPoint];
        [self setMiddleOfVisibleScreenToCamera];
    } else if (sceneType != kSceneTypeTutorial){
        [self setCameraLocation:homeBaseLocation];
        [self setMiddleOfVisibleScreenToCamera];
    }
    // Just to be sure
    [sharedStarSingleton randomizeStars];
    [[GameController sharedGameController] setCurrentScene:self];
    [[sharedGameController currentProfile] startSceneWithType:sceneType];
}

- (void)sceneDidDisappear {
    [sharedGameCenterSingleton disconnectFromGame];
}

#pragma mark -
#pragma mark Brogguts

- (void)addBroggutTextValue:(int)value atLocation:(CGPoint)location withAlliance:(int)alliance {
    if (value > 0) {
        NSString* string = [NSString stringWithFormat:@"+%i Bgs", value];
        float stringWidth = [[fontArray objectAtIndex:kFontBlairID] getWidthForString:string];
        CGPoint newLoc = CGPointMake(CLAMP(location.x - (stringWidth / 2), fullMapBounds.origin.x, fullMapBounds.size.width),
                                     CLAMP(location.y + 16, fullMapBounds.origin.y, fullMapBounds.size.height));
        TextObject* obj = [[TextObject alloc] initWithFontID:kFontBlairID Text:string withLocation:newLoc withDuration:2.5f];
        [obj setScrollWithBounds:YES];
        [obj setObjectVelocity:Vector2fMake(0.0f, 0.4f)];
        [obj setFontColor:Color4fMake(1.0f, 1.0f, 0.0f, 1.0f)];
        [obj setRenderLayer:kLayerTopLayer];
        [textObjectArray addObject:obj];
        [obj release];
    } else if (value < 0) {
        NSString* string = [NSString stringWithFormat:@"%i Bgs", value];
        float stringWidth = [[fontArray objectAtIndex:kFontBlairID] getWidthForString:string];
        CGPoint newLoc = CGPointMake(CLAMP(location.x - (stringWidth / 2), fullMapBounds.origin.x, fullMapBounds.size.width),
                                     CLAMP(location.y + 16, fullMapBounds.origin.y, fullMapBounds.size.height));
        TextObject* obj = [[TextObject alloc] initWithFontID:kFontBlairID Text:string withLocation:newLoc withDuration:3.0f];
        [obj setScrollWithBounds:YES];
        [obj setObjectVelocity:Vector2fMake(0.0f, 0.4f)];
        [obj setFontColor:Color4fMake(1.0f, 0.0f, 0.0f, 1.0f)];
        [obj setRenderLayer:kLayerTopLayer];
        [textObjectArray addObject:obj];
        [obj release];
    }
}

- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds withLocationArray:(NSArray*)locationArray {
    for (int i = 0; i < number; i++) {
        CGPoint curPoint;
        if (locationArray && [locationArray count] != 0) {
            int randomIndex = arc4random() % [locationArray count];
            NSArray* numberArray = [locationArray objectAtIndex:randomIndex];
            curPoint = CGPointMake([[numberArray objectAtIndex:0] floatValue],
                                   [[numberArray objectAtIndex:1] floatValue]);
        } else {
            curPoint = CGPointMake(bounds.origin.x + RANDOM_0_TO_1() * bounds.size.width,
                                   bounds.origin.y + RANDOM_0_TO_1() * bounds.size.height);
        }
        
        Image* rockImage = [[Image alloc] initWithImageNamed:kObjectBroggutSmallSprite filter:GL_LINEAR];
        float randomDarkness = CLAMP(RANDOM_0_TO_1() + 0.2f, 0.0f, 0.8f);
        [rockImage setColor:Color4fMake(randomDarkness, randomDarkness, randomDarkness, 1.0f)];
        BroggutObject* tempObj = [[BroggutObject alloc]
                                  initWithImage:rockImage
                                  withLocation:CGPointMake(curPoint.x + RANDOM_MINUS_1_TO_1() * (COLLISION_CELL_WIDTH / 2),
                                                           curPoint.y + RANDOM_MINUS_1_TO_1() * (COLLISION_CELL_HEIGHT / 2))];
        tempObj.objectRotation = 360 * RANDOM_0_TO_1();
        tempObj.rotationSpeed = RANDOM_MINUS_1_TO_1() * kBroggutSmallMaxRotationSpeed;
        tempObj.objectVelocity = Vector2fMake(RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f),
                                              RANDOM_MINUS_1_TO_1() * ((float)kBroggutSmallMaxVelocity / 100.0f));
        
        int rarityFactor = arc4random() % kBroggutRarityBase;
        if (rarityFactor > (kBroggutRarityBase - kBroggutYoungRarity)) {
            tempObj.broggutValue = kBroggutYoungSmallMinValue + (arc4random() % (kBroggutYoungSmallMaxValue - kBroggutYoungSmallMinValue));
        } else if (rarityFactor > (kBroggutRarityBase - (kBroggutOldRarity + kBroggutYoungRarity))) {
            tempObj.broggutValue = kBroggutOldSmallMinValue + (arc4random() % (kBroggutOldSmallMaxValue - kBroggutOldSmallMinValue));
        } else {
            tempObj.broggutValue = kBroggutAncientSmallMinValue + (arc4random() % (kBroggutAncientSmallMaxValue - kBroggutAncientSmallMinValue));
        }
        [tempObj setCurrentScene:self];
        
        if (arc4random() % 2 == 1) {
            [tempObj setRenderLayer:kLayerBottomLayer];
        } else {
            [tempObj setRenderLayer:kLayerMiddleLayer];
        }
        
        [collisionManager addCollidableObject:tempObj];
        numberOfSmallBrogguts++;
        [renderableObjects insertObject:tempObj atIndex:0]; // Insert the broggut at the beginning so it is rendered first
        [tempObj release];
        [rockImage release];
    }
}

- (void)refineMetalOutOfBrogguts:(int)metal {
    if (numberOfRefineries == 0) {
        return;
    }
    if ([[sharedGameController currentProfile] subtractBrogguts:(metal * 10) metal:0] == kProfileNoFail) {
        int divided = metal / numberOfRefineries;
        int remainder = metal % numberOfRefineries;
        
        for (int i = 0; i < numberOfRefineries; i++) {
            RefineryStructureObject* refinery = [currentRefineries objectAtIndex:i];
            [refinery addRefiningCount:divided];
            if (i == 0) {
                [refinery addRefiningCount:remainder];
            }
        }
    } else {
        [self showHelpMessageWithMessageID:kHelpMessageNeedBrogguts];
    }
}

#pragma mark -
#pragma mark Fonts

- (float)getWidthForFontID:(int)fontID withString:(NSString*)string {
    BitmapFont* font = [fontArray objectAtIndex:fontID];
    return [font getWidthForString:string];
}

- (float)getHeightForFontID:(int)fontID withString:(NSString*)string  {
    BitmapFont* font = [fontArray objectAtIndex:fontID];
    return [font getHeightForString:string];
}

#pragma mark -
#pragma mark Scrolling

- (void)scrollScreenWithVector:(Vector2f)scrollVector {
    float xAddition = scrollVector.x;
    float yAddition = scrollVector.y;
    
    // Check bounds against the mapRect
    if (visibleScreenBounds.origin.x + visibleScreenBounds.size.width + xAddition > fullMapBounds.size.width) {
        xAddition = fullMapBounds.size.width - (visibleScreenBounds.origin.x + visibleScreenBounds.size.width);
    }
    if (visibleScreenBounds.origin.y + visibleScreenBounds.size.height + yAddition > fullMapBounds.size.height) {
        yAddition = fullMapBounds.size.height - (visibleScreenBounds.origin.y + visibleScreenBounds.size.height);
    }
    if (visibleScreenBounds.origin.x + xAddition < fullMapBounds.origin.x) {
        xAddition = fullMapBounds.origin.x - visibleScreenBounds.origin.x;
    }
    if (visibleScreenBounds.origin.y + yAddition < fullMapBounds.origin.y) {
        yAddition = fullMapBounds.origin.y - visibleScreenBounds.origin.y;
    }
    
    // Set the new visible screen bounds
    visibleScreenBounds = CGRectMake(visibleScreenBounds.origin.x + xAddition,
                                     visibleScreenBounds.origin.y + yAddition,
                                     visibleScreenBounds.size.width,
                                     visibleScreenBounds.size.height);
    
    // Update the camera container rectangle
    cameraContainRect = CGRectInset(visibleScreenBounds, SCROLL_BOUNDS_X_INSET, SCROLL_BOUNDS_Y_INSET);
    
    // Scroll the stars, this needs to be called separately since they scroll at different rates
    [sharedStarSingleton scrollStarsWithVector:Vector2fMake(-xAddition, -yAddition)];
    
    // Update the touch location, since we are scrolling
    currentTouchLocation = CGPointMake(currentTouchLocation.x + xAddition, currentTouchLocation.y + yAddition);
}

// Used for scrolling the screen with the camera, NOT to be used by other objects
- (Vector2f)newScrollVectorFromCamera {
    Vector2f newVector = Vector2fMake(0, 0);
    
    if (CGRectContainsPoint(cameraContainRect, cameraLocation)) {
        return newVector;
    } else {
        CGPoint screenMiddle = [self middleOfVisibleScreen];
        newVector.x = CLAMP(newVector.x + SCROLL_MAX_SPEED * (cameraLocation.x - screenMiddle.x) / visibleScreenBounds.size.width,
                            -SCROLL_MAX_SPEED, SCROLL_MAX_SPEED);
        newVector.y = CLAMP(newVector.y + SCROLL_MAX_SPEED * (cameraLocation.y - screenMiddle.y) / visibleScreenBounds.size.height,
                            -SCROLL_MAX_SPEED, SCROLL_MAX_SPEED);
    }
    return newVector;
}

// ALL objects should use this to do their scrolled drawing
- (Vector2f)scrollVectorFromScreenBounds {
    if (!isScreenShaking) {
        return Vector2fMake(visibleScreenBounds.origin.x, visibleScreenBounds.origin.y);
    } else {
        float randX = RANDOM_MINUS_1_TO_1() * screenShakingAmount;
        float randY = RANDOM_MINUS_1_TO_1() * screenShakingAmount;
        return Vector2fMake(visibleScreenBounds.origin.x + randX, visibleScreenBounds.origin.y + randY);   
    }
}
     
- (CGPoint)middleOfVisibleScreen {
    return CGPointMake(visibleScreenBounds.origin.x + (visibleScreenBounds.size.width / 2),
                       visibleScreenBounds.origin.y + (visibleScreenBounds.size.height / 2));
}
     
- (void)setMiddleOfVisibleScreenToCamera {
    float originX = cameraLocation.x - (visibleScreenBounds.size.width / 2);
    float originY = cameraLocation.y - (visibleScreenBounds.size.height / 2);
    visibleScreenBounds = CGRectMake(CLAMP(originX, 0.0f, fullMapBounds.size.width - visibleScreenBounds.size.width),
                                     CLAMP(originY, 0.0f, fullMapBounds.size.height - visibleScreenBounds.size.height), 
                                     visibleScreenBounds.size.width,
                                     visibleScreenBounds.size.height);
}
     
- (CGPoint)middleOfEntireMap {
    return CGPointMake(fullMapBounds.origin.x + (fullMapBounds.size.width / 2),
                       fullMapBounds.origin.y + (fullMapBounds.size.height / 2));
}

#pragma mark -
#pragma mark Update/Render

- (void)updateSceneWithDelta:(GLfloat)aDelta {
    if (isMultiplayerMatch && ![sharedGameCenterSingleton matchStarted]) {
        // Waiting for other player
        return;
    }
    
    // Update the frame counter used by the scene
    if (++frameCounter >= FRAME_COUNTER_MAX) {
        frameCounter = 0;
    }
    
    if (isScreenShaking) {
        screenShakingAmount /= 1.1;
        if (screenShakingAmount <= 0.0f) {
            isScreenShaking = NO;
            screenShakingAmount = 0.0f;
        }
    }
    
    // Update the current broggut count
    NSString* brogCount = [NSString stringWithFormat:@" %i",[sharedGameController currentProfile].broggutCount];
    [broggutCounter setFontColor:Color4fMake(1.0f, 1.0f, 0.75f, 1.0f)];
    [broggutCounter setObjectText:brogCount];
    [broggutCounter setIsTextHidden:!isShowingBroggutCount];
    
    NSString* metalCount = [NSString stringWithFormat:@" %i",[sharedGameController currentProfile].metalCount];
    [metalCounter setFontColor:Color4fMake(0.75f, 0.75f, 1.0f, 1.0f)];
    [metalCounter setObjectText:metalCount];
    [metalCounter setIsTextHidden:!isShowingMetalCount];
    
    NSString* supplyCount = [NSString stringWithFormat:@" %i/%i", numberOfCurrentShips, [self currentMaxShipSupply]];
    if (numberOfCurrentShips >= [self currentMaxShipSupply]) {
        [supplyCounter setFontColor:Color4fMake(1.0f, 0.75f, 0.75f, 1.0f)];
    } else {
        [supplyCounter setFontColor:Color4fMake(0.75f, 1.0f, 0.75f, 1.0f)];
    }
    [supplyCounter setObjectText:supplyCount];
    [supplyCounter setIsTextHidden:!isShowingSupplyCount];
    
    if (isMissionOver) {
        [endMissionObject endMissionDidAppear];
        isShowingBroggutCount = NO;
        isShowingMetalCount = NO;
        if (!didAddBrogguts) {
            didAddBrogguts = YES;
            [[sharedGameController currentProfile] endSceneWithType:sceneType wasSuccessful:isMissionOver];
        }
        [endMissionObject updateObjectLogicWithDelta:aDelta];
        if (fadeBackgroundAlpha < END_MISSION_BACKGROUND_ALPHA) {
            fadeBackgroundAlpha += 0.005f;
        }
        return;
    }
    
    // Update the stars' positions and brightness if applicable
    [sharedStarSingleton updateStars];
    
    // Update the particle manager's particles
    [sharedParticleSingleton updateParticlesWithDelta:aDelta];
    
    // Update the camera's location
    if (controlledShips && [controlledShips count] != 0) { // If there is a controlling ship
        float averageX = 0.0f, averageY = 0.0f;
        float minVelocity = FLT_MAX;
        int shipCount = [controlledShips count];
        float commonDirection = [[controlledShips objectAtIndex:0] objectRotation];
        for (CraftObject* craft in controlledShips) {
            float dirDiff = fabsf(commonDirection - craft.objectRotation);
            if (![craft craftDoesRotate]) {
                dirDiff = 0.0f;
            }
            if (dirDiff > 180.0f) {
                dirDiff = 360.0f - dirDiff;
            }
            averageX += craft.objectLocation.x / ((float)shipCount);
            averageY += craft.objectLocation.y / ((float)shipCount);
            if (craft.maxVelocity < minVelocity) {
                minVelocity = craft.maxVelocity;
            }
            if (dirDiff > CRAFT_ROTATION_TURNING_RANGE) {
                minVelocity = 0.0f;
            }
        }
        CGPoint cameraPoint = CGPointMake(averageX, averageY);
        if (isTouchScrolling && !isShowingOverview) {
            for (CraftObject* craft in controlledShips) {
                float xDiff = craft.objectLocation.x - averageX;
                float yDiff = craft.objectLocation.y - averageY;
                CGPoint craftDest = CGPointMake(currentTouchLocation.x + xDiff, currentTouchLocation.y + yDiff);
                [craft stopFollowingCurrentPath];
                [craft setAttackingAIState:kAttackingAIStateNeutral];
                [craft accelerateTowardsLocation:craftDest withMaxVelocity:minVelocity];
            }
            if (!isTouchMovingOverview)
                cameraLocation = GetMidpointFromPoints(cameraPoint, currentTouchLocation);
        } else {
            if (!isTouchMovingOverview)
                cameraLocation = cameraPoint;
        }
    }
    
    // Update the medium broggut value checker
    if (isTouchScrolling) {
        isShowingValueText = YES;
        [self showBroggutValueAtLocation:currentTouchLocation];
    } else {
        isShowingValueText = NO;
        [self showBroggutValueAtLocation:currentTouchLocation];
    }
    
    if (isShowingBuildingValues) {
        [self showBuildingValuesWithBrogguts:currentBuildBroggutCost withMetal:currentBuildMetalCost atLocation:currentBuildDragLocation];
    } else {
        [buildBroggutValue setIsTextHidden:YES];
        [buildMetalValue setIsTextHidden:YES];
    }
    
    if (isShowingMessageTimer) {
        messageTimer -= aDelta;
        [helpMessageObject setObjectLocation:CGPointMake(kPadScreenLandscapeWidth / 2, 64.0f)];
        [helpMessageObject setFontColor:Color4fMake(1.0f, 0.0f, 0.0f, CLAMP(messageTimer, 0.0f, 1.0f))];
        if (messageTimer <= 0.0f) {
            isShowingMessageTimer = NO;
        }
    }
    
    // Gets the vector that the screen shoudl scroll, and scrolls it, updating the rects as necessary
    Vector2f cameraScroll = [self newScrollVectorFromCamera];
    [self scrollScreenWithVector:Vector2fMultiply(cameraScroll, 1.0f)];
    
    // Update side bar
    [sideBar updateSideBar];
    
    // Update alpha of the overview map
    if (isFadingOverviewIn) {
        overviewAlpha += OVERVIEW_FADE_IN_RATE;
        if (overviewAlpha >= 1.0f) {
            isFadingOverviewIn = NO;
        }
    } else if (isFadingOverviewOut) {
        overviewAlpha -= OVERVIEW_FADE_IN_RATE;
        if (overviewAlpha <= 0.0f) {
            isShowingOverview = NO; // Ending fade out
            isFadingOverviewOut = NO;
        }
    } else if (!isShowingOverview) {
        overviewAlpha = 0.0f;
    }
    overviewAlpha = CLAMP(overviewAlpha, 0.0f, 1.0f);
    
    // Loop through all text objects and update them
    for (int i = 0; i < [textObjectArray count]; i++) {
        TextObject* tempObj = [textObjectArray objectAtIndex:i];
        [tempObj updateObjectLogicWithDelta:aDelta];
        if (tempObj.destroyNow) {
            [renderableDestroyed addObject:tempObj];
        }
    }
    
    // Loop through all collidable objects and update them
    for (int i = 0; i < [renderableObjects count]; i++) {
        CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
        [tempObj updateObjectLogicWithDelta:aDelta];
        if (tempObj.objectType == kObjectBroggutSmallID) {
            if (tempObj.objectLocation.x < fullMapBounds.origin.x)
                tempObj.objectLocation = CGPointMake(fullMapBounds.size.width, tempObj.objectLocation.y);
            if (tempObj.objectLocation.x > fullMapBounds.size.width)
                tempObj.objectLocation = CGPointMake(fullMapBounds.origin.x, tempObj.objectLocation.y);
            if (tempObj.objectLocation.y < fullMapBounds.origin.y)
                tempObj.objectLocation = CGPointMake(tempObj.objectLocation.x, fullMapBounds.size.height);
            if (tempObj.objectLocation.y > fullMapBounds.size.height)
                tempObj.objectLocation = CGPointMake(tempObj.objectLocation.x, fullMapBounds.origin.y);
        } else {
            tempObj.objectLocation = CGPointMake(CLAMP(tempObj.objectLocation.x, 0.0f, fullMapBounds.size.width),
                                                 CLAMP(tempObj.objectLocation.y, 0.0f, fullMapBounds.size.height));
        }
        if (tempObj.destroyNow) {
            [renderableDestroyed addObject:tempObj];
        }
    }
    
    // Check for collisions
    if (frameCounter % (COLLISION_DETECTION_FREQ + 1) == 0) {
        [collisionManager processAllCollisionsWithScreenBounds:visibleScreenBounds];
    } else {
        [collisionManager updateAllObjectsInTableInScreenBounds:visibleScreenBounds];
    }
    
    // Check for radial effects
    if (frameCounter % (RADIAL_EFFECT_CHECK_FREQ + 1) == 0) {
        [collisionManager processAllEffectRadii];
    }
    
    // Update the AI controller
    if (!isMultiplayerMatch) {
        [enemyAIController updateAIController];
    }
    
    if (isShowingNotification) {
        if (!notification || [notification destroyNow]) {
            isShowingNotification = NO;
            notification = nil;
        }
    }
    
    // Destroy all objects in the destory array, and remove them from other arrays
    for (int i = 0; i < [renderableDestroyed count]; i++) {
        CollidableObject* tempObj = [renderableDestroyed objectAtIndex:i];
        [enemyAIController removeObjectsInArray:renderableDestroyed];
        [renderableObjects removeObject:tempObj];
        if (tempObj.isCheckedForCollisions) {
            [collisionManager removeCollidableObject:tempObj];
        }
        if (tempObj.isTextObject) {
            [textObjectArray removeObject:tempObj];
        }
        if ([tempObj isKindOfClass:[TouchableObject class]]) {
            TouchableObject* touchObj = (TouchableObject*)tempObj;
            if (touchObj.isCheckedForRadialEffect) {
                [collisionManager removeRadialAffectedObject:touchObj];
            }
        }
        [tempObj objectWasDestroyed];
        if ([tempObj isKindOfClass:[CraftObject class]]) {
            // It is a ship
            // If was being controlled, remove it
            [self removeControlledCraft:(CraftObject*)tempObj];
            if (tempObj.objectAlliance == kAllianceFriendly) {
                numberOfCurrentShips--;
            } else if (tempObj.objectAlliance == kAllianceEnemy) {
                numberOfEnemyShips--;
            }
        }
        if ([tempObj isKindOfClass:[StructureObject class]]) {
            // It is a structure
            if (tempObj.objectAlliance == kAllianceFriendly) {
                numberOfCurrentStructures--;
                if (tempObj.objectType == kObjectStructureRefineryID) {
                    numberOfRefineries--;
                    [currentRefineries removeObject:tempObj];
                }
                if (tempObj.objectType == kObjectStructureBlockID) {
                    // Do not decrease the supply
                    [currentBlocks removeObject:tempObj];
                }
            } else if (tempObj.objectAlliance == kAllianceEnemy) {
                numberOfEnemyStructures--;
            }
        }
        if ([tempObj isKindOfClass:[BroggutObject class]]) {
            // It is a broggut
            numberOfSmallBrogguts--;
        }
        
        [tempObj setObjectLocation:CGPointMake(-INT_MAX, -INT_MAX)];
        if (!tempObj.isRemoteObject) {
            DestructionPacket packet;
            packet.objectID = tempObj.uniqueObjectID;
            [sharedGameCenterSingleton sendDestructionPacket:packet isRequired:YES];
        }
    }
    [renderableDestroyed removeAllObjects];
    
    if (sceneType == kSceneTypeSkirmish && isMultiplayerMatch && [sharedGameCenterSingleton matchStarted]) {
        if (frameCounter % (GAME_CENTER_OBJECT_UPDATE_FRAME_PAUSE + 1) == 0) {
            [self updateRemoteObjectsWithDelta:aDelta];
        }
    }
}

- (void)updateRemoteObjectsWithDelta:(float)aDelta {
    int count = [touchableObjects count];
    for (int i = 0; i < count; i++) {
        TouchableObject* thisObject = [touchableObjects objectAtIndex:i];
        if (thisObject.destroyNow) continue;
        if (thisObject.objectVelocity.x == 0.0f &&
            thisObject.objectVelocity.y == 0.0f) continue;
        
        ComplexEntityPacket packet;
        packet.objectID = thisObject.uniqueObjectID;
        packet.position = Vector2fMake(thisObject.objectLocation.x, thisObject.objectLocation.y);
        packet.rotation = thisObject.objectRotation;
        packet.velocity = thisObject.objectVelocity;
        BOOL required = NO;
        if ([thisObject isOnScreen]) {
            required = YES;
        }
        [sharedGameCenterSingleton sendComplexPacket:packet isRequired:required];
    }
    [sharedGameCenterSingleton processQueuedPackets];
}

- (void)renderScene {
    
    // Clear the screen
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Get the scroll vector that most images will need to by translated with
    Vector2f scroll = [self scrollVectorFromScreenBounds];
    
    // Rendering stars
    [sharedStarSingleton renderStars];
    
    if (doesSceneShowGrid) {
        enablePrimitiveDraw();
        // Draw the grid that collisions are based in
        glLineWidth(1.0f);
        [collisionManager drawCellGridAtPoint:[self middleOfEntireMap] withScale:Scale2fMake(1.0f, 1.0f) withScroll:scroll withAlpha:SCENE_GRID_RENDER_ALPHA];
        disablePrimitiveDraw();
    }
    
    if (isShowingBroggutCount) {
        CGPoint broggutPoint = CGPointMake(broggutCounter.objectLocation.x - 36,
                                           broggutCounter.objectLocation.y - 6);
        [broggutIconImage renderAtPoint:broggutPoint];
    }
    
    if (isShowingMetalCount) {
        CGPoint metalPoint = CGPointMake(metalCounter.objectLocation.x - 36,
                                         metalCounter.objectLocation.y - 6);
        [metalIconImage renderAtPoint:metalPoint];
    }
    
    if (isShowingSupplyCount) {
        CGPoint supplyPoint = CGPointMake(supplyCounter.objectLocation.x - 36,
                                          supplyCounter.objectLocation.y - 6);
        [supplyIconImage renderAtPoint:supplyPoint];
    }
    
    // Draw the medium/large brogguts
    [collisionManager renderMediumBroggutsInScreenBounds:visibleScreenBounds withScrollVector:scroll];
    
    // Render text objects
    for (int i = 0; i < [textObjectArray count]; i++) {
        TextObject* tempObj = [textObjectArray objectAtIndex:i];
        if (tempObj.scrollWithBounds)
            [tempObj renderWithFont:[fontArray objectAtIndex:tempObj.fontID] withScrollVector:scroll centered:NO];
        else
            [tempObj renderWithFont:[fontArray objectAtIndex:tempObj.fontID]];
    }
    
    // Render all objects (excluding text objects)
    for (int i = 0; i < [renderableObjects count]; i++) {
        CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
        if ([tempObj isOnScreen])
            [tempObj renderCenteredAtPoint:tempObj.objectLocation withScrollVector:scroll];
    }
    
    // Render particles underneath everything
    [sharedParticleSingleton renderParticlesOnLayer:kParticleLayerBottom WithScroll:scroll];
    
    // Render images
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerBottomLayer];
    
    // Render all primitives under
    for (int i = 0; i < [renderableObjects count]; i++) {
        CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
        if ([tempObj isOnScreen])
            [tempObj renderUnderObjectWithScroll:scroll];
        else if ([tempObj isKindOfClass:[TouchableObject class]]) {
            TouchableObject* touchObj = (TouchableObject*)tempObj;
            if ([touchObj isDrawingEffectRadius]) {
                [tempObj renderUnderObjectWithScroll:scroll];
            }
        }
    }
    
    // Render particles under middle
    [sharedParticleSingleton renderParticlesOnLayer:kParticleLayerMiddle WithScroll:scroll];
    
    // Render images
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerMiddleLayer];
    
    // Render all primitives over
    for (int i = 0; i < [renderableObjects count]; i++) {
        CollidableObject* tempObj = [renderableObjects objectAtIndex:i];
        if ([tempObj isOnScreen])
            [tempObj renderOverObjectWithScroll:scroll];
        else if ([tempObj isKindOfClass:[TouchableObject class]]) {
            TouchableObject* touchObj = (TouchableObject*)tempObj;
            if ([touchObj isDrawingEffectRadius]) {
                [tempObj renderOverObjectWithScroll:scroll];
            }
        }
    }
    
    // Render particles under middle
    [sharedParticleSingleton renderParticlesOnLayer:kParticleLayerTop WithScroll:scroll];
    
    // Render images
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerTopLayer];
    
    // Draw the selection area
    if (isSelectingShips) {
        glColor4f(0.1f, 1.0f, 0.1f, 0.75f);
        [self renderSelectionAreaWithPoints:selectionPointsOne andPoints:selectionPointsTwo];
    }
    
    // Render the map overview if present
    if (isShowingOverview) {
        [self renderOverviewMapWithAlpha:overviewAlpha];
    } else {
        overviewAlpha = 0.0f;
    }
    
    // Render the sidebar button (and sidebar, if activated)
    if (isAllowingSidebar)
        [sideBar renderSideBar];
    
    if (isMissionOver) {
        glColor4f(0.0f, 0.0f, 0.0f, fadeBackgroundAlpha);
        enablePrimitiveDraw();
        drawFilledRect(CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight), Vector2fZero);
        disablePrimitiveDraw();
        [endMissionObject renderCenteredAtPoint:[self middleOfVisibleScreen] withScrollVector:scroll];
    }
    
    // Render the help message
    if (isShowingMessageTimer) {
        [helpMessageObject renderWithFont:[fontArray objectAtIndex:kFontBlairID] withScrollVector:Vector2fZero centered:YES];
    }
    
    // Render images
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerHUDBottomLayer];
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerHUDMiddleLayer];
    [sharedImageRenderSingleton renderImagesOnLayer:kLayerHUDTopLayer];
    
    if (isMissionOver) {
        CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
        enablePrimitiveDraw();
        glColor4f(1.0f, 1.0f, 1.0f, 0.8f);
        glLineWidth(3.0f);
        drawLine(CGPointMake(center.x - (END_MISSION_BACKGROUND_WIDTH / 3), center.y),
                 CGPointMake(center.x + (END_MISSION_BACKGROUND_WIDTH / 3), center.y), Vector2fZero);
        disablePrimitiveDraw();
    }
}

#pragma mark -
#pragma mark Managing Objects

- (void)addTouchableObject:(TouchableObject*)obj withColliding:(BOOL)collides {
    [obj setCurrentScene:self];
    if ([obj isKindOfClass:[CraftObject class]]) {
        if (obj.objectAlliance == kAllianceFriendly) {
            numberOfCurrentShips++;
        } else if (obj.objectAlliance == kAllianceEnemy) {
            numberOfEnemyShips++;
        }
    }
    if ([obj isKindOfClass:[StructureObject class]]) {
        if (obj.objectAlliance == kAllianceFriendly) {
            numberOfCurrentStructures++;
        } else if (obj.objectAlliance == kAllianceEnemy) {
            numberOfEnemyStructures++;
        }
    }
    if (collides) {
        [collisionManager addCollidableObject:obj]; // Adds to the collision detection
    }
    if (obj.isCheckedForRadialEffect) {
        [collisionManager addRadialAffectedObject:obj];
    }
    [renderableObjects addObject:obj];				// Adds to the rendering queue
    [touchableObjects addObject:obj];				// Adds to the touchable queue
    [enemyAIController updateArraysWithTouchableObjects:touchableObjects];  // Updates AI controller with new objects
}

- (void)createLocalTouchableObject:(TouchableObject*)obj withColliding:(BOOL)collides {
    // Send the creation message to the other player
    if (isMultiplayerMatch) {
        CreationPacket packet;
        packet.objectID = obj.uniqueObjectID;
        packet.objectTypeID = obj.objectType;
        packet.position = Vector2fMake(obj.objectLocation.x, obj.objectLocation.y);
        [sharedGameCenterSingleton sendCreationPacket:packet isRequired:YES];
    }
    
    [self addTouchableObject:obj withColliding:collides];
}

- (void)addCollidableObject:(CollidableObject*)obj {
    [obj setCurrentScene:self];
    [collisionManager addCollidableObject:obj];
    [renderableObjects addObject:obj];
}

- (void)addTextObject:(TextObject*)obj {
    [obj setCurrentScene:self];
    [textObjectArray addObject:obj];
}

- (void)setNotification:(NotificationObject *)noti {
    if (!isShowingNotification) {
        isShowingNotification = YES;
        notification = noti;
        [self addCollidableObject:notification];
    }
}

- (void)addRefinery:(RefineryStructureObject*)refinery {
    if (![currentRefineries containsObject:refinery]) {
        numberOfRefineries++;
        [currentRefineries addObject:refinery];
    }
}

- (void)addBlock:(BlockStructureObject*)block {
    if (![currentBlocks containsObject:block]) {
        numberOfBlocks++;
        [currentBlocks addObject:block];
    }
}

- (int)currentMaxShipSupply {
    return (kStructureBaseStationSupplyBonus + (numberOfBlocks * kStructureBlockSupplyBonus));
}

- (void)showBroggutValueAtLocation:(CGPoint)location {
	MediumBroggut* broggut = [[self collisionManager] broggutCellForLocation:location];
	if (isShowingValueText) {
        if (broggut->broggutValue != -1) {
            NSString* string = [NSString stringWithFormat:@"(%i)",broggut->broggutValue];
            [valueTextObject setObjectText:string];
            [valueTextObject setIsTextHidden:NO];
            float width = [self getWidthForFontID:kFontBlairID withString:string];
            [valueTextObject setObjectLocation:CGPointMake(location.x - (width / 2), location.y + 32.0f)];
        } else {
            [valueTextObject setIsTextHidden:YES];
        }
	} else {
        [valueTextObject setIsTextHidden:YES];
    }
}

- (void)showHelpMessageWithMessageID:(int)helpID {
    if (helpID < 0 || helpID >= HELP_MESSAGE_COUNT) {
        return;
    }
    isShowingMessageTimer = YES;
    messageTimer = HELP_MESSAGE_TIME;
    NSString* messageString = [NSString stringWithString:kHelpMessagesTextArray[helpID]];
    [helpMessageObject setObjectText:messageString];
}

- (void)startShakingScreenWithMagnitude:(float)magnitude {
    isScreenShaking = YES;
    screenShakingAmount = magnitude;
}

#pragma mark -
#pragma mark Overview Map

- (void)fadeOverviewMapIn {
    if (!isShowingOverview) {
        if (!isFadingOverviewIn) {
            isShowingOverview = YES; // Start the fade in
            isFadingOverviewIn = YES;
            isFadingOverviewOut = NO;
        }
    }
}

- (void)fadeOverviewMapOut {
    if (isShowingOverview) {
        if (!isFadingOverviewOut) {
            isShowingOverview = YES; // Start the fade out 
            isFadingOverviewOut = YES;
            isFadingOverviewIn = NO;
        }
    }
}

- (void)renderOverviewMapWithAlpha:(float)alpha {
    if (isTouchMovingOverview) {
        alpha /= OVERVIEW_TRANSPARENT_ALPHA_DIVISOR;
    }
    // Disable the color array and switch off texturing
    enablePrimitiveDraw();
    
    GLfloat vertices[10] = {
        0.0f, 0.0f, // V1
        0.0f, kPadScreenLandscapeHeight, // V2
        kPadScreenLandscapeWidth, 0.0f, // V3
        0.0f, kPadScreenLandscapeHeight, // V4
        kPadScreenLandscapeWidth, kPadScreenLandscapeHeight // V5
    };
    
    // Render the back (black) square at this alpha
    glColor4f(0.0f, 0.0f, 0.0f, CLAMP(alpha, 0.0f, OVERVIEW_MAX_ALPHA));
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 5);
    float xRatio = visibleScreenBounds.size.width / fullMapBounds.size.width;
    float yRatio = visibleScreenBounds.size.height / fullMapBounds.size.height;
    float xOffset = 0.0f;
    float yOffset = 0.0f;
    
    // This ensures that the 4:3 aspect is mantained
    if (xRatio > yRatio) {
        xRatio = yRatio;
        xOffset = (kPadScreenLandscapeWidth - (fullMapBounds.size.width * xRatio)) / 2;
    } else if (yRatio > xRatio) {
        yRatio = xRatio;
        yOffset = (kPadScreenLandscapeHeight - (fullMapBounds.size.height * yRatio)) / 2;
    }
    
    CGPoint relativeMiddle = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    glLineWidth(1.0f);
    [collisionManager drawCellGridAtPoint:relativeMiddle withScale:Scale2fMake(xRatio, yRatio) withScroll:Vector2fZero withAlpha:CLAMP(alpha - 0.5f, 0.0f, 0.1f)];
    
    // Render each object as a point (sprite?) on the overview map
    GLfloat objPoint[2];
    for (int i = 0; i < [renderableObjects count]; i++) {
        CollidableObject* obj = [renderableObjects objectAtIndex:i];
        if (!obj.isRenderedInOverview) {
            continue;
        }
        objPoint[0] = xOffset + obj.objectLocation.x * xRatio;
        objPoint[1] = yOffset + obj.objectLocation.y * yRatio;
        glPointSize(1.0f);
        if ([obj isKindOfClass:[TouchableObject class]]) {
            TouchableObject* touchObj = (TouchableObject*)obj;
            if ([touchObj isDrawingEffectRadius]) {
                // If the object has an "effect circle" then draw it in faded gray
                Circle newCircle;
                newCircle.x = objPoint[0];
                newCircle.y = objPoint[1];
                newCircle.radius = [touchObj effectRadiusCircle].radius * xRatio;
                glColor4f(0.5f, 0.5f, 0.5f, CLAMP(alpha - 0.8f, 0.0f, OVERVIEW_MAX_ALPHA));
                drawCircle(newCircle, CIRCLE_SEGMENTS_COUNT, Vector2fZero);
            }
        }
        if (obj.objectAlliance == kAllianceNeutral) {
            glColor4f(1.0f, 1.0f, 0.0f, alpha);
        } else if (obj.objectAlliance == kAllianceFriendly) {
            glColor4f(0.0f, 1.0f, 0.0f, alpha);
        } else if (obj.objectAlliance == kAllianceEnemy) {
            glColor4f(1.0f, 0.0f, 0.0f, alpha);
        }
        if ([obj isKindOfClass:[CraftObject class]]) {
            glPointSize(4.0f);
        }
        if ([obj isKindOfClass:[StructureObject class]]) {
            glPointSize(8.0f);
        }
        glVertexPointer(2, GL_FLOAT, 0, objPoint);
        glDrawArrays(GL_POINTS, 0, 1);
    }
    
    // Draw the medium broggut grid
    BroggutArray* brogArray = [collisionManager broggutArray];
    int cellsWide, cellsHigh;
    cellsWide = brogArray->bWidth;
    cellsHigh = brogArray->bHeight;
    glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha, 0.0f, 0.1f));
    for (int j = 0; j < cellsHigh; j++) {
        for (int i = 0; i < cellsWide; i++) {
            int straightIndex = i + (j * cellsWide);
            MediumBroggut* broggut = &brogArray->array[straightIndex];
            CGRect brogRect = CGRectMake(xOffset + 1 + i * COLLISION_CELL_WIDTH * xRatio,
                                         yOffset + 1 + j * COLLISION_CELL_HEIGHT * yRatio,
                                         COLLISION_CELL_WIDTH * xRatio, 
                                         COLLISION_CELL_HEIGHT * yRatio);
            if (broggut->broggutValue != -1) {
                if (broggut->broggutEdge == kMediumBroggutEdgeNone) {
                    glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha * 0.1f, 0.0f, 1.0f));
                } else {
                    glColor4f(1.0f, 1.0f, 1.0f, CLAMP(alpha * 0.15f, 0.0f, 1.0f));
                }
                drawFilledRect(brogRect, Vector2fZero);
            }
        }
    }
    
    CGRect viewportRect = CGRectMake(xOffset + visibleScreenBounds.origin.x * xRatio,
                                     yOffset + visibleScreenBounds.origin.y * yRatio,
                                     visibleScreenBounds.size.width * xRatio,
                                     visibleScreenBounds.size.height * yRatio);
    glColor4f(1.0f, 1.0f, 1.0f, alpha);
    if (isTouchMovingOverview) {
        viewportRect = CGRectInset(viewportRect, -5.0f, -5.0f);
        glColor4f(1.0f, 1.0f, 1.0f, alpha - 0.5f);
    }
    drawRect(CGRectInset(viewportRect, 1.0f, 1.0f), Vector2fZero);
    
    // Switch the color array back on and enable textures.  This is the default state
    // for our game engine
    disablePrimitiveDraw();
}

#pragma mark -
#pragma mark Controlling Ships

- (void)renderSelectionAreaWithPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo {
    enablePrimitiveDraw();
    NSArray* pointsAll = [pointsOne arrayByAddingObjectsFromArray:pointsTwo];
    int pointCount = [pointsAll count];
    float* cPoints = malloc(2 * pointCount * sizeof(*cPoints));
    int vertexCounter = 0;
    
    // Put all points into C arrays
    for (int i = 0; i < pointCount; i++) {
        CGPoint point = [[pointsAll objectAtIndex:i] CGPointValue];
        cPoints[vertexCounter++] = point.x;
        cPoints[vertexCounter++] = point.y;
    }
    glLineWidth(2.0f);
    drawLines(cPoints, pointCount, Vector2fZero);
    disablePrimitiveDraw();
    free(cPoints);
}

- (BOOL)attemptToSelectCraftWithinRect:(CGRect)selectionRect {
    NSMutableArray* tempShips = [[NSMutableArray alloc] init];
    BOOL anySelected = NO;
    // Go through all friendly craft and check if we can select them
    for (int i = 0; i < [touchableObjects count]; i++) {
        TouchableObject* object = [touchableObjects objectAtIndex:i];
        if ([object isKindOfClass:[CraftObject class]] && ![object isKindOfClass:[SpiderDroneObject class]]) {
            if (object.isTouchable) {
                if (CGRectContainsPoint([self visibleScreenBounds], object.objectLocation)) {
                    if (object.objectAlliance == kAllianceFriendly) {
                        if (CGRectContainsPoint(selectionRect, object.objectLocation)) {
                            CraftObject* craft = (CraftObject*)object;
                            [tempShips addObject:craft]; // Select ship
                            anySelected = YES;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    if ([tempShips count] > 0) {
        // Deselect all current ships
        for (CraftObject* craft in controlledShips) {
            [craft setIsBeingControlled:NO];
        }
        [controlledShips removeAllObjects];
        for (CraftObject* craft in tempShips) {
            [controlledShips addObject:craft];
            [craft blinkSelectionCircle];
            [craft setIsBeingControlled:YES];
        }
    }
    [tempShips release];
    return anySelected;
}

- (void)attemptToSelectCraftWithinPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo {
    NSArray* pointsAll = [pointsOne arrayByAddingObjectsFromArray:pointsTwo];
    int pointCount = [pointsAll count];
    float* xPoints = malloc(pointCount * sizeof(*xPoints));
    float* yPoints = malloc(pointCount * sizeof(*yPoints));
    Vector2f scroll = [self scrollVectorFromScreenBounds];
    
    // Put all points into C arrays
    for (int i = 0; i < pointCount; i++) {
        CGPoint point = [[pointsAll objectAtIndex:i] CGPointValue];
        xPoints[i] = point.x + scroll.x;
        yPoints[i] = point.y + scroll.y;
    }
    
    NSMutableArray* tempShips = [[NSMutableArray alloc] init];
    
    // Go through all friendly craft and check if we can select them
    for (int i = 0; i < [touchableObjects count]; i++) {
        TouchableObject* object = [touchableObjects objectAtIndex:i];
        if ([object isKindOfClass:[CraftObject class]] && ![object isKindOfClass:[SpiderDroneObject class]]) {
            if (object.isTouchable) {
                if (CGRectContainsPoint([self visibleScreenBounds], object.objectLocation)) {
                    if (object.objectAlliance == kAllianceFriendly) {
                        if (isPointInPoly(pointCount, xPoints, yPoints, object.objectLocation)) {
                            CraftObject* craft = (CraftObject*)object;
                            [tempShips addObject:craft]; // Select ship
                        }
                    }
                }
            }
        }
    }
    
    if ([tempShips count] > 0) {
        // Deselect all current ships
        for (CraftObject* craft in controlledShips) {
            [craft setIsBeingControlled:NO];
        }
        [controlledShips removeAllObjects];
        for (CraftObject* craft in tempShips) {
            [controlledShips addObject:craft];
            [craft setIsBeingControlled:YES];
        }
    }
    [tempShips release];
    
    if ([controlledShips count] > 1) {
        [self spreadOutCurrentlySelectedShips];
    }
    
    free(xPoints);
    free(yPoints);
    [selectionPointsOne removeAllObjects];
    [selectionPointsTwo removeAllObjects];
}

- (void)spreadOutCurrentlySelectedShips {
    int shipCount = [controlledShips count];
    float* pointsX = malloc(shipCount * sizeof(*pointsX));
    float* pointsY = malloc(shipCount * sizeof(*pointsY));
    float averageX = 0.0f;
    float averageY = 0.0f;
    for (int i = 0; i < shipCount; i++) {
        CraftObject* craft = [controlledShips objectAtIndex:i];
        pointsX[i] = craft.objectLocation.x;
        pointsY[i] = craft.objectLocation.y;
        averageX += pointsX[i] / (float)shipCount;
        averageY += pointsY[i] / (float)shipCount;
        if ([craft isFollowingPath]) {
            return;
        }
    }
    
    BOOL allTooClose = YES;
    for (int i = 0; i < shipCount; i++) {
        float pointXOne = pointsX[i];
        float pointYOne = pointsY[i];
        for (int j = i + 1; j < shipCount; j++) {
            float pointXTwo = pointsX[j];
            float pointYTwo = pointsY[j];
            if (GetDistanceBetweenPointsSquared(CGPointMake(pointXOne, pointYOne), CGPointMake(pointXTwo, pointYTwo)) > POW2(COLLISION_CELL_WIDTH)) {
                allTooClose = NO;
            }
        }
    }
    
    if (allTooClose) {
        for (int i = 0; i < shipCount; i++) {
            CraftObject* craft = [controlledShips objectAtIndex:i];
            float currentAngle = 360.0f * ((float)i / (float)shipCount);
            float distance = CLAMP([craft boundingCircle].radius, COLLISION_CELL_WIDTH, FLT_MAX);
            CGPoint newPoint = CGPointMake(averageX + (distance * cosf(DEGREES_TO_RADIANS(currentAngle))),
                                           averageY + (distance * sinf(DEGREES_TO_RADIANS(currentAngle))));
            NSArray* path = [collisionManager pathFrom:craft.objectLocation to:newPoint allowPartial:YES isStraight:YES];
            [craft followPath:path isLooped:NO];
        }
    }
    
    free(pointsX);
    free(pointsY);
}

- (void)addControlledCraft:(CraftObject*)craft {
    if (![craft isKindOfClass:[SpiderDroneObject class]]) {
        [controlledShips addObject:craft];
        [craft setIsBeingControlled:YES];
    }
}

- (void)removeControlledCraft:(CraftObject*)craft {
    [controlledShips removeObject:craft];
    [craft setIsBeingControlled:NO];
}

- (TouchableObject*)attemptToGetEnemyAtLocation:(CGPoint)location {
    for (int i = 0; i < [touchableObjects count]; i++) {
        TouchableObject* object = [touchableObjects objectAtIndex:i];
        if (([object isKindOfClass:[CraftObject class]] || [object isKindOfClass:[StructureObject class]])
            && !object.destroyNow) {
            // Object is a craft or structure
            if (object.objectAlliance == kAllianceFriendly) {
                continue;
            }
            if (CircleContainsPoint(object.touchableBounds, location)) {
                // NSLog(@"Set enemy target to object (%i)", object.uniqueObjectID);
                return object;
                break;
            }
        }
    }
    return nil;
}

- (BOOL)attemptToControlCraftAtLocation:(CGPoint)location { // Returns YES if a ship is controlled
    for (int i = 0; i < [touchableObjects count]; i++) {
        TouchableObject* object = [touchableObjects objectAtIndex:i];
        if ([object isKindOfClass:[CraftObject class]] && !object.destroyNow) {
            // Object is a craft
            if (object.objectAlliance == kAllianceEnemy ||
                !object.isTouchable || object.isPartOfASquad) {
                continue;
            }
            if (CircleContainsPoint(object.touchableBounds, location)) {
                // NSLog(@"Set controlling ship to object (%i)", object.uniqueObjectID);
                [self addControlledCraft:(CraftObject*)object];
                return YES;
            }
        }
    }
    return NO;
}

/*
 - (BOOL)attemptToPutCraft:(CraftObject*)craft inSquadAtLocation:(CGPoint)location {
 for (int i = 0; i < [touchableObjects count]; i++) {
 TouchableObject* object = [touchableObjects objectAtIndex:i];
 if ([object isKindOfClass:[MonarchCraftObject class]] && !object.destroyNow) {
 MonarchCraftObject* monarch = (MonarchCraftObject*)object;
 // Object is a monarch
 if (monarch.objectAlliance == kAllianceEnemy || !monarch.isTouchable || craft.isPartOfASquad) {
 continue;
 }
 if (CircleContainsPoint(object.touchableBounds, location)) {
 // NSLog(@"Attempting to add object (%i) to squad with object (%i)", craft.uniqueObjectID, monarch.uniqueObjectID);
 [monarch addCraftToSquad:craft];
 return YES;
 }
 }
 }
 return NO;
 }
 */

- (void)controlNearestShipToLocation:(CGPoint)location {
    float minDistance = fullMapBounds.size.width + fullMapBounds.size.height; // Set to above max distance
    CraftObject* closestCraft = nil;
    for (int i = 0; i < [touchableObjects count]; i++) {
        TouchableObject* object = [touchableObjects objectAtIndex:i];
        if ([object isKindOfClass:[CraftObject class]] && !object.destroyNow) {
            if (object.objectAlliance == kAllianceEnemy) {
                continue;
            }
            float curDist = GetDistanceBetweenPoints(location, object.objectLocation);
            if (curDist < minDistance) {
                minDistance = curDist;
                closestCraft = (CraftObject*)object;
            }
        }
    }
    if (closestCraft) {
        [self addControlledCraft:closestCraft];
    } else {
        [self setCameraLocation:homeBaseLocation];
        [self setMiddleOfVisibleScreenToCamera];
    }
}

#pragma mark -
#pragma mark Purchasing Craft and Structures

- (void)failedToCreateAtLocation:(CGPoint)location withFailType:(int)failtype {
    switch (failtype) {
        case kProfileFailBroggutsAndMetal:
            [self showHelpMessageWithMessageID:kHelpMessageNeedBroggutsAndMetal];
            break;
        case kProfileFailBrogguts:
            [self showHelpMessageWithMessageID:kHelpMessageNeedBrogguts];
            break;
        case kProfileFailMetal:
            [self showHelpMessageWithMessageID:kHelpMessageNeedMetal];
            break;
        default:
            break;
    }
}

- (void)attemptToCreateCraftWithID:(int)craftID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance {
    if (numberOfCurrentShips >= TOTAL_CRAFT_LIMIT) {
        [self showHelpMessageWithMessageID:kHelpMessageNeedUnitLimit];
        return;
    }
    if (numberOfCurrentShips >= [self currentMaxShipSupply]) {
        [self showHelpMessageWithMessageID:kHelpMessageNeedMoreBlocks];
        return;
    }
    switch (craftID) {
        case kObjectCraftAntID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftAntCostBrogguts metal:kCraftAntCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftAntCostBrogguts atLocation:location withAlliance:alliance];
                AntCraftObject* newCraft = [[AntCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftMothID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftMothCostBrogguts metal:kCraftMothCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftMothCostBrogguts atLocation:location withAlliance:alliance];
                MothCraftObject* newCraft = [[MothCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftBeetleID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftBeetleCostBrogguts metal:kCraftBeetleCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftBeetleCostBrogguts atLocation:location withAlliance:alliance];
                BeetleCraftObject* newCraft = [[BeetleCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftMonarchID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftMonarchCostBrogguts metal:kCraftMonarchCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftMonarchCostBrogguts atLocation:location withAlliance:alliance];
                MonarchCraftObject* newCraft = [[MonarchCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftCamelID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftCamelCostBrogguts metal:kCraftCamelCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftCamelCostBrogguts atLocation:location withAlliance:alliance];
                CamelCraftObject* newCraft = [[CamelCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftRatID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftRatCostBrogguts metal:kCraftRatCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftRatCostBrogguts atLocation:location withAlliance:alliance];
                RatCraftObject* newCraft = [[RatCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftSpiderID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftSpiderCostBrogguts metal:kCraftSpiderCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftSpiderCostBrogguts atLocation:location withAlliance:alliance];
                SpiderCraftObject* newCraft = [[SpiderCraftObject alloc] initWithLocation:location isTraveling:YES];
                [newCraft setCurrentScene:self];
                for (int i = 0; i < SPIDER_NUMBER_OF_DRONES; i++) {
                    [newCraft addNewDroneToBay];
                }
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectCraftEagleID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kCraftEagleCostBrogguts metal:kCraftEagleCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kCraftEagleCostBrogguts atLocation:location withAlliance:alliance];
                EagleCraftObject* newCraft = [[EagleCraftObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newCraft setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newCraft setObjectLocation:enemyBaseLocation];
                }
                [newCraft setObjectAlliance:alliance];
                [self createLocalTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newCraft withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        default:
            NSLog(@"Tried to create craft with invalid ID (%i)", craftID);
            break;
    }
}

- (void)attemptToCreateStructureWithID:(int)structureID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance {
    if (isBuildingStructure) {
        return;
    }
    if (numberOfCurrentStructures >= TOTAL_STRUCTURE_LIMIT) {
        [self showHelpMessageWithMessageID:kHelpMessageNeedStructureLimit];
        return;
    }
    if (![collisionManager isPathNodeOpenAtLocation:location]) {
        [self showHelpMessageWithMessageID:kHelpMessageNeedStructureBuilding];
        return;
    }
    switch (structureID) {
        case kObjectStructureBaseStationID: {
            NSLog(@"Shouldn't create another base station!");
            break;
        }
        case kObjectStructureBlockID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureBlockCostBrogguts metal:kStructureBlockCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureBlockCostBrogguts atLocation:location withAlliance:alliance];
                BlockStructureObject* newStructure = [[BlockStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureTurretID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureTurretCostBrogguts metal:kStructureTurretCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureTurretCostBrogguts atLocation:location withAlliance:alliance];
                TurretStructureObject* newStructure = [[TurretStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureRadarID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureRadarCostBrogguts metal:kStructureRadarCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureRadarCostBrogguts atLocation:location withAlliance:alliance];
                RadarStructureObject* newStructure = [[RadarStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureFixerID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureFixerCostBrogguts metal:kStructureFixerCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureFixerCostBrogguts atLocation:location withAlliance:alliance];
                FixerStructureObject* newStructure = [[FixerStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureRefineryID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureRefineryCostBrogguts metal:kStructureRefineryCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureRefineryCostBrogguts atLocation:location withAlliance:alliance];
                RefineryStructureObject* newStructure = [[RefineryStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureCraftUpgradesID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureCraftUpgradesCostBrogguts metal:kStructureCraftUpgradesCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureCraftUpgradesCostBrogguts atLocation:location withAlliance:alliance];
                CraftUpgradesStructureObject* newStructure = [[CraftUpgradesStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        case kObjectStructureStructureUpgradesID: {
            int failType = [[sharedGameController currentProfile] subtractBrogguts:kStructureStructureUpgradesCostBrogguts metal:kStructureStructureUpgradesCostMetal];
            if (failType == kProfileNoFail) {
                [self addBroggutTextValue:-kStructureStructureUpgradesCostBrogguts atLocation:location withAlliance:alliance];
                StructureUpgradesStructureObject* newStructure = [[StructureUpgradesStructureObject alloc] initWithLocation:location isTraveling:YES];
                if (alliance == kAllianceFriendly) {
                    [newStructure setObjectLocation:homeBaseLocation];
                } else if (alliance == kAllianceEnemy) {
                    [newStructure setObjectLocation:enemyBaseLocation];
                }
                [newStructure setObjectAlliance:alliance];
                [self createLocalTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
                BuildingObject* tempObject = [[BuildingObject alloc] initWithObject:newStructure withLocation:location];
                [self addCollidableObject:tempObject];
            } else {
                [self failedToCreateAtLocation:location withFailType:failType];
            }
            break;
        }
        default:
            NSLog(@"Tried to create structure with invalid ID (%i)", structureID);
            break;
    }
}

- (void)showBuildingValuesWithBrogguts:(int)brogguts withMetal:(int)metal atLocation:(CGPoint)location {
    NSString* broggutsString = [NSString stringWithFormat:@"Bgs: %i", brogguts];
    NSString* metalString = [NSString stringWithFormat:@"Mtl: %i", metal];
    float bWidth = [self getWidthForFontID:kFontBlairID withString:broggutsString];
    float fixedDistance = 16.0f;
    
    [buildBroggutValue setIsTextHidden:NO];
    [buildMetalValue setIsTextHidden:NO];
    
    [buildBroggutValue setObjectText:broggutsString];
    [buildBroggutValue setFontColor:Color4fMake(0.5f, 1.0f, 0.0f, 0.8f)];
    [buildBroggutValue setObjectLocation:CGPointMake(location.x - bWidth - (fixedDistance / 2), location.y + 48)];
    [buildMetalValue setObjectText:metalString];
    [buildMetalValue setFontColor:Color4fMake(0.0f, 0.5f, 1.0f, 0.8f)];
    [buildMetalValue setObjectLocation:CGPointMake(location.x + (fixedDistance / 2), location.y + 48)];
}

#pragma mark -
#pragma mark Match Control

- (void)otherPlayerDisconnected {
    if (isMultiplayerMatch)
        [[GameController sharedGameController] returnToMainMenuWithSave:NO];
}

#pragma mark -
#pragma mark Touch Events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    if (isMissionOver) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([endMissionObject rect], touchLocation)) {
            [endMissionObject touchesBeganAtLocation:touchLocation];
        }
        return;
    }
    NSArray* touchesArray = [touches allObjects];
    for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
        
        // Check if the touch is in the (active) sidebar
        if (CGRectContainsPoint([sideBar sideBarRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
            if ([sideBar isSideBarShowing]) {
                if (touch.tapCount == 2) {
                    [sideBar touchesDoubleTappedAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                } else {
                    [sideBar touchesBeganAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                    [currentTouchesInSideBar setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:[touch hash]]];
                }
            }
            continue;
        }
        
        // Check if there are more than 1 touches (start selection area)
        if ([touches count] == 2) {
            if ([touch hash] == [[touchesArray objectAtIndex:0] hash]) {
                selectionTouchHashOne = [[touchesArray objectAtIndex:0] hash];
                NSValue* value = [NSValue valueWithCGPoint:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                [selectionPointsOne addObject:value];
            }
            if ([touch hash] == [[touchesArray objectAtIndex:1] hash]) {
                selectionTouchHashTwo = [[touchesArray objectAtIndex:1] hash];
                NSValue* value = [NSValue valueWithCGPoint:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                [selectionPointsTwo insertObject:value atIndex:0];
            }
            isSelectingShips = YES;
            continue;
        }
        
        // Check if the touch is in the button to bring out the sidebar
        if (isAllowingSidebar) {
            if (CGRectContainsPoint([sideBar buttonRect], [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero])) {
                if (![sideBar isSideBarShowing]) {
                    [sideBar moveSideBarIn];
                } else {
                    [sideBar moveSideBarOut];
                }
                continue;
            }
        }
        
        if (isAllowingOverview) {
            if (isShowingOverview) {
                if (!isTouchMovingOverview) {
                    float xRatio = visibleScreenBounds.size.width / fullMapBounds.size.width;
                    float yRatio = visibleScreenBounds.size.height / fullMapBounds.size.height;
                    CGRect viewportRect = CGRectMake(visibleScreenBounds.origin.x * xRatio,
                                                     visibleScreenBounds.origin.y * yRatio,
                                                     visibleScreenBounds.size.width * xRatio,
                                                     visibleScreenBounds.size.height * yRatio);
                    CGPoint localTouchLoc = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
                    if (CGRectContainsPoint(viewportRect, localTouchLoc)) {
                        isTouchMovingOverview = YES;
                        movingOverviewTouchHash = [touch hash];
                        currentOverViewPoint = localTouchLoc;
                        break;
                    }
                }
            }
        }
        
        // If it is somewhere else, scroll using this touch
        if ([touches count] == 1 && !isSelectingShips && [currentObjectsTouching count] == 0 && !isTouchScrolling && (!isShowingOverview || isFadingOverviewOut)) {
            isTouchScrolling = YES;
            movingTouchHash = [touch hash];
            currentTouchLocation = touchLocation;
        }
        
        BOOL noObjectTouched = YES;
        // Check all touchable objects and call their methods
        for (int i = 0; i < [touchableObjects count]; i++) {
            TouchableObject* obj = [touchableObjects objectAtIndex:i];
            if (obj.isTouchable) {
                if (CircleContainsPoint(obj.touchableBounds, touchLocation)) {
                    if (!obj.isCurrentlyTouched && !obj.isPartOfASquad) {
                        if (touch.tapCount == 2) {
                            [obj touchesDoubleTappedAtLocation:touchLocation];
                        } else {
                            obj.isCurrentlyTouched = YES;
                            [obj touchesHoveredOver];
                            [obj touchesBeganAtLocation:touchLocation];
                            [currentObjectsTouching setObject:obj forKey:[NSNumber numberWithInt:[touch hash]]];
                            [currentObjectsHovering setObject:obj forKey:[NSNumber numberWithInt:[touch hash]]];
                            if ([touches count] == 1) isTouchScrolling = NO;
                        }
                        noObjectTouched = NO;
                        break;
                    }
                }
            }
        }
        
        if (!isSelectingShips && noObjectTouched) { // If touch used for scrolling, stop the current path
            for (CraftObject* craft in controlledShips) {
                [craft stopFollowingCurrentPath];
            }
        }
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    if (isMissionOver) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint previousOrigTouchLocation = [touch previousLocationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        CGPoint prevTouchLocation = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([endMissionObject rect], touchLocation)) {
            [endMissionObject touchesMovedToLocation:touchLocation from:prevTouchLocation];
        }
        return;
    }
    // Loop through all the touches
    for (UITouch *touch in touches) {
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint previousOrigTouchLocation = [touch previousLocationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
        CGPoint prevTouchLocation = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:visibleScreenBounds];
        
        // Check if the touch is in the (active) sidebar
        if ([[currentTouchesInSideBar objectForKey:[NSNumber numberWithInt:[touch hash]]] intValue] == 1) {
            if ([sideBar isSideBarShowing] && movingTouchHash != [touch hash]) {
                CGPoint toPoint = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
                CGPoint fromPoint = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:CGRectZero];
                [sideBar touchesMovedToLocation:toPoint from:fromPoint];
                continue;
            }
        }
        
        // Check if there are more than 2 touches (bring up overview)
        if ([touches count] >= 3 && isAllowingOverview) {
            float dy = touchLocation.y - prevTouchLocation.y;
            if (fabsf(dy) > OVERVIEW_MIN_FINGER_DISTANCE
                && !isFadingOverviewIn && !isFadingOverviewOut) {
                [selectionPointsOne removeAllObjects];
                [selectionPointsTwo removeAllObjects];
                selectionTouchHashOne = -1;
                selectionTouchHashTwo = -1;
                isSelectingShips = NO;
                if (!isShowingOverview) {
                    [self fadeOverviewMapIn];
                    [sideBar moveSideBarOut];
                } else
                    [self fadeOverviewMapOut];
                break;
            }
        }
        
        if (isAllowingOverview) {
            if (isShowingOverview) {
                if (isTouchMovingOverview && movingOverviewTouchHash == [touch hash]) {
                    float xRatio = visibleScreenBounds.size.width / fullMapBounds.size.width;
                    float yRatio = visibleScreenBounds.size.height / fullMapBounds.size.height;
                    CGPoint localTouchLoc = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
                    currentOverViewPoint = localTouchLoc;
                    [self setCameraLocation:CGPointMake(currentOverViewPoint.x / xRatio, currentOverViewPoint.y / yRatio)];
                    [self setMiddleOfVisibleScreenToCamera];
                    [self scrollScreenWithVector:Vector2fMake(touchLocation.x - prevTouchLocation.x, touchLocation.y - prevTouchLocation.y)];
                    break;
                }
            }
        }
        
        // If the touch is a selection touch
        if (isSelectingShips) {
            CGPoint thisTouch = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
            if ([touch hash] == selectionTouchHashOne) {
                if ([selectionPointsOne count] == 0) {
                    NSValue* value = [NSValue valueWithCGPoint:thisTouch];
                    [selectionPointsOne addObject:value];
                } else {
                    CGPoint prevPoint = [[selectionPointsOne lastObject] CGPointValue];
                    if (GetDistanceBetweenPoints(prevPoint, thisTouch) >= SELECTION_MIN_DISTANCE) {
                        NSValue* value = [NSValue valueWithCGPoint:thisTouch];
                        [selectionPointsOne addObject:value];
                    }
                }
            }
            if ([touch hash] == selectionTouchHashTwo) {
                if ([selectionPointsTwo count] == 0) {
                    NSValue* value = [NSValue valueWithCGPoint:thisTouch];
                    [selectionPointsTwo addObject:value];
                } else {
                    CGPoint prevPoint = [[selectionPointsTwo objectAtIndex:0] CGPointValue];
                    if (GetDistanceBetweenPoints(prevPoint, thisTouch) >= SELECTION_MIN_DISTANCE) {
                        NSValue* value = [NSValue valueWithCGPoint:thisTouch];
                        [selectionPointsTwo insertObject:value atIndex:0];
                    }
                }
            }
            continue;
        }
        
        // Update the position of the camera moving/scrolling touch
        if (movingTouchHash == [touch hash]) {
            currentTouchLocation = touchLocation;
        }
        
        // Check if the current hovered object no longer is being hovered over
        TouchableObject* currentHover = [currentObjectsHovering objectForKey:[NSNumber numberWithInt:[touch hash]]];
        if (currentHover && !CircleContainsPoint(currentHover.touchableBounds, touchLocation)) {
            [currentHover touchesHoveredLeft];
        }
        
        // Check each touchable object and see which object is closest to the touch
        float minDistance = visibleScreenBounds.size.width + visibleScreenBounds.size.height;
        TouchableObject* closestObj = nil;
        for (int i = 0; i < [touchableObjects count]; i++) {
            TouchableObject* obj = [touchableObjects objectAtIndex:i];
            if (obj.isTouchable) {
                float distance = GetDistanceBetweenPoints(obj.objectLocation, touchLocation);
                if (distance < minDistance && CircleContainsPoint(obj.touchableBounds, touchLocation)) {
                    minDistance = distance;
                    closestObj = obj;
                }
            }
        }
        
        // If there was an object hovered over, add it to the dictionary
        if (closestObj) {
            // Check if there is a current hover object
            TouchableObject* currentHover = [currentObjectsHovering objectForKey:[NSNumber numberWithInt:[touch hash]]];
            if (currentHover && currentHover != closestObj) {
                [currentHover touchesHoveredLeft];
            }
            [currentObjectsHovering setObject:closestObj forKey:[NSNumber numberWithInt:[touch hash]]];
            [closestObj touchesHoveredOver];
        }
        
        // Call the touches Moved method on the current object that owns this touch
        TouchableObject* currentObj = [currentObjectsTouching objectForKey:[NSNumber numberWithInt:[touch hash]]];
        if (currentObj) {
            [currentObj touchesMovedToLocation:touchLocation from:prevTouchLocation];
        }
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    [self touchesEnded:touches withEvent:event view:aView];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    if (isMissionOver) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([endMissionObject rect], touchLocation)) {
            [endMissionObject touchesEndedAtLocation:touchLocation];
        }
        return;
    }
    for (UITouch *touch in touches) {
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:visibleScreenBounds];
        
        // Call hover left method on the object that was hovered over by that touch
        TouchableObject* currentHoverObj = [currentObjectsHovering objectForKey:[NSNumber numberWithInt:[touch hash]]];
        if (currentHoverObj) {
            [currentHoverObj touchesHoveredLeft];
            [currentObjectsHovering removeObjectForKey:[NSNumber numberWithInt:[touch hash]]];
        }
        
        if (isAllowingOverview) {
            if (isShowingOverview) {
                if (isTouchMovingOverview && movingOverviewTouchHash == [touch hash]) {
                    isTouchMovingOverview = NO;
                    float xRatio = visibleScreenBounds.size.width / fullMapBounds.size.width;
                    float yRatio = visibleScreenBounds.size.height / fullMapBounds.size.height;
                    CGPoint localTouchLoc = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
                    currentOverViewPoint = localTouchLoc;
                    /*
                     if ([self attemptToSelectCraftWithinRect:[self visibleScreenBounds]]) {
                     [self setCameraLocation:CGPointMake(currentOverViewPoint.x / xRatio, currentOverViewPoint.y / yRatio)];
                     [self setMiddleOfVisibleScreenToCamera];
                     [self fadeOverviewMapOut];
                     }
                     */
                    for (CraftObject* craft in controlledShips) {
                        [craft setIsBeingControlled:NO];
                    }
                    [controlledShips removeAllObjects];
                    [self setCameraLocation:CGPointMake(currentOverViewPoint.x / xRatio, currentOverViewPoint.y / yRatio)];
                    [self setMiddleOfVisibleScreenToCamera];
                    [self fadeOverviewMapOut];
                    break;
                }
            }
        }
        
        // If the touch is a selection touch
        if (isSelectingShips) {
            if ([touch hash] == selectionTouchHashOne) {
                NSValue* value = [NSValue valueWithCGPoint:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                [selectionPointsOne addObject:value];
                selectionTouchHashOne = -1;
                if (selectionTouchHashTwo == -1) {
                    [self attemptToSelectCraftWithinPoints:selectionPointsOne andPoints:selectionPointsTwo];
                    isSelectingShips = NO;
                }
            }
            if ([touch hash] == selectionTouchHashTwo) {
                NSValue* value = [NSValue valueWithCGPoint:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                [selectionPointsTwo insertObject:value atIndex:0];
                selectionTouchHashTwo = -1;
                if (selectionTouchHashOne == -1) {
                    [self attemptToSelectCraftWithinPoints:selectionPointsOne andPoints:selectionPointsTwo];
                    isSelectingShips = NO;
                }
            }
            continue;
        }
        
        // Call touches ended method for object that owns that touch
        TouchableObject* currentObj = [currentObjectsTouching objectForKey:[NSNumber numberWithInt:[touch hash]]];
        if (currentObj) {
            [currentObj touchesEndedAtLocation:touchLocation];
            [currentObjectsTouching removeObjectForKey:[NSNumber numberWithInt:[touch hash]]];
            currentObj.isCurrentlyTouched = NO;
        }
        
        // Check if the touch is in the (active) sidebar
        if ([[currentTouchesInSideBar objectForKey:[NSNumber numberWithInt:[touch hash]]] intValue] == 1) {
            if ([sideBar isSideBarShowing] && movingTouchHash != [touch hash]) {
                [sideBar touchesEndedAtLocation:[sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero]];
                [currentTouchesInSideBar removeObjectForKey:[NSNumber numberWithInt:[touch hash]]];
                continue;
            }
        }
        
        if ([touch hash] == movingTouchHash) {
            currentTouchLocation = touchLocation;
            isTouchScrolling = NO;
            movingTouchHash = 0;
        }
    }
}



@end