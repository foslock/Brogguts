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

#define COLLISION_CELL_WIDTH 128.0f
#define COLLISION_CELL_HEIGHT 128.0f

// Class responsible for passing touch and game events to the correct game
// scene.  A game scene is an object which is responsible for a specific
// scene within the game i.e. Main menu, main game, high scores etc.
// The state manager hold the currently active scene and the game controller
// will then pass the necessary messages to that scene.
//
@interface GameController : NSObject {
	
	// Player profile
	PlayerProfile* currentPlayerProfile;
	
	///////////////////// Views and orientation
	EAGLView *eaglView;						// Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation
	BroggutScene* currentScene;
	
    ///////////////////// Game controller iVars	
    NSDictionary *gameScenes;				// Dictionary of the different game scenes
}

@property (retain) PlayerProfile* currentPlayerProfile;
@property (nonatomic, retain) BroggutScene *currentScene;
@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) NSDictionary *gameScenes;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController*)sharedGameController;

// Deal with loading and saving the player data
- (void)loadPlayerProfile;
- (void)savePlayerProfile;

- (NSString*)documentsPathWithFilename:(NSString*)filename;

- (void)createBaseCampLevel;
- (BroggutScene*)sceneFromLevelWithFilename:(NSString*)filename;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Returns an adjusted touch point based on the orientation of the device and the scrolled visible viewport
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch inScreenBounds:(CGRect)bounds;

@end

