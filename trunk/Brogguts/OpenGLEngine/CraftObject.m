//
//  CraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftObject.h"
#import "Image.h"
#import "GameController.h"
#import "BroggutScene.h"
#import "StructureObject.h"
#import "CollisionManager.h"

@implementation CraftObject

- (void)dealloc {
	[pathPointArray release];
	[super dealloc];
}

- (void)initCraftWithID:(int)typeID {
	switch (typeID) {
		case kObjectCraftAntID:
			attributeBroggutCost = kCraftAntCostBrogguts;
			attributeMetalCost = kCraftAntCostMetal;
			attributeEngines = kCraftAntEngines;
			attributeWeapons = kCraftAntWeapons;
			attributeAttackRange = kCraftAntAttackRange;
			attributeAttackRate = kCraftAntAttackRate;
			attributeHullCapacity = kCraftAntHull;
			attributeHullCurrent = kCraftAntHull;
			break;
		case kObjectCraftMothID:
			attributeBroggutCost = kCraftMothCostBrogguts;
			attributeMetalCost = kCraftMothCostMetal;
			attributeEngines = kCraftMothEngines;
			attributeWeapons = kCraftMothWeapons;
			attributeAttackRange = kCraftMothAttackRange;
			attributeAttackRate = kCraftMothAttackRate;
			attributeHullCapacity = kCraftMothHull;
			attributeHullCurrent = kCraftMothHull;
			break;
		case kObjectCraftBeetleID:
			attributeBroggutCost = kCraftBeetleCostBrogguts;
			attributeMetalCost = kCraftBeetleCostMetal;
			attributeEngines = kCraftBeetleEngines;
			attributeWeapons = kCraftBeetleWeapons;
			attributeAttackRange = kCraftBeetleAttackRange;
			attributeAttackRate = kCraftBeetleAttackRate;
			attributeHullCapacity = kCraftBeetleHull;
			attributeHullCurrent = kCraftBeetleHull;
			break;
		case kObjectCraftMonarchID:
			attributeBroggutCost = kCraftMonarchCostBrogguts;
			attributeMetalCost = kCraftMonarchCostMetal;
			attributeEngines = kCraftMonarchEngines;
			attributeWeapons = kCraftMonarchWeapons;
			attributeAttackRange = kCraftMonarchAttackRange;
			attributeAttackRate = kCraftMonarchAttackRate;
			attributeHullCapacity = kCraftMonarchHull;
			attributeHullCurrent = kCraftMonarchHull;
			break;
		case kObjectCraftCamelID:
			attributeBroggutCost = kCraftCamelCostBrogguts;
			attributeMetalCost = kCraftCamelCostMetal;
			attributeEngines = kCraftCamelEngines;
			attributeWeapons = kCraftCamelWeapons;
			attributeAttackRange = kCraftCamelAttackRange;
			attributeAttackRate = kCraftCamelAttackRate;
			attributeHullCapacity = kCraftCamelHull;
			attributeHullCurrent = kCraftCamelHull;
			break;
		case kObjectCraftRatID:
			attributeBroggutCost = kCraftRatCostBrogguts;
			attributeMetalCost = kCraftRatCostMetal;
			attributeEngines = kCraftRatEngines;
			attributeWeapons = kCraftRatWeapons;
			attributeAttackRange = kCraftRatAttackRange;
			attributeAttackRate = kCraftRatAttackRate;
			attributeHullCapacity = kCraftRatHull;
			attributeHullCurrent = kCraftRatHull;
			break;
		case kObjectCraftSpiderID:
			attributeBroggutCost = kCraftSpiderCostBrogguts;
			attributeMetalCost = kCraftSpiderCostMetal;
			attributeEngines = kCraftSpiderEngines;
			attributeWeapons = kCraftSpiderWeapons;
			attributeAttackRange = kCraftSpiderAttackRange;
			attributeAttackRate = kCraftSpiderAttackRate;
			attributeHullCapacity = kCraftSpiderHull;
			attributeHullCurrent = kCraftSpiderHull;
			break;
		case kObjectCraftEagleID:
			attributeBroggutCost = kCraftEagleCostBrogguts;
			attributeMetalCost = kCraftEagleCostMetal;
			attributeEngines = kCraftEagleEngines;
			attributeWeapons = kCraftEagleWeapons;
			attributeAttackRange = kCraftEagleAttackRange;
			attributeAttackRate = kCraftEagleAttackRate;
			attributeHullCapacity = kCraftEagleHull;
			attributeHullCurrent = kCraftEagleHull;
			break;
		default:
			break;
	}
}

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	Image* image;
	switch (typeID) {
		case kObjectCraftAntID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftAntSprite filter:GL_LINEAR];
			break;
		case kObjectCraftMothID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftMothSprite filter:GL_LINEAR];
			break;
		case kObjectCraftBeetleID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftBeetleSprite filter:GL_LINEAR];
			break;
		case kObjectCraftMonarchID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftMonarchSprite filter:GL_LINEAR];
			break;
		case kObjectCraftCamelID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftCamelSprite filter:GL_LINEAR];
			break;
		case kObjectCraftRatID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftRatSprite filter:GL_LINEAR];
			break;
		case kObjectCraftSpiderID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftSpiderSprite filter:GL_LINEAR];
			break;
		case kObjectCraftEagleID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftEagleSprite filter:GL_LINEAR];
			break;
		default:
			break;
	}
	self = [super initWithImage:image withLocation:location withObjectType:typeID];
	if (self) {
		// Initialize the craft
		pathPointArray = nil;
		pathPointNumber = 0;
		isFollowingPath = NO;
		hasCurrentPathFinished = YES;
		friendlyAIState = kFriendlyAIStateStill;
		renderLayer = 0;
		[self initCraftWithID:typeID];
	}
	return self;
}

- (void)updateObjectTargets {
	// Check if there is an enemy in the closest vicinity
	if (friendlyAIState == kFriendlyAIStateStill ||
		friendlyAIState == kFriendlyAIStateMoving) {
		NSMutableArray* closeCraftArray = [[NSMutableArray alloc] init];
		[[self.currentScene collisionManager] putNearbyObjectsToLocation:objectLocation intoArray:closeCraftArray];
		for (int i = 0; i < [closeCraftArray count]; i++) {
			CollidableObject* obj = [closeCraftArray objectAtIndex:i];
			if ([obj isKindOfClass:[StructureObject class]] || 
				[obj isKindOfClass:[CraftObject class]]) {
				if (obj.objectAlliance == kAllianceEnemy) {
					closestEnemyObject = (TouchableObject*)obj;
					// NSLog(@"Found an enemy: object (%i)", obj.uniqueObjectID);
				}
			}
		}
	}
}

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped {
	if ([array count] == 0) {
		NSLog(@"Path contained no points!");
		return;
	}
	[pathPointArray autorelease];
	pathPointArray = [[NSMutableArray alloc] initWithArray:array];
	isFollowingPath = YES;
	pathPointNumber = 0;
	isPathLooped = looped;
	hasCurrentPathFinished = NO;
}

- (void)stopFollowingCurrentPath {
	isFollowingPath = NO;
	hasCurrentPathFinished = YES;
	friendlyAIState = kFriendlyAIStateStill;
}

- (void)resumeFollowingCurrentPath {
	if (pathPointArray && [pathPointArray count] != 0) {
		isFollowingPath = YES;
		hasCurrentPathFinished = NO;
		friendlyAIState = kFriendlyAIStateMoving;
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	// Get the current point we should be following
	if (isFollowingPath && pathPointArray && !hasCurrentPathFinished) {
		NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
		CGPoint moveTowardsPoint = [pointValue CGPointValue];
		// If the craft has reached the point...
		if (AreCGPointsEqual(objectLocation, moveTowardsPoint)) {
			pathPointNumber++;
		}
		if (pathPointNumber < [pathPointArray count]) {
			NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
			moveTowardsPoint = [pointValue CGPointValue];
		} else {
			if (isPathLooped) {
				pathPointNumber = 0;
			} else {
				isFollowingPath = NO;
				hasCurrentPathFinished = YES;
				friendlyAIState = kFriendlyAIStateStill;
			}
		}
		[self accelerateTowardsLocation:moveTowardsPoint];
	} else {
		[self decelerate];
	}

	[self updateObjectTargets];
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	enablePrimitiveDraw();
	if (isCurrentlyHoveredOver) {
		// Draw "selection circle"
		if (objectAlliance == kAllianceFriendly) {
			glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		} else {
			glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		}
		drawDashedCircle(boundingCircle, 20, vector);
	}
	if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= attributeAttackRange + boundingCircle.radius) {
		glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		glLineWidth(6.0f);
		drawLine(objectLocation, closestEnemyObject.objectLocation, vector);
		glLineWidth(1.0f);
	}
	if (isBeingDragged) {
		if (isBeingControlled) {
			glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		} else {
			glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		}
		float distance = GetDistanceBetweenPoints(objectLocation, dragLocation);
		int segments = distance / 50;
		drawDashedLine(objectLocation, dragLocation, CLAMP(segments, 1, 10), vector);
		
	}
	disablePrimitiveDraw();
	[super renderCenteredAtPoint:aPoint withScrollVector:vector];
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
	if (objectAlliance == kAllianceFriendly) {
		isBeingDragged = YES;
		dragLocation = location;
	}
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
	if (objectAlliance == kAllianceFriendly) {
		dragLocation = toLocation;
	}
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	if (objectAlliance == kAllianceFriendly) {
		if (isBeingDragged) {
			if (!isBeingControlled && friendlyAIState != kFriendlyAIStateMining) {
				NSArray* newPath = [NSArray arrayWithObjects:
									[NSValue valueWithCGPoint:dragLocation],
									nil];
				[self followPath:newPath isLooped:NO];
			} else {
				[self.currentScene attemptToControlShipAtLocation:location];
			}
		}
		isBeingDragged = NO;
		dragLocation = objectLocation;
	}
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!",uniqueObjectID);
}

@end
