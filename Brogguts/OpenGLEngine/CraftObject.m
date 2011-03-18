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
#import "CraftAndStructures.h"

@implementation CraftObject
@synthesize isFollowingPath, craftAIInfo, attributePlayerCurrentCargo, attributePlayerCargoCapacity, attributeHullCurrent;

- (void)dealloc {
    if (turretPointsArray) {
        if (turretPointsArray->locations) {
            free(turretPointsArray->locations);
        }
        free(turretPointsArray);
    }
    
    if (lightPointsArray) {
        if (lightPointsArray->locations) {
            free(lightPointsArray->locations);
        }
        free(lightPointsArray);
    }
    
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
			attributeSpecialCooldown = kCraftAntSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftMothSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftBeetleSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftMonarchSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftCamelSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftRatSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftSpiderSpecialCoolDown;
			break;
		case kObjectCraftSpiderDroneID:
			attributeBroggutCost = kCraftSpiderDroneCostBrogguts;
			attributeMetalCost = kCraftSpiderDroneCostMetal;
			attributeEngines = kCraftSpiderDroneEngines;
			attributeWeaponsDamage = kCraftSpiderDroneWeapons;
			attributeAttackRange = kCraftSpiderDroneAttackRange;
			attributeAttackCooldown = kCraftSpiderDroneAttackCooldown;
			attributeHullCapacity = kCraftSpiderDroneHull;
			attributeHullCurrent = kCraftSpiderDroneHull;
			attributeSpecialCooldown = kCraftSpiderDroneSpecialCoolDown;
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
			attributeSpecialCooldown = kCraftEagleSpecialCoolDown;
			break;
		default:
			break;
	}
	maxVelocity = attributeEngines; // Set the maximum velocity
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
		case kObjectCraftSpiderDroneID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftSpiderDroneSprite filter:GL_LINEAR];
			break;
		case kObjectCraftEagleID:
			image = [[Image alloc] initWithImageNamed:kObjectCraftEagleSprite filter:GL_LINEAR];
			break;
		default:
            image = [[Image alloc] initWithImageNamed:kObjectCraftAntSprite filter:GL_LINEAR];
            break;
	}
	self = [super initWithImage:image withLocation:location withObjectType:typeID];
    [image release];
	if (self) {
		// Initialize the craft
		[self initCraftWithID:typeID];
        [self calculateCraftAIInfo];
		lightBlinkTimer = (arc4random() % LIGHT_BLINK_FREQUENCY) + 1;
		lightBlinkAlpha = 0.0f;
		blinkingLightImage = [[Image alloc] initWithImageNamed:@"defaultTexture.png" filter:GL_LINEAR];
		blinkingLightImage.scale = Scale2fMake(0.25f, 0.25f);
        
        lightPointsArray = NULL;
        turretPointsArray = NULL;
        
		pathPointArray = nil;
		pathPointNumber = 0;
		isFollowingPath = NO;
		hasCurrentPathFinished = YES;
		[self setMovingAIState:kMovingAIStateStill];
		[self setAttackingAIState:kAttackingAIStateNeutral];
		renderLayer = 0;
		isCheckedForRadialEffect = YES;
		attributePlayerCurrentCargo = 0;
		attributePlayerCargoCapacity = 200;
		squadMonarch = nil;
		effectRadius = attributeAttackRange;
		attackCooldownTimer = 0;
		isSpecialAbilityCooling = NO;
		isSpecialAbilityActive = NO;
		specialAbilityCooldownTimer = 0;
		creationEndLocation = location;
		if (traveling) {
			[self setIsTraveling:YES];
			NSArray* path = [NSArray arrayWithObject:[NSValue valueWithCGPoint:location]];
			[self followPath:path isLooped:NO];
		}
	}
	return self;
}

- (void)createLightLocationsWithCount:(int)lightCount {
    if (lightPointsArray) {
        if (lightPointsArray->locations) {
            free(lightPointsArray->locations);
        }
        free(lightPointsArray);
    }
    
    lightPointsArray = (PointArray*)malloc( sizeof(*lightPointsArray) );
    lightPointsArray->pointCount = lightCount;
    lightPointsArray->locations = (PointLocation*)malloc(lightCount * sizeof(PointLocation) );
}

- (void)createTurretLocationsWithCount:(int)turretCount {
    if (turretPointsArray) {
        if (turretPointsArray->locations) {
            free(turretPointsArray->locations);
        }
        free(turretPointsArray);
    }
    
    turretPointsArray = (PointArray*)malloc( sizeof(*turretPointsArray) );
    turretPointsArray->pointCount = turretCount;
    turretPointsArray->locations = (PointLocation*)malloc(turretCount * sizeof(PointLocation) );
}

- (void)calculateCraftAIInfo {
    
    float attackValue = (attributeEngines / (float)kMaximumEnginesValue) +
    (attributeAttackRange / (float)kMaximumAttackRangeValue) +
    (attributeWeaponsDamage / (float)kMaximumWeaponsValue) -
    (attributeAttackCooldown / (float)kMaximumAttackCooldownValue);
    
    float defenseValue = (attributeAttackRange / (float)kMaximumAttackRangeValue) +
    (attributeWeaponsDamage / (float)kMaximumWeaponsValue) -
    (attributeAttackCooldown / (float)kMaximumAttackCooldownValue) +
    (attributeHullCurrent / (float)attributeHullCapacity);
    
    craftAIInfo.computedAttackValue = attackValue / 4.0f;
    craftAIInfo.computedDefendValue = defenseValue / 4.0f;
    craftAIInfo.averageCraftValue = ( (attackValue / 4.0f) + (defenseValue / 4.0f) ) / 2.0f;
    
    if ([self isKindOfClass:[AntCraftObject class]] || [self isKindOfClass:[CamelCraftObject class]]) {
        craftAIInfo.computedMiningValue = 1;
    } else {
        craftAIInfo.computedMiningValue = 0;
    }
}

- (void)updateCraftLightLocations {
    // OVERRIDE FOR EACH CRAFT
}

- (void)updateCraftTurretLocations {
    // OVERRIDE FOR EACH CRAFT
}

- (CGPoint)miningLocation {
    return CGPointZero;
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
    [self setMovingAIState:kMovingAIStateMoving];
    // Must reset the state after the follow path call if want to change from moving
}

- (void)stopFollowingCurrentPath {
    isFollowingPath = NO;
    hasCurrentPathFinished = YES;
    [self setMovingAIState:kMovingAIStateStill];
}

- (void)resumeFollowingCurrentPath {
    if (pathPointArray && [pathPointArray count] != 0) {
        isFollowingPath = YES;
        hasCurrentPathFinished = NO;
        [self setMovingAIState:kMovingAIStateMoving];
    }
}

- (void)accelerateTowardsLocation:(CGPoint)location {
    if ([self isOnScreen] && objectType != kObjectCraftSpiderDroneID)
        [[ParticleSingleton sharedParticleSingleton] createParticles:1 withType:kParticleTypeShipThruster atLocation:objectLocation];
    [super accelerateTowardsLocation:location];
}

- (void)targetWasDestroyed:(TouchableObject *)target {
    if (target == closestEnemyObject) {
        if (attackingAIState == kAttackingAIStateAttacking) {
            [self setAttackingAIState:kAttackingAIStateNeutral];
        }
    }
    [super targetWasDestroyed:target];
}

- (BOOL)attackedByEnemy:(TouchableObject *)enemy withDamage:(int)damage {
    [super attackedByEnemy:enemy withDamage:damage];
    attributeHullCurrent -= damage;
    if (attributeHullCurrent <= 0) {
        destroyNow = YES;
        return YES;
    }
    BOOL returnedAttack = NO;
    if (attackingAIState != kAttackingAIStateAttacking && !isBeingControlled && !isBeingDragged) {
        if ([enemy isKindOfClass:[CraftObject class]]) {
            CraftObject* enemyCraft = (CraftObject*)enemy;
            [enemyCraft calculateCraftAIInfo];
            NSMutableArray* nearbyCraftArray = [[NSMutableArray alloc] init];
            [[[self currentScene] collisionManager] putNearbyObjectsToLocation:objectLocation intoArray:nearbyCraftArray];
            float totalCraftPower = 0.0f;
            for (int i = 0; i < [nearbyCraftArray count]; i++) {
                CollidableObject* obj = [nearbyCraftArray objectAtIndex:i];
                if ([obj isKindOfClass:[CraftObject class]]) {
                    CraftObject* craft = (CraftObject*)obj;
                    if (craft.objectAlliance == objectAlliance) {
                        [craft calculateCraftAIInfo];
                        totalCraftPower += craft.craftAIInfo.averageCraftValue;
                    }
                }
            }
            if (totalCraftPower > enemyCraft.craftAIInfo.averageCraftValue) {
                returnedAttack = YES;
                for (int i = 0; i < [nearbyCraftArray count]; i++) {
                    CollidableObject* obj = [nearbyCraftArray objectAtIndex:i];
                    if ([obj isKindOfClass:[CraftObject class]]) {
                        CraftObject* craft = (CraftObject*)obj;
                        if (craft.objectAlliance == objectAlliance) {
                            [craft setPriorityEnemyTarget:enemy];
                        }
                    }
                }
            }
            [nearbyCraftArray release];
        }
    }
    
    if (!returnedAttack && movingAIState == kMovingAIStateStill && attackingAIState == kAttackingAIStateNeutral
               && !isBeingControlled && !isBeingDragged) {
        // Move away from the attacker
        float xDest = objectLocation.x;
        float yDest = objectLocation.y;
        if (enemy.objectLocation.x < objectLocation.x) {
            xDest += COLLISION_CELL_WIDTH;
        } else {
            xDest -= COLLISION_CELL_WIDTH;
        }
        if (enemy.objectLocation.y < objectLocation.y) {
            yDest += COLLISION_CELL_HEIGHT;
        } else {
            yDest -= COLLISION_CELL_HEIGHT;
        }
        NSArray* newPath = [[self.currentScene collisionManager] pathFrom:objectLocation to:CGPointMake(xDest, yDest) allowPartial:NO isStraight:NO];
        [self followPath:newPath isLooped:NO];
        [self setMovingAIState:kMovingAIStateMoving];
    }
    return NO;
}

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location {
    // Override in each ship with special ability, CALL THIS FIRST
    if (isSpecialAbilityActive || isSpecialAbilityCooling || specialAbilityCooldownTimer > 0 ||
        attributeSpecialCooldown == 0) { // If the ability is passive, don't do anything
        return NO;
    }
    specialAbilityCooldownTimer = attributeSpecialCooldown;
    isSpecialAbilityCooling = YES;
    isSpecialAbilityActive = YES;
    return YES;
    // NSLog(@"Special performed");
}

- (void)attackTarget {
    CGPoint enemyPoint = closestEnemyObject.objectLocation;
    attackLaserTargetPosition = CGPointMake(enemyPoint.x + (RANDOM_MINUS_1_TO_1() * 20.0f),
                                            enemyPoint.y + (RANDOM_MINUS_1_TO_1() * 20.0f));
    [[ParticleSingleton sharedParticleSingleton] createParticles:4 withType:kParticleTypeSpark atLocation:attackLaserTargetPosition];
    attackCooldownTimer = attributeAttackCooldown;
    if ([closestEnemyObject attackedByEnemy:self withDamage:attributeWeaponsDamage]) {
        [self setClosestEnemyObject:nil];
    }
}

- (void)repairCraft:(int)amount {
    int newHP = attributeHullCurrent + amount;
    attributeHullCurrent = CLAMP(newHP, 0, attributeHullCapacity);
}

- (BOOL)isHullFull {
    if (attributeHullCurrent == attributeHullCapacity) {
        return YES;
    }
    return NO;
}

- (void)setCurrentHull:(int)newHull {
    if (newHull >= 0) {
        attributeHullCurrent = CLAMP(newHull, 0, attributeHullCapacity);
    }
}

- (void)setPriorityEnemyTarget:(TouchableObject*)target {
    [self setClosestEnemyObject:target];
    [target blinkSelectionCircle];
    [self setAttackingAIState:kAttackingAIStateAttacking];
    if (objectType != kObjectCraftSpiderDroneID) {
        if (GetDistanceBetweenPointsSquared(objectLocation, target.objectLocation) >= POW2(attributeAttackRange)) {
            float distance = attributeAttackRange - maxVelocity;
            float pointDir = atan2f(objectLocation.y - target.objectLocation.y,
                                    objectLocation.x - target.objectLocation.x);
            float xDist = distance * cosf(pointDir);
            float yDist = distance * sinf(pointDir);
            CGPoint followPoint = CGPointMake(target.objectLocation.x + xDist,
                                              target.objectLocation.y + yDist);
            NSArray* newPath = [[self.currentScene
                                 collisionManager]
                                pathFrom:objectLocation to:followPoint allowPartial:NO isStraight:YES];
            [self followPath:newPath isLooped:NO];
        }
    } else {
        NSArray* newPath = [[self.currentScene
                             collisionManager]
                            pathFrom:objectLocation to:target.objectLocation allowPartial:NO isStraight:YES];
        [self followPath:newPath isLooped:NO];
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    if (attributeHullCurrent <= 0) {
        destroyNow = YES;
        return;
    }
    
    if (specialAbilityCooldownTimer > 0) { // Reduce the special counter timer by one each frame
        isSpecialAbilityCooling = YES;
        specialAbilityCooldownTimer--;
        if (specialAbilityCooldownTimer <= 0) {
            isSpecialAbilityCooling = NO;
            isSpecialAbilityActive = NO;
            specialAbilityCooldownTimer = 0;
        }
    }
    
    // Get the current point we should be following
    if (isFollowingPath && pathPointArray && !hasCurrentPathFinished) {
        NSValue* pointValue = [pathPointArray objectAtIndex:pathPointNumber];
        CGPoint moveTowardsPoint = [pointValue CGPointValue];
        // If the craft has reached the point...
        if (AreCGPointsEqual(objectLocation, moveTowardsPoint, attributeEngines)) {
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
                [self setMovingAIState:kMovingAIStateStill];
                if (isTraveling) {
                    [self setIsTraveling:NO];
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
    // [self updateCraftTurretLocations];
    
    // Attack if able!
    if (attackCooldownTimer > 0) {
        attackCooldownTimer--;
    } else {
        if (attributeWeaponsDamage != 0 && attributeAttackCooldown != 0) {
            if (closestEnemyObject && (movingAIState != kMovingAIStateMining) ) {
                if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= attributeAttackRange) {
                    if (attackCooldownTimer == 0 && !closestEnemyObject.destroyNow && !isTraveling) {
                        [self attackTarget];
                    }
                }
            }
        }
    }
    
    // If too far away to attack, and in ATTACKING state, move towards your target
    if (attackingAIState == kAttackingAIStateAttacking && objectType != kObjectCraftSpiderDroneID) {
        if (!isFollowingPath && closestEnemyObject) {
            if (GetDistanceBetweenPointsSquared(objectLocation, closestEnemyObject.objectLocation) >= POW2(attributeAttackRange)) {
                float distance = attributeAttackRange - maxVelocity;
                float pointDir = atan2f(objectLocation.y - closestEnemyObject.objectLocation.y,
                                        objectLocation.x - closestEnemyObject.objectLocation.x);
                float xDist = distance * cosf(pointDir);
                float yDist = distance * sinf(pointDir);
                CGPoint followPoint = CGPointMake(closestEnemyObject.objectLocation.x + xDist,
                                                  closestEnemyObject.objectLocation.y + yDist);
                NSArray* newPath = [[self.currentScene
                                     collisionManager]
                                    pathFrom:objectLocation to:followPoint allowPartial:NO isStraight:YES];
                [self followPath:newPath isLooped:NO];
            }
        }
    }
    
    // If the closest target is too far away, and not in ATTACKING state, set it to nil
    if (attackingAIState != kAttackingAIStateAttacking && !([self isKindOfClass:[SpiderDroneObject class]])) {
        if (closestEnemyObject) {
            if (GetDistanceBetweenPointsSquared(objectLocation, closestEnemyObject.objectLocation) > POW2(attributeAttackRange)) {
                [self setClosestEnemyObject:nil];
            }
        }
    }
    
    [super updateObjectLogicWithDelta:aDelta];
}

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
    // Draw "selection circle"
    glLineWidth(2.0f);
    if (objectAlliance == kAllianceFriendly) {
        Color4f filled = Color4fMake(0.0f, 1.0f, 0.0f, 1.0f);
        Color4f unfilled = Color4fMake(0.5f, 0.5f, 0.5f, 0.6f);
        drawPartialDashedCircle(self.boundingCircle, attributeHullCurrent, attributeHullCapacity, filled, unfilled, scroll);
    } else {
        Color4f filled = Color4fMake(1.0f, 0.0f, 0.0f, 1.0f);
        Color4f unfilled = Color4fMake(0.5f, 0.5f, 0.5f, 0.6f);
        drawPartialDashedCircle(self.boundingCircle, attributeHullCurrent, attributeHullCapacity, filled, unfilled, scroll);
    }
    glLineWidth(1.0f);
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    if (![self isOnScreen]) {
        return;
    }
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
    enablePrimitiveDraw();
    
    if (isCurrentlyHoveredOver || isBeingControlled && !isBlinkingSelectionCircle) {
        [self drawHoverSelectionWithScroll:vector];
    }
    
    // Draw the laser attack
    if (attributeWeaponsDamage != 0) {
        if (GetDistanceBetweenPointsSquared(objectLocation, closestEnemyObject.objectLocation) <= POW2(attributeAttackRange + maxVelocity)) {
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
    }
    
    // Draw dragging line
    if (isBeingDragged) {
        glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
        float distance = GetDistanceBetweenPoints(objectLocation, dragLocation);
        int segments = distance / 50;
        drawDashedLine(objectLocation, dragLocation, CLAMP(segments, 1, 10), vector);
    }
    
    // Render blinking lights
    if (lightPointsArray) {
        for (int i = 0; i < lightPointsArray->pointCount; i++) {
            PointLocation curPoint = lightPointsArray->locations[i];
            if (self.objectAlliance == kAllianceFriendly) {
                if (!isTraveling)
                    blinkingLightImage.color = Color4fMake(0.0f, 1.0f, 0.0f, lightBlinkAlpha);
                else
                    blinkingLightImage.color = Color4fMake(1.0f, 1.0f, 0.0f, lightBlinkAlpha);
            } else {
                blinkingLightImage.color = Color4fMake(1.0f, 0.0f, 0.0f, lightBlinkAlpha);
            }
            [blinkingLightImage renderCenteredAtPoint:CGPointMake(curPoint.x, curPoint.y) withScrollVector:vector];
        }
    }
    
#ifdef DRAW_PATH
    if (isFollowingPath) {
        glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
        drawPath(pathPointArray, vector);
    }
#endif
    
    disablePrimitiveDraw();
}

- (void)addCargo:(int)cargo {
    attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo + cargo, 0, attributePlayerCargoCapacity);
}

- (void)cashInBrogguts {
    if (attributePlayerCurrentCargo > 0) {
        [self.currentScene addBroggutValue:attributePlayerCurrentCargo atLocation:objectLocation withAlliance:objectAlliance];
        attributePlayerCurrentCargo = 0;
    }
}

- (void)objectWasDestroyed {
    if (isBeingControlled && objectAlliance == kAllianceFriendly) {
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
            if (movingAIState != kMovingAIStateMining) {
                
                NSArray* newPath = [[self.currentScene
                                     collisionManager]
                                    pathFrom:objectLocation to:dragLocation allowPartial:NO isStraight:NO];
                [self followPath:newPath isLooped:NO];
                [self setMovingAIState:kMovingAIStateMoving];
                [self setAttackingAIState:kAttackingAIStateNeutral];
                
                TouchableObject* enemy = [self.currentScene attemptToGetEnemyAtLocation:dragLocation];
                if (enemy) {
                    [self setPriorityEnemyTarget:enemy];
                }
                if (![self isKindOfClass:[MonarchCraftObject class]]) {
                    if ([self.currentScene attemptToPutCraft:self inSquadAtLocation:location]) {
                        [self setMovingAIState:kMovingAIStateMoving];
                    }
                }
            }
            /*
             if (isBeingControlled) {
             if (![self.currentScene attemptToControlCraftAtLocation:location]) {
             if (movingAIState != kMovingAIStateMining)
             [self performSpecialAbilityAtLocation:location];
             }
             }
             */
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