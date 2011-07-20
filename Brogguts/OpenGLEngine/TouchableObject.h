//
//  TouchableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"

#define CIRCLE_BLINK_FADE_SPEED 0.05f // The speed at which the circle fades in and out
#define CIRCLE_BLINK_FRAMES 100	// The total frames the circle blinks
#define CIRCLE_SHOW_FRAMES 100	// The total frames the circle is shown

#define LIGHT_BLINK_FREQUENCY 200	 // Number of steps between the light's flashes
#define LIGHT_BLINK_BRIGHTNESS 0.8f	 // Brightness that the lights blink at
#define LIGHT_BLINK_FADE_SPEED 0.05f // Rate at which the blinking light fades out

#define SHADOW_OFFSET_HORIZONTAL 3.0f
#define SHADOW_OFFSET_VERTICAL -3.0f
#define SHADOW_ALPHA 0.3f

@interface TouchableObject : CollidableObject {
	BOOL isTouchable;
	BOOL isCurrentlyTouched;
	BOOL isCurrentlyHoveredOver; // Private, true if a touch has entered and NOT left its bounding circle yet
	Circle touchableBounds;
	
	// Selection circle blinking vars
	BOOL isBlinkingSelectionCircle;
	int blinkingSelectionCircleTimer;
    BOOL isBlinkingCircleFadingIn;
    float blinkingCircleAlpha;
    BOOL isShowingSelectionCircle;
	int showingSelectionCircleTimer;
    
	// True if the structure should be checked for ships/structures in it's area
	BOOL isCheckedForRadialEffect;
    BOOL isDrawingEffectRadius;
	float effectRadius;
	
	// AI states
	int movingAIState;
	int attackingAIState;
	
	// Closest enemy object, within range
	TouchableObject* closestEnemyObject;
	NSMutableSet* objectsTargetingSelf;
	
	// For craft ONLY
	BOOL isPartOfASquad;
	
	// Used so things are disabled when traveling
	BOOL isTraveling;
	CGPoint creationEndLocation;
}

@property (readonly) int movingAIState;
@property (readonly) int attackingAIState;
@property (nonatomic, assign) TouchableObject* closestEnemyObject;
@property (nonatomic, assign) BOOL isPartOfASquad;
@property (nonatomic, assign) BOOL isTouchable;
@property (nonatomic, assign) BOOL isTraveling;
@property (nonatomic, assign) BOOL isCurrentlyTouched;
@property (nonatomic, assign) Circle touchableBounds;
@property (nonatomic, assign) BOOL isCheckedForRadialEffect;
@property (nonatomic, assign) BOOL isDrawingEffectRadius;
@property (nonatomic, assign) CGPoint creationEndLocation;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;

- (Circle)effectRadiusCircle;
- (void)objectEnteredEffectRadius:(TouchableObject*)other;

// Use these functions to set the AI states
- (void)setMovingAIState:(int)state;
- (void)setAttackingAIState:(int)state;

// Blinks the selection circle around the object
- (void)blinkSelectionCircle;

// Shows the circle, this takes precedence over blinking
- (void)showSelectionCircle;

// Called every step if the upgrade is unlocked and PURCHASED
- (void)performPassiveAbility:(float)aDelta;

// Returns YES if the object is destroyed because of the attack
- (BOOL)attackedByEnemy:(TouchableObject*)enemy withDamage:(int)damage;

// Called on an object when it has been targeted by "enemy"
- (void)targetedByEnemy:(TouchableObject*)enemy;
- (void)untargetedByEnemy:(TouchableObject*)enemy;

// Called on an object (enemy targeting the object) when destroyed, passes itself
- (void)targetWasDestroyed:(TouchableObject*)target;

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll withAlpha:(float)alpha;
- (void)touchesHoveredOver;
- (void)touchesHoveredLeft;
- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
