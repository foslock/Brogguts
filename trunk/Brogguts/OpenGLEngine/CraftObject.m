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
#import "ParticleSingleton.h"
#import "MonarchCraftObject.h"

@implementation CraftObject
@synthesize attributePlayerCargoCapacity;

- (void)dealloc {
	[pathPointArray release];
	[blinkingLightImage release];
	[super dealloc];
}

- (void)initCraftWithID:(int)typeID {
	switch (typeID) {
		case kObjectCraftAntID:
			attributeBroggutCost = kCraftAntCostBrogguts;
			attributeMetalCost = kCraftAntCostMetal;
			attributeEngines = kCraftAntEngines;
			attributeWeaponsDamage = kCraftAntWeapons;
			attributeAttackRange = kCraftAntAttackRange;
			attributeAttackCooldown = kCraftAntAttackCooldown;
			attributeHullCapacity = kCraftAntHull;
			attributeHullCurrent = kCraftAntHull;
			break;
		case kObjectCraftMothID:
			attributeBroggutCost = kCraftMothCostBrogguts;
			attributeMetalCost = kCraftMothCostMetal;
			attributeEngines = kCraftMothEngines;
			attributeWeaponsDamage = kCraftMothWeapons;
			attributeAttackRange = kCraftMothAttackRange;
			attributeAttackCooldown = kCraftMothAttackCooldown;
			attributeHullCapacity = kCraftMothHull;
			attributeHullCurrent = kCraftMothHull;
			break;
		case kObjectCraftBeetleID:
			attributeBroggutCost = kCraftBeetleCostBrogguts;
			attributeMetalCost = kCraftBeetleCostMetal;
			attributeEngines = kCraftBeetleEngines;
			attributeWeaponsDamage = kCraftBeetleWeapons;
			attributeAttackRange = kCraftBeetleAttackRange;
			attributeAttackCooldown = kCraftBeetleAttackCooldown;
			attributeHullCapacity = kCraftBeetleHull;
			attributeHullCurrent = kCraftBeetleHull;
			break;
		case kObjectCraftMonarchID:
			attributeBroggutCost = kCraftMonarchCostBrogguts;
			attributeMetalCost = kCraftMonarchCostMetal;
			attributeEngines = kCraftMonarchEngines;
			attributeWeaponsDamage = kCraftMonarchWeapons;
			attributeAttackRange = kCraftMonarchAttackRange;
			attributeAttackCooldown = kCraftMonarchAttackCooldown;
			attributeHullCapacity = kCraftMonarchHull;
			attributeHullCurrent = kCraftMonarchHull;
			break;
		case kObjectCraftCamelID:
			attributeBroggutCost = kCraftCamelCostBrogguts;
			attributeMetalCost = kCraftCamelCostMetal;
			attributeEngines = kCraftCamelEngines;
			attributeWeaponsDamage = kCraftCamelWeapons;
			attributeAttackRange = kCraftCamelAttackRange;
			attributeAttackCooldown = kCraftCamelAttackCooldown;
			attributeHullCapacity = kCraftCamelHull;
			attributeHullCurrent = kCraftCamelHull;
			break;
		case kObjectCraftRatID:
			attributeBroggutCost = kCraftRatCostBrogguts;
			attributeMetalCost = kCraftRatCostMetal;
			attributeEngines = kCraftRatEngines;
			attributeWeaponsDamage = kCraftRatWeapons;
			attributeAttackRange = kCraftRatAttackRange;
			attributeAttackCooldown = kCraftRatAttackCooldown;
			attributeHullCapacity = kCraftRatHull;
			attributeHullCurrent = kCraftRatHull;
			break;
		case kObjectCraftSpiderID:
			attributeBroggutCost = kCraftSpiderCostBrogguts;
			attributeMetalCost = kCraftSpiderCostMetal;
			attributeEngines = kCraftSpiderEngines;
			attributeWeaponsDamage = kCraftSpiderWeapons;
			attributeAttackRange = kCraftSpiderAttackRange;
			attributeAttackCooldown = kCraftSpiderAttackCooldown;
			attributeHullCapacity = kCraftSpiderHull;
			attributeHullCurrent = kCraftSpiderHull;
			break;
		case kObjectCraftEagleID:
			attributeBroggutCost = kCraftEagleCostBrogguts;
			attributeMetalCost = kCraftEagleCostMetal;
			attributeEngines = kCraftEagleEngines;
			attributeWeaponsDamage = kCraftEagleWeapons;
			attributeAttackRange = kCraftEagleAttackRange;
			attributeAttackCooldown = kCraftEagleAttackCooldown;
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
		[self initCraftWithID:typeID];
		lightBlinkTimer = (arc4random() % LIGHT_BLINK_FREQUENCY) + 1;
		lightBlinkAlpha = 0.0f;
		blinkingLightImage = [[Image alloc] initWithImageNamed:@"defaultTexture.png" filter:GL_LINEAR];
		blinkingLightImage.scale = Scale2fMake(0.25f, 0.25f);
		[self updateCraftLightLocations];
		[self updateCraftTurretLocations];
		pathPointArray = nil;
		pathPointNumber = 0;
		isFollowingPath = NO;
		hasCurrentPathFinished = YES;
		friendlyAIState = kFriendlyAIStateStill;
		renderLayer = 0;
		isCheckedForRadialEffect = YES;
		attributePlayerCurrentCargo = 0;
		attributePlayerCargoCapacity = 200;
		squadMonarch = nil;
		effectRadius = attributeAttackRange;
		attackCooldownTimer = 0;
		if (traveling) {
			isTraveling = YES;
			isTouchable = NO;
			NSArray* path = [NSArray arrayWithObject:[NSValue valueWithCGPoint:location]];
			[self followPath:path isLooped:NO];
		}
	}
	return self;
}

- (void)updateCraftLightLocations {
	// OVERRIDE FOR EACH CRAFT
}

- (void)updateCraftTurretLocations {
	// OVERRIDE FOR EACH CRAFT
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

- (void)accelerateTowardsLocation:(CGPoint)location {
	[[ParticleSingleton sharedParticleSingleton] createParticles:1 withType:kParticleTypeShipThruster atLocation:objectLocation];
	[super accelerateTowardsLocation:location];
}

- (BOOL)attackedByEnemy:(TouchableObject *)enemy withDamage:(int)damage {
	[super attackedByEnemy:enemy withDamage:damage];
	attributeHullCurrent -= damage;
	if (attributeHullCurrent <= 0) {
		return YES;
	}
	return NO;
}

- (void)attackTarget {
	if (closestEnemyObject) {
		if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= attributeAttackRange) {
			if (attackCooldownTimer == 0 && !closestEnemyObject.destroyNow && !isTraveling) {
				CGPoint enemyPoint = closestEnemyObject.objectLocation;
				attackLaserTargetPosition = CGPointMake(enemyPoint.x + (RANDOM_MINUS_1_TO_1() * 20.0f),
														enemyPoint.y + (RANDOM_MINUS_1_TO_1() * 20.0f));
				[[ParticleSingleton sharedParticleSingleton] createParticles:10 withType:kParticleTypeSpark atLocation:attackLaserTargetPosition];
				attackCooldownTimer = attributeAttackCooldown;
				if ([closestEnemyObject attackedByEnemy:self withDamage:attributeWeaponsDamage]) {
					[self setClosestEnemyObject:nil];
				}
			}
		}
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	if (attributeHullCurrent <= 0) {
		destroyNow = YES;
		return;
	}
	
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
				if (isTraveling) {
					isTraveling = NO;
					isTouchable = YES;
				}
			}
		}
		[self accelerateTowardsLocation:moveTowardsPoint];
	} else {
		[self decelerate];
	}
	
	// Update the light blinking
	if (lightBlinkTimer == 0) {
		lightBlinkTimer = LIGHT_BLINK_FREQUENCY;
		lightBlinkAlpha = LIGHT_BLINK_BRIGHTNESS;
	} else {
		lightBlinkTimer--;
		lightBlinkAlpha -= LIGHT_BLINK_FADE_SPEED;
	}
	
	// Update the light blinking positions
	[self updateCraftLightLocations];
	
	// Update turret position
	[self updateCraftTurretLocations];
	
	// Attack if able!
	if (attackCooldownTimer > 0) {
		attackCooldownTimer--;
	} else {
		[self attackTarget];
	}
	
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
	if (isCurrentlyHoveredOver) {
		// Draw "selection circle"
		if (objectAlliance == kAllianceFriendly) {
			glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		} else {
			glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		}
		drawDashedCircle(self.boundingCircle, CIRCLE_SEGMENTS_COUNT, scroll);
	}
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	[super renderCenteredAtPoint:aPoint withScrollVector:vector];
	enablePrimitiveDraw();
	[self drawHoverSelectionWithScroll:vector];
	
	// Draw the laser attack
	if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= attributeAttackRange) {
		float width = CLAMP((10.0f * (float)(attackCooldownTimer - (attributeAttackCooldown / 2)) / (float)attributeAttackCooldown), 0.0f, 10.0f);
		if (width != 0.0f) {
			if (objectAlliance == kAllianceFriendly)
				glColor4f(0.2f, 1.0f, 0.2f, 0.8f);
			if (objectAlliance == kAllianceEnemy)
				glColor4f(1.0f, 0.2f, 0.2f, 0.8f);
			glLineWidth(width);
			drawLine(objectLocation, attackLaserTargetPosition, vector);
			glLineWidth(1.0f);
		}
	}
	
	// Draw dragging line
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
	
	// Render blinking lights
	if (lightPointsArray) {
		for (int i = 0; i < [lightPointsArray count]; i++) {
			CGPoint curPoint = [[lightPointsArray objectAtIndex:i] CGPointValue];
			if (self.objectAlliance == kAllianceFriendly) {
				if (!isTraveling)
					blinkingLightImage.color = Color4fMake(0.0f, 1.0f, 0.0f, lightBlinkAlpha);
				else
					blinkingLightImage.color = Color4fMake(1.0f, 1.0f, 0.0f, lightBlinkAlpha);
			} else {
				blinkingLightImage.color = Color4fMake(1.0f, 0.0f, 0.0f, lightBlinkAlpha);
			}
			[blinkingLightImage renderCenteredAtPoint:curPoint withScrollVector:vector];
		}
	}
	
	disablePrimitiveDraw();
}

- (void)addCargo:(int)cargo {
	attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo + cargo, 0, attributePlayerCargoCapacity);
}

- (void)objectWasDestroyed {
	if (isBeingControlled) {
		// The controlling ship was just destroyed
		[self.currentScene controlNearestShipToLocation:objectLocation];
	}
	[super objectWasDestroyed];
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
		if (isBeingDragged && !CircleContainsPoint(self.boundingCircle, location)) {
			if (!isBeingControlled && friendlyAIState != kFriendlyAIStateMining) {
				NSArray* newPath = [NSArray arrayWithObjects:
									[NSValue valueWithCGPoint:dragLocation],
									nil];
				[self followPath:newPath isLooped:NO];
				
				if (![self isKindOfClass:[MonarchCraftObject class]]) {
					[self.currentScene attemptToPutCraft:self inSquadAtLocation:location];
				}
			} else if (isBeingControlled) {
				[self.currentScene attemptToControlCraftAtLocation:location];
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
