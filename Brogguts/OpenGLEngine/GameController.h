//
//  GameController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "BroggutScene.h"
#import "BaseCampScene.h"
#import "Global.h"

@class BroggutScene;
@class EAGLView;
@class PlayerProfile;
@class TextObject;

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

extern NSString* kBaseCampFileName;
extern NSString* kSavedScenesFileName;
extern NSString* kNewMapScenesFileName;

#define COLLISION_CELL_WIDTH 128.0f
#define COLLISION_CELL_HEIGHT 128.0f
#define FADING_RECT_ALPHA_RATE 0.015f
#define CRAFT_COLLISION_YESNO YES
#define STRUCTURE_COLLISION_YESNO YES

// Class responsible for passing touch and game events to the correct game
// scene.  A game scene is an object which is responsible for a specific
// scene within the game i.e. Main menu, main game, high scores etc.
// The state manager hold the currently active scene and the game controller
// will then pass the necessary messages to that scene.
//
@interface GameController : NSObject {
	
	// Player profile
	PlayerProfile* currentPlayerProfile;
	
	// Views and orientation
	EAGLView *eaglView;								// Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation
	BroggutScene* currentScene;
	
	// Scene transition vars
	NSString* transitionName;
	TextObject* sceneNameObject;
	BOOL isAlreadyInScene;
	BOOL isFadingSceneIn;
	BOOL isFadingSceneOut;
	float fadingRectAlpha;
    BOOL isTutorial;
    BOOL isReturningToMenu;
	
    // Game controller iVars	
    NSDictionary *gameScenes;						// Dictionary of the different game scenes
}

@property (retain) NSString* transitionName;
@property (retain) PlayerProfile* currentPlayerProfile;
@property (nonatomic, retain) BroggutScene *currentScene;
@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) NSDictionary *gameScenes;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (readonly) BOOL isFadingSceneIn;
@property (readonly) BOOL isFadingSceneOut;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController*)sharedGameController;

// Deal with loading and saving the player data
- (void)loadPlayerProfile;
- (void)savePlayerProfile;

- (NSString*)documentsPathWithFilename:(NSString*)filename;
- (BOOL)doesFilenameExistInDocuments:(NSString*)filename;

- (void)insertCGPoint:(CGPoint)point intoArray:(NSMutableArray*)array atIndex:(int)index;
- (CGPoint)getCGPointFromArray:(NSArray*)array atIndex:(int)index;

- (void)placeInitialFilesInDocumentsFolder;
- (void)createBlankSceneWithWidthCells:(int)width withHeightCells:(int)height withName:(NSString*)name;
- (void)createInitialBaseCampLevel;
- (BOOL)saveCurrentSceneWithFilename:(NSString*)filename allowOverwrite:(BOOL)overwrite; // Returns success
- (void)addFilenameToSceneFileList:(NSString*)filename;

// Transitions to the scene with the given filename
- (void)returnToMainMenu;
- (void)transitionToSceneWithFileName:(NSString*)fileName isTutorial:(BOOL)tutorial isNew:(BOOL)isNewScene;
- (void)loadTutorialLevelsForIndex:(int)index;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Returns an adjusted touch point based on the orientation of the device and the scrolled visible viewport
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch inScreenBounds:(CGRect)bounds;

@end

