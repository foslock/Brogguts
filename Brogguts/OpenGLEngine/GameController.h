//
//  GameController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "AbstractScene.h"
#import "BaseCampScene.h"
#import "Global.h"

@class AbstractScene;
@class EAGLView;

// Class responsible for passing touch and game events to the correct game
// scene.  A game scene is an object which is responsible for a specific
// scene within the game i.e. Main menu, main game, high scores etc.
// The state manager hold the currently active scene and the game controller
// will then pass the necessary messages to that scene.
//
@interface GameController : NSObject {
	
	///////////////////// Views and orientation
	EAGLView *eaglView;						// Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation
	AbstractScene* currentScene;
	
    ///////////////////// Game controller iVars	
    NSDictionary *gameScenes;				// Dictionary of the different game scenes
}


@property (nonatomic, retain) AbstractScene *currentScene;
@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) NSDictionary *gameScenes;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController*)sharedGameController;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Returns an adjusted touch point based on the orientation of the device and the scrolled visible viewport
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch inScreenBounds:(CGRect)bounds;

@end

