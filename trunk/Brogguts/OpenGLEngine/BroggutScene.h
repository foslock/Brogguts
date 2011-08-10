//
//  BroggutScene.h
//  Brogguts
//
//  Created by Foster Lockwood
//  Copyright 2009 Games in Dorms. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define HELP_MESSAGE_TIME 4.0f
#define SCROLL_BOUNDS_X_INSET 500.0f
#define SCROLL_BOUNDS_Y_INSET 350.0f
#define SCROLL_MAX_SPEED 40.0f
#define CRAFT_ROTATION_TURNING_RANGE 10.0f
#define INITIAL_OBJECT_CAPACITY 100
#define FRAME_COUNTER_MAX 100
#define OVERVIEW_FADE_IN_RATE 0.025f
#define SIDEBAR_WIDTH 192.0f
#define OVERVIEW_MAX_ALPHA 1.0f
#define OVERVIEW_TRANSPARENT_ALPHA_DIVISOR 1.8f
#define OVERVIEW_MIN_FINGER_DISTANCE 10.0f
#define SELECTION_MIN_DISTANCE 20.0f
#define SCENE_NAME_OBJECT_TIME 5.0f
#define SCENE_GRID_RENDER_ALPHA 0.075f
#define END_MISSION_BACKGROUND_ALPHA 0.6f
#define TOTAL_CRAFT_LIMIT 200
#define TOTAL_STRUCTURE_LIMIT 200

#define HELP_MESSAGE_COUNT 8

enum kHelpMessageIDs {
    kHelpMessageNeedBrogguts,
    kHelpMessageNeedMetal,
    kHelpMessageNeedBroggutsAndMetal,
    kHelpMessageNeedStructureBuilding,
    kHelpMessageNeedStructureLimit,
    kHelpMessageNeedUnitLimit,
    kHelpMessageMiningEdges,
    kHelpMessageNeedMoreBlocks,
};

extern NSString* const kHelpMessagesTextArray[HELP_MESSAGE_COUNT];

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
@class EndMissonObject;
@class RefineryStructureObject;
@class BlockStructureObject;
@class NotificationObject;
@class DialogueObject;

// This is an abstract class which contains the basis for any game scene which is going
// to be used.  A game scene is a self contained class which is responsible for updating 
// the logic and rendering the screen for the current scene.  It is simply a way to 
// encapsulate a specific scenes code in a single class.
//
// The Director class controls which scene is the current scene and it is this scene which
// is updated and rendered during the game loop.
//

enum kProcessFrameOffset {
    kFrameOffsetCollisions,
    kFrameOffsetRadialEffect,
};

@interface BroggutScene : NSObject {
	
	// Name of the scene, will be displayed when loaded
	NSString* sceneName;
    NSString* sceneFileName;
    
    // Timer, counting seconds this scene has lasted
    float sceneTimer;
    
    // Type of the scene (enum defined in GameController)
    int sceneType;
    
    // Booleans regarding the scene's status and what to display
    BOOL isAllowingSidebar;
    BOOL isShowingBroggutCount;
    BOOL isShowingMetalCount;
    BOOL isShowingSupplyCount;
    BOOL isAllowingOverview;
    BOOL isMultiplayerMatch;
    BOOL isMissionOver;
    BOOL isAllowingCraft;
    BOOL isAllowingStructures;
    BOOL isLoadedScene;
    
    // No losses achievement
    BOOL didLoseAnyCraftOrStructure;
    
    // Used in campaign scenes, this array stores the raw spawners (not infos)
    NSMutableArray* sceneSpawners;
    
    // This array stores the raw dialogue objects (not infos)
    NSMutableArray* sceneDialogues;
    
    // The final box that pops up when the scene is done
    EndMissonObject* endMissionObject;
    float fadeBackgroundAlpha;
    BOOL didAddBrogguts;
	
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
    BOOL isFriendlyBaseStationAlive;
    BOOL isEnemyBaseStationAlive;
    int numberOfRefineries;
    NSMutableArray* currentRefineries;
    
    // Counter and array for all the blocks that the player currently owns
    int numberOfBlocks;
    NSMutableArray* currentBlocks;
    
    // Counters for enemy craft and structures
    int numberOfEnemyShips;
    int numberOfEnemyStructures;
	
	// Location of the home base
	CGPoint homeBaseLocation;
	CGPoint enemyBaseLocation;
    
    // Notification object
    BOOL isShowingNotification;
    NotificationObject* notification;
	
	// Display of brogguts
    Image* broggutIconImage;
    Image* metalIconImage;
    Image* supplyIconImage;
	TextObject* broggutCounter;
	TextObject* metalCounter;
    TextObject* supplyCounter;
    
    TextObject* valueTextObject;		// Text object that shows the medium broggut value
	BOOL isShowingValueText;			// Boolean about if the text is showing
    
    // Displayed when the player doesn't have the required resources
    TextObject* helpMessageObject;
    float messageTimer;
    BOOL isShowingMessageTimer;
    
    // Timer counter
    TextObject* countdownTimer;
    
    // Only allow one structure to be built at once.
    BOOL isBuildingStructure;
    
    // Explosion's shaking the screen
    BOOL isScreenShaking;
    float screenShakingAmount;
    
    // These are shown when about to build a new structure or craft
    TextObject* buildBroggutValue;
    TextObject* buildMetalValue;
    int currentBuildBroggutCost;
    int currentBuildMetalCost;
    CGPoint currentBuildDragLocation;
    BOOL isShowingBuildingValues;
	
	// The current location at which the screen is being touched
	CGPoint currentTouchLocation;
	int movingTouchHash;		// Holds the unique hash value given to a touch on the screen.  
								// This allows us to track the same touch during touchesMoved events (-1 is none)
	BOOL isTouchScrolling;		// YES if a touch is being tracked for scrolling the screen/controlling the current ship
    BOOL isTouchMovingOverview; // YES is a touch is moving the overview around
    int movingOverviewTouchHash;// Hash for the touch moving the overview around
    CGPoint currentOverViewPoint;// Location of the center of the overview view box
	
	// Object management
	NSMutableArray* renderableObjects;			 // The array of objects that need to be updated and rendered
	NSMutableArray* renderableDestroyed;		 // The array of objects that need to be destroyed through the next frame pass
	NSMutableArray* touchableObjects;			 // The array of objects that need to be checked for touches in ADDITION to rendered/updated
	NSMutableDictionary* currentObjectsTouching; // Key: numerical hash value of the touch. Value: the object currently being touched
	NSMutableDictionary* currentObjectsHovering; // Key: numerical hash value of the touch. Value: the object currently being hovered
	NSMutableDictionary* currentTouchesInSideBar;// Array of NSValues of touch hashes for touches active in the sidebar
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
	int frameCounter;			// The counter for frames (use for functions you want to call NOT every frame with "%" operator)
	
	// Overview map control
	BOOL isShowingOverview;
	BOOL isFadingOverviewIn;
	BOOL isFadingOverviewOut;
	float overviewAlpha;
    
    // Dialogue pop-up control
    BOOL isShowingDialogue;
    BOOL isFadingDialogueIn;
    BOOL isFadingDialogueOut;
    float dialogueFadeAlpha;
    DialogueObject* currentShowingDialogue;
    BOOL isTouchSkippingDialogue;
    float skipDialogueTimer;
    CGPoint skipDialogueTouchPoint;
	
	// Map vars
	int widthCells;
	int heightCells;
}

#pragma mark -
#pragma mark Properties

@property (readonly) float sceneTimer;
@property (readonly) NSMutableArray* fontArray;
@property (retain) NSString* sceneName;
@property (retain) NSString* sceneFileName;
@property (assign) int sceneType;
@property (retain) CraftObject* commandingShip;
@property (readonly) CollisionManager* collisionManager;
@property (nonatomic, assign) CGPoint homeBaseLocation;
@property (nonatomic, assign) CGPoint enemyBaseLocation;
@property (nonatomic, assign) CGRect cameraContainRect;
@property (nonatomic, assign) CGPoint cameraLocation;	
@property (nonatomic, assign) CGRect fullMapBounds;
@property (nonatomic, assign) CGRect visibleScreenBounds;
@property (nonatomic, assign) BOOL isShowingOverview;
@property (nonatomic, assign) BOOL isMultiplayerMatch;
@property (nonatomic, assign) BOOL isMissionOver;
@property (nonatomic, assign) BOOL isLoadedScene;
@property (nonatomic, assign) BOOL isFriendlyBaseStationAlive;
@property (nonatomic, assign) BOOL isEnemyBaseStationAlive;
@property (nonatomic, assign) SideBarController* sideBar;
@property (readonly) TextObject* broggutCounter;
@property (readonly) TextObject* metalCounter;
@property (readonly) TextObject* supplyCounter;
@property (readonly) NSMutableArray* touchableObjects;
@property (readonly) int widthCells;
@property (readonly) int heightCells;
@property (readonly) int numberOfSmallBrogguts;
@property (readonly) int numberOfRefineries;
@property (readonly) int numberOfBlocks;
@property (nonatomic, assign) BOOL isShowingBuildingValues;
@property (nonatomic, assign) int currentBuildBroggutCost;
@property (nonatomic, assign) int currentBuildMetalCost;
@property (nonatomic, assign) CGPoint currentBuildDragLocation;
@property (nonatomic, assign) BOOL isBuildingStructure;
@property (nonatomic, assign) BOOL isShowingNotification;
@property (nonatomic, readonly) NotificationObject* notification;
@property (readonly) BOOL isAllowingCraft;
@property (readonly) BOOL isAllowingStructures;
@property (nonatomic, assign) int numberOfEnemyShips;
@property (nonatomic, assign) int numberOfEnemyStructures;
@property (readonly) NSMutableArray* sceneSpawners;
@property (readonly) NSMutableArray* sceneDialogues;

#pragma mark -
#pragma mark Selectors

// Get a scene from a file
- (id)initWithFileName:(NSString*)filename wasLoaded:(BOOL)loaded;

// Get a file from scene
- (NSArray*)arrayFromScene;

// Set default values, etc.
- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString*)sName;

// Called when the scene was just revealed, not necessarily right after loaded
- (void)sceneDidAppear;
- (void)sceneDidDisappear;

// Creates a broggut value text object showing where brogguts were gathered (and adds value to total brogguts)
- (void)addBroggutTextValue:(int)value atLocation:(CGPoint)location withAlliance:(int)alliance;

// Randomly generates small brogguts and adds them to the scene randomly scattered in 
- (void)addSmallBrogguts:(int)number inBounds:(CGRect)bounds withLocationArray:(NSArray*)locationArray;

// Will divide the metal needed among the current refineries
- (void)refineMetalOutOfBrogguts:(int)metal;

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

// Makes sure to send a message to the remote opponent about the object
- (void)createLocalTouchableObject:(TouchableObject*)obj withColliding:(BOOL)collides;

// Adds an collidable object to the scene
- (void)addCollidableObject:(CollidableObject*)obj;

// Adds a text object to the scene
- (void)addTextObject:(TextObject*)obj;

// Sets the scene specific notification object
- (void)setSceneNotification:(NotificationObject*)noti;

// Increments the refinery count
- (void)addRefinery:(RefineryStructureObject*)refinery;

// Increments the block count
- (void)addBlock:(BlockStructureObject*)block;

// Returns the current max number of ships the player can own
- (int)currentMaxShipSupply;

// Show medium broggut value
- (void)showBroggutValueAtLocation:(CGPoint)location;

// Shows the message with the appropriate ID
- (void)showHelpMessageWithMessageID:(int)helpID;

// Shakes the screen
- (void)startShakingScreenWithMagnitude:(float)magnitude;

// Selector to update the scenes logic using |aDelta| which is passe in from the game loop
- (void)updateSceneWithDelta:(float)aDelta;

// Called to send packets about all the objects that need to be updated remotely
- (void)updateRemoteObjectsWithDelta:(float)aDelta;

// Render the selection area
- (void)renderSelectionAreaWithPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo;

// Attempt to select craft inside of the given rect
- (BOOL)attemptToSelectCraftWithinRect:(CGRect)selectionRect;

// Attempt to select craft with given ID inside of the visible rect
- (void)attemptToSelectCraftInVisibleRectWithID:(int)objectID;

// Try to select the ships between the two arrays of points
- (void)attemptToSelectCraftWithinPoints:(NSArray*)pointsOne andPoints:(NSArray*)pointsTwo;

// Spreads out the ships that are currently selected so that they aren't all in a clump
- (void)spreadOutCurrentlySelectedShips;

// Add a craft the the current controlled craft
- (void)addControlledCraft:(CraftObject*)craft;

// Removes a craft the the current controlled craft
- (void)removeControlledCraft:(CraftObject*)craft;

// Returns an enemy ship at the location
- (TouchableObject*)attemptToGetEnemyAtLocation:(CGPoint)location;

// Called when the player is trying to switch controlling ships
- (BOOL)attemptToControlCraftAtLocation:(CGPoint)location;

// Called when a ship wants to join a squad
// - (BOOL)attemptToPutCraft:(CraftObject*)craft inSquadAtLocation:(CGPoint)location;

// Controls the nearest ship to a given location, if there are any ships left
- (void)controlNearestShipToLocation:(CGPoint)location;

// Called when the player is trying to create/purchase a craft at the location
- (void)attemptToCreateCraftWithID:(int)craftID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance;

// Called when the player is trying to create/purchase a structure at the location
- (void)attemptToCreateStructureWithID:(int)structureID atLocation:(CGPoint)location isTraveling:(BOOL)traveling withAlliance:(int)alliance;

// Shows the broggut and metal cost for the object being built
- (void)showBuildingValuesWithBrogguts:(int)brogguts withMetal:(int)metal atLocation:(CGPoint)location;

// Called when the other player disconnects (only in multiplayer)
- (void)otherPlayerDisconnected;

// Check if the Base Camp fail conditions are valid
- (BOOL)baseCampCheckFailCondition;

// Selector that enables a touchesBegan events location to be passed into a scene.
- (void)disregardAllCurrentTouches;
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
