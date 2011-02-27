//
//  TouchableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"

@interface TouchableObject : CollidableObject {
	BOOL isTouchable;
	BOOL isCurrentlyTouched;
	BOOL isCurrentlyHoveredOver; // Private, true if a touch has entered and NOT left its bounding circle yet
	Circle touchableBounds;
	
	// True if the structure should be checked for ships/structures in it's area
	BOOL isCheckedForRadialEffect;
	float effectRadius;
	
	// Closest enemy object, within range
	TouchableObject* closestEnemyObject;
	NSMutableSet* objectsTargetingSelf;
	
	// For craft ONLY
	BOOL isPartOfASquad;
	
	// Used so things are disabled when traveling
	BOOL isTraveling;
}

@property (nonatomic, assign) TouchableObject* closestEnemyObject;
@property (nonatomic, assign) BOOL isPartOfASquad;
@property (nonatomic, assign) BOOL isTouchable;
@property (nonatomic, assign) BOOL isCurrentlyTouched;
@property (nonatomic, assign) Circle touchableBounds;
@property (nonatomic, assign) BOOL isCheckedForRadialEffect;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;

- (Circle)effectRadiusCircle;
- (void)objectEnteredEffectRadius:(TouchableObject*)other;

// Returns YES if the object is destroyed because of the attack
- (BOOL)attackedByEnemy:(TouchableObject*)enemy withDamage:(int)damage;

// Called on an object when it has been targeted by "enemy"
- (void)targetedByEnemy:(TouchableObject*)enemy;
- (void)untargetedByEnemy:(TouchableObject*)enemy;

// Called on an object (enemy targeting the object) when destroyed, passes itself
- (void)targetWasDestroyed:(TouchableObject*)target;

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll;
- (void)touchesHoveredOver;
- (void)touchesHoveredLeft;
- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;
- (void)touchesDoubleTappedAtLocation:(CGPoint)location;

@end
