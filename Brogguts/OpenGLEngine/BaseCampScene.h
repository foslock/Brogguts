//
//  GameScene.h
//  SLQTSOR
//
//  Created by Mike Daley on 29/08/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "AbstractScene.h"

@class Image;
@class ImageRenderSingleton;
@class GameCenterSingleton;
@class GameController;
@class SoundSingleton;
@class BitmapFont;
@class ParticleEmitter;
@class StarSingleton;
@class BitmapFont;
@class TextObject;

@interface BaseCampScene : AbstractScene {

	////////////////////// Singleton references
	GameController *sharedGameController;				// Reference to the game controller
	ImageRenderSingleton *sharedImageRenderSingleton;	// Reference to the image render manager
	SoundSingleton *sharedSoundSingleton;				// Reference to the sound manager
	GameCenterSingleton* sharedGameCenterSingleton;		// Reference to the game center controller
	StarSingleton* sharedStarSingleton;					// Reference to the star controller
	
	// Camera Image
	Image *cameraImage;
	
	// Player location and velocity vector
	CGPoint playerLocation;
	Vector2f playerMomentumForce;
	
	// Gothic Font
	TextObject* textObject;
	
	////////////////////// Images
	CGPoint currentTouchLocation;
	int movingTouchHash;		// Holds the unique hash value given to a touch on the joypad.  
								// This allows us to track the same touch during touchesMoved events
	BOOL isTouchScrolling;	// YES if a touch is being tracked for the joypad
	
	ParticleEmitter* currentEmitter;
	
}

@end
