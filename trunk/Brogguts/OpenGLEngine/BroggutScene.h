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

#define SCROLL_BOUNDS_X_INSET 500.0f
#define SCROLL_BOUNDS_Y_INSET 350.0f
#define SCROLL_MAX_SPEED 20.0f
#define INITIAL_OBJECT_CAPACITY 100
#define FRAME_COUNTER_MAX 100
#define OVERVIEW_FADE_IN_RATE 0.025f
#define SIDEBAR_WIDTH 192.0f
#define OVERVIEW_MAX_ALPHA 1.0f
#define OVERVIEW_MIN_FINGER_DISTANCE 10.0f
#define SELECTION_MIN_DISTANCE 20.0f
#define SCENE_NAME_OBJECT_TIME 5.0f

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
@class CollidableObject;
@class ControllableObject;
@class SideBarController;
@class CollisionManager;
@class TouchableObject;
@class CraftObject;
@class ParticleSingleton;
@class AIController;

// This is an abstract class which contains the basis for any game scene which is going
// to be used.  A game scene is a self contained class which is responsible for updating 
// the logic and rendering the screen for the current scene.  It is simply a way to 
// encapsulate a specific scenes code in a single class.
//
// The Director class controls which scene is the current scene and it is this scene which
// is updated and rendered during the game loop.
//
@interface BroggutScene : NSObject {
	
	// Name of the scene, will be displayed when loaded
	NSString* sceneName;
    
    // Booleans regarding the scene's status and what to display
    BOOL isBaseCamp;
    BOOL isTutorial;
    BOOL isAllowingSidebar;
    BOOL isShowingBroggutCount;
    BOOL isShowingMetalCount;
    BOOL isAllowingOverview;
	
	////////////////////// Singleton references
	GameController *sharedGameController;				// Reference to the game controller
	ImageRenderSingleton *sharedImageRenderSingleton;	// Reference to the image render manager
	SoundSingleton *sharedSoundSingleton;				// Reference to the sound manager
	GameCenterSingleton* sharedGameCenterSingleton;		// Reference to the game center controller
	StarSingleton* sharedStarSingleton;					// Reference to the star controller
	ParticleSingleton* sharedParticleSingleton;			// Reference to the particle manager
	
	// Player's currently controlled ships
	NSMutableArray* controlledShips;
	NSMutableArray* selectionPointsOne;
	NSMutableArray* selectionPointsTwo; // Stored in reverse order
	int selectionTouchHashOne;
	int selectionTouchHashTwo;
	BOOL isSelectingShips;
    
    // AI Controller for this scene (controlling enemy)
	AIController* enemyAIController;
    
	// The ship (if any) that is currently being commanded
	CraftObject* commandingShip;
	
	// Counters for craft and structures (friendly only)
	int numberOfCurrentShips;
	int numberOfCurrentStructures;
	int numberOfSmallBrogguts;
	
	// Location of the home base
	CGPoint homeBaseLocation;
	CGPoint enemyBaseLocation;
	
	// Display of brogguts
	TextObject* broggutCounter;
	TextObject* metalCounter;
	
	// The current location at which the screen is being touched
	CGPoint currentTouchLocation;
	int movingTouchHash;		// Holds the unique hash value given to a touch on the screen.  
								// This allows us to track the same touch during touchesMoved events
	BOOL isTouchScrolling;		// YES if a touch is being tracked for scrolling the screen/controlling the current ship
    BOOL isTouchMovingOverview; // YES is a touch is moving the overview around
    int movingOverviewTouchHash;// Hash for the touch moving the overview around
    CGPoint currentOverViewPoint;// Location of the center of the overview view box
	
	// Object management
	NSMutableArray* renderableObjects;			 // The array of objects that need to be updated and rendered
	NSMutableArray* renderableDestroyed;		 // The array of objects that need to be destroyed through the next frame pass
	NSMutableArray* touchableObjects;			 // The array of objects that need to be checked for touches in ADDITION to rendered/updated
	NSMutableDictionary* currentObjectsTouching; // Key: numerical hash value of the touch. Value: the object currently being touched
	NSMutableDictionary* currentObjectsHovering; // Key: numerical hash value of the touch. Value: the object currently being touched
	NSMutableDictionary* currentTouchesInSideBar;	 // Array of NSValues of touch hashes for touches active in the sidebar
	CollisionManager* collisionManager;			 // Manages objects that need to check between other collidable objects
	
	// Camera Control
	CGRect cameraContainRect;	// The rectangle that will contain the "camera" if the map should not scroll
	CGPoint cameraLocation;		// The location of the camera object, which controls scrolling if outside of the containing rectangle
	Image *cameraImage;
	
	// Side bar object
	SideBarController* sideBar;		// Side bar that controls other things
	
	// Full Map and screen bounds
	CGRect fullMapBounds;		// Stores the static rectangle of the entire playable space (map)
	CGRect visibleScreenBounds;	// Stores the dynamic bounds of the visible window (viewport)
	
	// Dealing with text objects
	NSMutableArray* textObjectArray;    // Array containing all of the objects that want to render fonts
	NSMutableArray* fontArray;          // Array containing the all the bitmap fonts used
	
	// Frame counter
	int frameCounter;			// The counter for frames (use for functions you want to call NOT every frame with "%" operator
	
	// Overview map control
	BOOL isShowingOverview;
	BOOL isFadingOverviewIn;
	BOOL isFadingOverviewOut;
	float overviewAlpha;
	
	// Map vars
	int widthCells;
	int heightCells;
	
}

#pragma mark -
#pragma mark Properties

@property (readonly) NSMutableArray* fontArray;
@property (retain) NSString* sceneName;
@property (retain) CraftObject* commandingShip;
@property (readonly) CollisionManager* collisionManager;
@property (nonatomic, assign) CGPoint homeBaseLocation;
@property (nonatomic, assign) CGPoint enemyBaseLocation;
@property (nonatomic, assign) CGRect cameraContainRect;
@property (nonatomic, assign) CGPoint cameraLocation;	
@property (nonatomic, assign) CGRect fullMapBounds;
@property (nonatomic, assign) CGRect visibleScreenBounds;
@property (nonatomic, assign) BOOL isShowingOverview;
@property (nonatomic, assign) BOOL isBaseCamp;
@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) SideBarController* sideBar;
@property (readonly) TextObject* broggutCounter;
@property (readonly) TextObject* metalCounter;
@property (readonly) NSMutableArray* touchableObjects;
@property (readonly) int widthCells;
@property (readonly) int heightCells;
@property (readonly) int numberOfSmallBrogguts;

#pragma mark -
#pragma mark Selectors

// Get a scene from a file
- (id)initWithFileName:(NSString*)filename;

// Set default values, etc.
- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName;

// Called when the scene was just revealed, not necessarily right after loaded
- (void)sceneDidAppear;

// Creates a broggut value text object showing where brogguts were gathered (and adds value to total brogguts)
- (void)addBroggutValue:(int)value atLocation:(CGPoint)location withAlliance:(int)alliance;

// Randomly generates small brogguts and adds them to the scene randomly scattered in 
- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds withLocationArray:(NSArray*)locationArray;

// Font widths and heights
- (float)getWidthForFontID:(int)fontID withString:(NSString*)string;
- (float)getHeightForFontID:(int)fontID withString:(NSString*)string;

// Handles scrolling all of the objects when the view moves
- (void)scrollScreenWithVector:(Vector2f)scrollVector;

// Returns the vector to scroll the screen with (RELATIVE), while the camera is at its location
- (Vector2f)newScrollVectorFromCamera;

// Returns the current vector that the screen is scrolled (ABSOLUTE)
- (Vector2f)scrollVectorFromScreenBounds;

// Returns the point in the middle of the visible screen
- (CGPoint)middleOfVisibleScreen;

// Sets the middle of the screen to the camera location
- (void)setMiddleOfVisibleScreenToCamera;

// Returns the point in the middle of the full map
- (CGPoint)middleOfEntireMap;

// Adds an touchable object to the scene
- (void)addTouchableObject:(TouchableObject*)obj withColliding:(BOOL)collides;

// Adds an collidable object to the scene
- (void)addCollidableObject:(CollidableObject*)obj;

// Adds a text object to the scene
- (void)addTextObject:(TextObject*)obj;

// Selector to update the scenes logic using |aDelta| which is passe in from the game loop
- (void)updateSceneWithDelta:(float)aDelta;

// Render the selection area
- (void)renderSelectionAreaWithPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo;

// Attempt to select craft inside of the given rect
- (BOOL)attemptToSelectCraftWithinRect:(CGRect)selectionRect;

// Try to select the ships between the two arrays of points
- (void)attemptToSelectCraftWithinPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo;

// Add a craft the the current controlled craft
- (void)addControlledCraft:(CraftObject*)craft;

// Removes a craft the the current controlled craft
- (void)removeControlledCraft:(CraftObject*)craft;

// Returns an enemy ship at the location
- (TouchableObject*)attemptToGetEnemyAtLocation:(CGPoint)location;

// Called when the player is trying to switch controlling ships
- (BOOL)attemptToControlCraftAtLocation:(CGPoint)location;

// Called when a ship wants to join a squad
- (BOOL)attemptToPutCraft:(CraftObject*)craft inSquadAtLocation:(CGPoint)location;

// Controls the nearest ship to a given location, if there are any ships left
- (void)controlNearestShipToLocation:(CGPoint)location;

// Called when the player is trying to create/purchase a craft at the location
- (void)attemptToCreateCraftWithID:(int)craftID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance;

// Called when the player is trying to create/purchase a structure at the location
- (void)attemptToCreateStructureWithID:(int)structureID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance;

// Selector that enables a touchesBegan events location to be passed into a scene.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;

// Selector which renders the scene
- (void)renderScene;

// Start fading in/out the overview map
- (void)fadeOverviewMapIn;
- (void)fadeOverviewMapOut;

// Renders the overview map 
- (void)renderOverviewMapWithAlpha:(float)alpha;

@end
