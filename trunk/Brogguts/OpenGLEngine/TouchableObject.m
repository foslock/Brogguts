//
//  TouchableObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TouchableObject.h"
#import "BroggutScene.h"
#import "Image.h"
#import "Global.h"
#import "Primitives.h"
#import "CraftAndStructures.h"
#import "PlayerProfile.h"
#import "GameController.h"
#import "HealthDropObject.h"
#import "ImageRenderSingleton.h"

@implementation TouchableObject
@synthesize isCheckedForRadialEffect, isTouchable, isTraveling, isCurrentlyTouched, isPartOfASquad, touchableBounds;
@synthesize closestEnemyObject;
@synthesize movingAIState, attackingAIState;
@synthesize creationEndLocation;
@synthesize isDrawingEffectRadius;

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
        isDrawingEffectRadius = NO;
		isPartOfASquad = NO;
		effectRadius = (objectImage.imageSize.width * objectImage.scale.x) / 2;
		closestEnemyObject = nil;
		objectsTargetingSelf = [[NSMutableSet alloc] init];
		isBlinkingSelectionCircle = NO;
		blinkingSelectionCircleTimer = 0;
        isBlinkingCircleFadingIn = NO;
        blinkingCircleAlpha = 0;
        isShowingSelectionCircle = NO;
        showingSelectionCircleTimer = 0;
		[self setMovingAIState:kMovingAIStateStill];
	}
	return self;
}

- (Circle)touchableBounds { // Could be Bigger than bounding circle, so that it's not hard to tap on it
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = (objectImage.imageSize.width * objectImage.scale.x) / 2; // Same as the bounding circle for now
	return tempBoundingCircle;
}

- (Circle)effectRadiusCircle {
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	tempBoundingCircle.radius = effectRadius;
	return tempBoundingCircle;
}

// Called every step if the upgrade is unlocked and PURCHASED
- (void)performPassiveAbility:(float)aDelta {
    
}

- (void)setIsTraveling:(BOOL)traveling {
	isTouchable = !traveling;
	isTraveling = traveling;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	[super updateObjectLogicWithDelta:aDelta];
    if (isShowingSelectionCircle) {
		if (showingSelectionCircleTimer > 0) {
			showingSelectionCircleTimer--;
			if (showingSelectionCircleTimer <= 0) {
				isShowingSelectionCircle = NO;
				showingSelectionCircleTimer = 0;
			}
		}
	}
    
	if (isBlinkingSelectionCircle) {
		if (blinkingSelectionCircleTimer > 0) {
			blinkingSelectionCircleTimer--;
            if (isBlinkingCircleFadingIn) {
                blinkingCircleAlpha += CIRCLE_BLINK_FADE_SPEED;
            } else {
                blinkingCircleAlpha -= CIRCLE_BLINK_FADE_SPEED;
            }
            if (isBlinkingCircleFadingIn && blinkingCircleAlpha > 1.0f) {
                isBlinkingCircleFadingIn = NO;
                blinkingCircleAlpha = 1.0f;
            }
            if (!isBlinkingCircleFadingIn && blinkingCircleAlpha < 0.0f) {
                isBlinkingCircleFadingIn = YES;
                blinkingCircleAlpha = 0.0f;
            }
			if (blinkingSelectionCircleTimer <= 0) {
				isBlinkingSelectionCircle = NO;
				blinkingSelectionCircleTimer = 0;
			}
		}
	}
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    if (isShowingSelectionCircle) {
        enablePrimitiveDraw();
        [self drawHoverSelectionWithScroll:scroll withAlpha:1.0f];
        disablePrimitiveDraw();
	} else if (isBlinkingSelectionCircle) {
        enablePrimitiveDraw();
        [self drawHoverSelectionWithScroll:scroll withAlpha:blinkingCircleAlpha];
        disablePrimitiveDraw();
	}
    
    if (!isTraveling && isDrawingEffectRadius) {
        enablePrimitiveDraw();
        if (objectAlliance == kAllianceFriendly) {
            if (!isCurrentlyHoveredOver) {
                glColor4f(0.5f, 1.0f, 0.5f, 0.25f);
            } else {
                glColor4f(0.5f, 1.0f, 0.5f, 0.6f);
            }
        } else if (objectAlliance == kAllianceEnemy) {
            if (!isCurrentlyHoveredOver) {
                glColor4f(1.0f, 0.5f, 0.5f, 0.25f);
            } else {
                glColor4f(1.0f, 0.5f, 0.5f, 0.6f);
            }
        }
        glLineWidth(2.0f);
        drawDashedCircle([self effectRadiusCircle], CIRCLE_SEGMENTS_COUNT * 2, scroll);
        disablePrimitiveDraw();
    }
}

- (void)setMovingAIState:(int)state {
	if (movingAIState != state)
		// NSLog(@"Object (%i) changed moving from state (%i) to (%i)", uniqueObjectID, movingAIState, state);
        movingAIState = state;
}

- (void)setAttackingAIState:(int)state {
	if (attackingAIState != state)
		// NSLog(@"Object (%i) changed attacking from state (%i) to (%i)", uniqueObjectID, attackingAIState, state);
        attackingAIState = state;
}

- (void)blinkSelectionCircle {
	if (!isShowingSelectionCircle) {
        isBlinkingCircleFadingIn = YES;
        blinkingCircleAlpha = 0.0f;
		isBlinkingSelectionCircle = YES;
		blinkingSelectionCircleTimer = CIRCLE_BLINK_FRAMES;		
	}
}

- (void)showSelectionCircle {
    isShowingSelectionCircle = YES;
    showingSelectionCircleTimer = CIRCLE_SHOW_FRAMES;		
    isBlinkingSelectionCircle = NO;
    blinkingSelectionCircleTimer = 0;
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
		[self setClosestEnemyObject:nil];
	}
}

// MUST USE THIS METHOD TO SET THE CLOSEST TARGET
- (void)setClosestEnemyObject:(TouchableObject*)enemy {
	if (closestEnemyObject) {
		// If a target already exists, remove self from that targets list
		[closestEnemyObject untargetedByEnemy:self];
	}
	[enemy targetedByEnemy:self];
	closestEnemyObject = enemy;
	if (!closestEnemyObject) {
		attackingAIState = kAttackingAIStateNeutral;
	}
}

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// "other" has entered the effect radius of this structure
	// NSLog(@"Object (%i) entered object (%i) effect radius", other.uniqueObjectID, uniqueObjectID);
	if (!other.isHidden && !isTraveling) {
		if (attackingAIState != kAttackingAIStateAttacking) {
			if (closestEnemyObject && !closestEnemyObject.destroyNow) {
				if (GetDistanceBetweenPointsSquared(objectLocation, other.objectLocation) < 
					GetDistanceBetweenPointsSquared(objectLocation, closestEnemyObject.objectLocation)) {
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
}

- (BOOL)attackedByEnemy:(TouchableObject*)enemy withDamage:(int)damage {
	// NSLog(@"Object (%i) attacked by enemy (%i) with damage <%i>", uniqueObjectID, enemy.uniqueObjectID, damage);
    HealthDropObject* healthDrop = [[HealthDropObject alloc] initWithTouchableObject:self];
    [[self currentScene] addCollidableObject:healthDrop];
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

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll withAlpha:(float)alpha {
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
