//
//  TouchableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TouchableObject.h"
#import "Image.h"

@implementation TouchableObject
@synthesize isCheckedForRadialEffect, isTouchable, isCurrentlyTouched, isPartOfASquad, touchableBounds;
@synthesize closestEnemyObject;
@synthesize friendlyAIState;

- (void)dealloc {
	[objectsTargetingSelf release];
	[super dealloc];
}

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		isTouchable = YES;
		isCurrentlyTouched = NO;
		isCurrentlyHoveredOver = NO;
		isCheckedForRadialEffect = NO;
		isPartOfASquad = NO;
		effectRadius = objectImage.imageSize.width / 2;
		closestEnemyObject = nil;
		objectsTargetingSelf = [[NSMutableSet alloc] init];
	}
	return self;
}

- (Circle)touchableBounds { // Could be Bigger than bounding circle, so that it's not hard to tap on it
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = objectImage.imageSize.width / 2; // Same as the bounding circle for now
	return tempBoundingCircle;
}

- (Circle)effectRadiusCircle {
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = effectRadius;
	return tempBoundingCircle;
}

- (void)targetedByEnemy:(TouchableObject*)enemy {
	if (enemy)
		[objectsTargetingSelf addObject:enemy];
}

- (void)untargetedByEnemy:(TouchableObject*)enemy {
	if (enemy)
		[objectsTargetingSelf removeObject:enemy];
}

- (void)targetWasDestroyed:(TouchableObject*)target {
	if (target == closestEnemyObject) { // Just in case, remove it from the objects targeting
		[objectsTargetingSelf removeObject:closestEnemyObject];
	}
	[self setClosestEnemyObject:nil];
}

// MUST USE THIS METHOD TO SET THE CLOSEST TARGET
- (void)setClosestEnemyObject:(TouchableObject*)enemy {
	if (closestEnemyObject) {
		// If a target already exists, remove self from that targets list
		[closestEnemyObject untargetedByEnemy:self];
	}
	[enemy targetedByEnemy:self];
	closestEnemyObject = enemy;
}

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// "other" has entered the effect radius of this structure
	// NSLog(@"Object (%i) entered object (%i) effect radius", other.uniqueObjectID, uniqueObjectID);
	if (friendlyAIState != kFriendlyAIStateAttacking) {
		if (closestEnemyObject && !closestEnemyObject.destroyNow) {
			if (GetDistanceBetweenPoints(objectLocation, other.objectLocation) < 
				GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation)) {
				if (objectAlliance == kAllianceFriendly && other.objectAlliance == kAllianceEnemy) {
					[self setClosestEnemyObject:other];
				}
				if (objectAlliance == kAllianceEnemy && other.objectAlliance == kAllianceFriendly) {
					[self setClosestEnemyObject:other];
				}
			}
		} else {
			if (objectAlliance == kAllianceFriendly && other.objectAlliance == kAllianceEnemy) {
				[self setClosestEnemyObject:other];
			}
			if (objectAlliance == kAllianceEnemy && other.objectAlliance == kAllianceFriendly) {
				[self setClosestEnemyObject:other];
			}
		}
	}
}

- (BOOL)attackedByEnemy:(TouchableObject*)enemy withDamage:(int)damage {
	NSLog(@"Object (%i) attacked by enemy (%i) with damage <%i>", uniqueObjectID, enemy.uniqueObjectID, damage);
	return NO;
}

- (void)objectWasDestroyed {
	NSSet* setCopy = [NSSet setWithSet:objectsTargetingSelf];
	for (TouchableObject* enemy in setCopy) {
		[enemy targetWasDestroyed:self];
	}
	[super objectWasDestroyed];
}

- (void)touchesHoveredOver {
	// OVERRIDE ME, BUT CALL SUPER FIRST
	if (!isCurrentlyHoveredOver) {
		isCurrentlyHoveredOver = YES;
	} else {
		return;
	}
	
	// NSLog(@"Hovered over object (%i)", uniqueObjectID);
}

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
	// OVERRIDE
}

- (void)touchesHoveredLeft {
	// OVERRIDE ME, BUT CALL SUPER FIRST
	if (isCurrentlyHoveredOver) {
		isCurrentlyHoveredOver = NO;
	} else {
		return;
	}
	
	// NSLog(@"Hovered left object (%i)", uniqueObjectID);
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!",uniqueObjectID);
}

@end
