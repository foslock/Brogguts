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
@class UnlockPresentView;

#pragma mark -
#pragma mark Scene storage 

enum kSceneStorageGlobals {
    kSceneStorageGlobalName,
    kSceneStorageGlobalSceneType,
    kSceneStorageGlobalWidthCells,
    kSceneStorageGlobalHeightCells,
    kSceneStorageGlobalSmallBrogguts,
    kSceneStorageGlobalAIController,
    kSceneStorageGlobalMediumBroggutArray,
    kSceneStorageGlobalObjectArray,
};

enum kSceneAIControllerIndexes {
    kSceneAIControllerSpawnerInfos,
    kSceneAIControllerDialogueInfos,
    kSceneAIControllerSceneTime,
    kSceneAIControllerPurchasedUpgrades,
    kSceneAIControllerCompletedUpgrades,
    kSceneAIControllerBrogguts,
    kSceneAIControllerMetal,
    kSceneAIControllerFogData,
};

enum kSceneStorageIndexes {
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
    kSceneStorageIndexOtherInfo, // - other info (used to store things in progress)
};

enum kSceneStorageOtherInfoIndexes {
    kSceneStorageOtherInfoUpgradeInfo, // - Upgrade-in-progress info,
};

enum kSceneStorageOtherInfoUpgradeInfoIndexes {
    kSceneStorageOtherInfoUpgradeInfoObjectID, // ID of upgrade being researched
    kSceneStorageOtherInfoUpgradeInfoProgressTime, // Progress of upgrade
};

extern NSString* kBaseCampFileName;
extern NSString* kSavedCampaignFileName;
extern NSString* kSavedSkirmishFileName;
extern NSString* kNewMapScenesFileName;

extern BOOL doesSceneHideGrid;
extern int sideBarButtonLocation;
extern BOOL isColorBlindFriendlyOn;

#define COLLISION_CELL_WIDTH 128.0f
#define COLLISION_CELL_HEIGHT 128.0f
#define FADING_RECT_ALPHA_RATE 0.015f
#define CRAFT_COLLISION_YESNO YES
#define STRUCTURE_COLLISION_YESNO NO
#define CRAFT_ALLIANCE_TINT_AMOUNT 0.25f

enum SceneTypes {
    kSceneTypeBaseCamp,
    kSceneTypeTutorial,
    kSceneTypeCampaign,
    kSceneTypeSkirmish,
};

@interface GameController : NSObject {
	// Player profile
	PlayerProfile* currentProfile;
	
	// Views and orientation
    UIView* containerView;
	EAGLView *eaglView;								// Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation
	BroggutScene* currentScene;
    BroggutScene* justMadeScene;
    BOOL isUpdatingCurrentScene;
    
    // Unlock presentation view
    BOOL isShowingUnlockView;
    UnlockPresentView* unlockView;
	
	// Scene transition vars
	NSString* transitionName;
	TextObject* sceneNameObject;
	BOOL isAlreadyInScene;
	BOOL isFadingSceneIn;
	BOOL isFadingSceneOut;
	float fadingRectAlpha;
    int currentSceneType;
    int currentSceneIndex;
    BOOL isNewSceneNew;
    BOOL isReturningToMenu;
    BOOL isSavingFadingScene;
    BOOL isLoadingSavedScene;
    
    BOOL isShowingBroggupediaInScene;
	
    // Game controller iVars	
    NSMutableDictionary *gameScenes;				// Dictionary of the different game scenes
}

@property (retain) NSString* transitionName;
@property (retain) PlayerProfile* currentProfile;
@property (nonatomic, retain) BroggutScene *currentScene;
@property (nonatomic, retain) BroggutScene *justMadeScene;
@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) NSMutableDictionary *gameScenes;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (readonly) BOOL isFadingSceneIn;
@property (readonly) BOOL isFadingSceneOut;
@property (readonly) BOOL isReturningToMenu;
@property (readonly) BOOL isAlreadyInScene;
@property (readonly) BOOL isShowingUnlockView;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController*)sharedGameController;

+ (void)setGlColorFriendly:(float)alpha;
+ (void)setGlColorEnemy:(float)alpha;
+ (void)setGlColorNeutral:(float)alpha;
+ (Color4f)getColorFriendly:(float)alpha;
+ (Color4f)getColorEnemy:(float)alpha;
+ (Color4f)getColorNeutral:(float)alpha;
+ (Color4f)getShadeColorFriendly:(float)alpha;
+ (Color4f)getShadeColorEnemy:(float)alpha;
+ (Color4f)getShadeColorNeutral:(float)alpha;

- (void)pushUnlockViewIn;
- (void)pushUnlockViewOut;

- (void)presentBroggupedia;
- (void)dismissBroggupedia;

// Deal with loading and saving the player data
- (void)loadPlayerProfile;
- (void)savePlayerProfile;

- (NSString*)documentsPathWithFilename:(NSString*)filename;
- (BOOL)doesFilenameExistInDocuments:(NSString*)filename;

- (void)resetAllProgress;

- (void)insertCGPoint:(CGPoint)point intoArray:(NSMutableArray*)array atIndex:(int)index;
- (CGPoint)getCGPointFromArray:(NSArray*)array atIndex:(int)index;

- (void)placeInitialFilesInDocumentsFolder;
- (void)createBlankSceneWithWidthCells:(int)width withHeightCells:(int)height withName:(NSString*)name;
- (void)createInitialBaseCampLevel;
- (NSArray*)convertSavedPath:(NSArray*)savedPath;
- (BOOL)saveCurrentSceneWithFilename:(NSString*)filename allowOverwrite:(BOOL)overwrite; // Returns success
- (void)addFilenameToSkirmishFileList:(NSString*)filename;
- (void)addFilenameToSavedCampaignFileList:(NSString*)filename;

// Transitions to the scene with the given filename
- (void)returnToMainMenuWithSave:(BOOL)save;
- (void)fadeOutToSceneWithFilename:(NSString*)fileName sceneType:(int)sceneType withIndex:(int)index isNew:(BOOL)isNewScene isLoading:(BOOL)loading;
- (void)loadCampaignLevelsForIndex:(int)index withLoaded:(BOOL)loaded;
- (void)loadTutorialLevelsForIndex:(int)index;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Called on a timer when the current player wants to start a multiplayer match
- (void)checkForRemotePlayer:(NSTimer*)timer;

// Returns an adjusted touch point based on the orientation of the device and the scrolled visible viewport
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch inScreenBounds:(CGRect)bounds;

@end

