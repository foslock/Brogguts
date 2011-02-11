//
//  GameController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameController.h"
#import "OpenGLEngineAppDelegate.h"
#import "AbstractScene.h"
#import "BaseCampScene.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private) 
// Initializes OpenGL
- (void)initGameController;

@end

static GameController* sharedGameController = nil;

@implementation GameController

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

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
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
	
	interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
	CGRect fullMapRect = CGRectMake(0, 0, kPadScreenLandscapeWidth * 4, kPadScreenLandscapeHeight * 4);
	CGRect visibleRect = CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
	
	// Load the game scenes
    gameScenes = [[NSMutableDictionary alloc] init];
	AbstractScene *scene = [[BaseCampScene alloc] initWithScreenBounds:visibleRect withFullMapBounds:fullMapRect];
	
	[gameScenes setValue:scene forKey:@"BaseCamp"];
	[scene release];
    
    // Set the starting scene for the game
    currentScene = [gameScenes objectForKey:@"BaseCamp"];
	
    NSLog(@"INFO - GameController: Finished game initialization.");
}

@end
