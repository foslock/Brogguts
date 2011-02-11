//
//  AbstractState.h
//  SLQTSOR
//
//  Created by Michael Daley on 01/06/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define COLLISION_CELL_WIDTH 128.0f
#define COLLISION_CELL_HEIGHT 128.0f
#define SCROLL_BOUNDS_X_INSET 500.0f
#define SCROLL_BOUNDS_Y_INSET 350.0f
#define SCROLL_MAX_SPEED 10.0f
#define INITIAL_OBJECT_CAPACITY 100
#define FRAME_COUNTER_MAX 100

@class CollisionManager;

// This is an abstract class which contains the basis for any game scene which is going
// to be used.  A game scene is a self contained class which is responsible for updating 
// the logic and rendering the screen for the current scene.  It is simply a way to 
// encapsulate a specific scenes code in a single class.
//
// The Director class controls which scene is the current scene and it is this scene which
// is updated and rendered during the game loop.
//
@interface AbstractScene : NSObject {
	
	// Object management
	NSMutableArray* renderableObjects;			 // The array of objects that need to be updated and rendered
	NSMutableArray* renderableDestroyed;		 // The array of objects that need to be destroyed through the next frame pass
	NSMutableArray* touchableObjects;			 // The array of objects that need to be checked for touches in ADDITION to rendered/updated
	NSMutableDictionary* currentObjectsTouching; // Key: numerical hash value of the touch. Value: the object currently being touched
	CollisionManager* collisionManager;			 // Manages objects that need to check between other collidable objects
	
	CGRect cameraContainRect;	// The rectangle that will contain the "camera" if the map should not scroll
	CGPoint cameraLocation;		// The location of the camera object, which controls scrolling if outside of the containing rectangle
	
	CGRect fullMapBounds;		// Stores the static rectangle of the entire playable space (map)
	CGRect visibleScreenBounds;	// Stores the dynamic bounds of the visible window (viewport)
	
	NSMutableArray* textObjectArray; // Array containing all of the objects that want to render fonts
	NSMutableArray* fontArray;		// Array containing the all the bitmap fonts used
	
	uint state;					// Holds the state of the scene
	GLfloat alpha;				// Alpha value that can be used across the entire scene
	NSString *nextSceneKey;		// The key of the next scene
    float fadeSpeed;			// The speed at which this scene should fade in
	NSString *name;				// The name of the scene i.e. the key
	int frameCounter;			// The counter for frames (use for functions you want to call NOT every frame with "%" operator
	
}

#pragma mark -
#pragma mark Properties

@property (nonatomic, assign) CGRect cameraContainRect;
@property (nonatomic, assign) CGPoint cameraLocation;	
@property (nonatomic, assign) CGRect fullMapBounds;
@property (nonatomic, assign) CGRect visibleScreenBounds;
@property (nonatomic, assign) uint state;
@property (nonatomic, assign) GLfloat alpha;
@property (nonatomic, retain) NSString *name;

#pragma mark -
#pragma mark Selectors

// Set default values, etc.
- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds;

// Handles scrolling all of the objects when the view moves
- (void)scrollScreenWithVector:(Vector2f)scrollVector;

// Returns the vector to scroll the screen with (RELATIVE), while the camera is at its location
- (Vector2f)newScrollVectorFromCamera;

// Returns the current vector that the screen is scrolled (ABSOLUTE)
- (Vector2f)scrollVectorFromScreenBounds;

// Returns the point in the middle of the visible screen
- (CGPoint)middleOfVisibleScreen;

// Returns the point in the middle of the full map
- (CGPoint)middleOfEntireMap;

// Randomly generates small brogguts and adds them to the scene randomly scattered in 
- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds;

// Selector to update the scenes logic using |aDelta| which is passe in from the game loop
- (void)updateSceneWithDelta:(float)aDelta;

// Selector that enables a touchesBegan events location to be passed into a scene.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;

// Selector that transitions from this scene to the scene with the key specified.  This allows the current
// scene to perform a transition action before the current scene within the game controller is changed.
- (void)transitionToSceneWithKey:(NSString*)aKey;

// Selector that sets off a transition into the scene
- (void)transitionIn;

// Selector which renders the scene
- (void)renderScene;
@end
