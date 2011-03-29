//
//  AntCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "AntCraftObject.h"
#import "CollisionManager.h"
#import "BroggutScene.h"
#import "BroggutObject.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "ParticleSingleton.h"
#import "Image.h"

enum MiningStates {
	kMiningStateMining,
	kMiningStateApproaching,
	kMiningStateReturning,
	kMiningStateNone,
};

@implementation AntCraftObject
@synthesize miningLocation, miningAIValue;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftAntID withLocation:location isTraveling:traveling];
	if (self) {
        [self createLightLocationsWithCount:1];
		attributePlayerCargoCapacity = kCraftAntCargoSpace;
		attributePlayerCurrentCargo = 0;
		attributeMiningCooldown = kCraftAntMiningCooldown;
        miningCooldownTimer = 0;
		miningState = kMiningStateNone;
        miningAIValue = 0.0f;
	}
	return self;
}

- (void)updateCraftLightLocations { // Too Slow!!
	for (int i = 0; i < lightPointsArray->pointCount; i++) {
        PointLocation* curPoint = &lightPointsArray->locations[i];
        curPoint->x = objectLocation.x;
        curPoint->y = objectLocation.y;
    }
}

- (void)updateCraftTurretLocations {
	// Update turret locations
}

- (CGPoint)miningLocation {
	return miningLocation;
}
/*
 - (void)objectEnteredEffectRadius:(TouchableObject *)other {
 if (objectAlliance != other.objectAlliance) {
 NSLog(@"Object entered");
 }
 [super objectEnteredEffectRadius:other];
 }
 */
- (void)tryMiningBroggutsWithCenter:(CGPoint)location {
	if (attributePlayerCurrentCargo >= attributePlayerCargoCapacity) {
		[self returnBroggutsHome];
		miningLocation = location;
		return;
	}
	if (![self startMiningBroggutWithLocation:location]) {
		// Middle broggut isn't minable
		for (int i = -1; i < 2; i++) {
			for (int j = -1; j < 2; j++) {
				if (i == 0 && j == 0) {
					continue;
				}
				CGPoint point = CGPointMake(location.x + (i * COLLISION_CELL_WIDTH), location.y + (j * COLLISION_CELL_HEIGHT));
				if ([self startMiningBroggutWithLocation:point]) {
					break;
				}
			}
		}
	}
}

- (BOOL)startMiningBroggutWithLocation:(CGPoint)location {
	MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:location];
	if (broggut && broggut->broggutValue != -1 && broggut->broggutEdge != kMediumBroggutEdgeNone) {
		// NSLog(@"Started object (%i) mining broggut (%i) with value (%i)", uniqueObjectID, broggut->broggutID, broggut->broggutValue);
		CGPoint broggutLoc = [[self.currentScene collisionManager] getBroggutLocationForID:broggut->broggutID];
		miningBroggutID = broggut->broggutID;
		miningLocation = broggutLoc;
		NSArray* pathArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:broggutLoc], nil];
		[self followPath:pathArray isLooped:NO];
		miningState = kMiningStateApproaching;
		[self setMovingAIState:kMovingAIStateMining];
        if (isBeingControlled) {
            [[self currentScene] removeControlledCraft:self];
            [self setIsBeingControlled:NO];
        }
		return YES;
	} else {
		miningState = kMiningStateNone;
		[self setMovingAIState:kMovingAIStateStill];
		return NO;
	}
}

- (void)addCargo:(int)cargo {
	attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo + cargo, 0, attributePlayerCargoCapacity);
}

- (void)cashInBrogguts {
	if (attributePlayerCurrentCargo > 0) {
		[self.currentScene addBroggutValue:attributePlayerCurrentCargo atLocation:objectLocation withAlliance:objectAlliance];
		attributePlayerCurrentCargo = 0;
		if (miningState == kMiningStateReturning) {
			[self tryMiningBroggutsWithCenter:miningLocation];
		}
	}
}

- (void)returnBroggutsHome {
    if (objectAlliance == kAllianceFriendly) {
        NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:[self.currentScene homeBaseLocation]]];
        [self followPath:homePath isLooped:NO];
    } else if (objectAlliance == kAllianceEnemy) {
        NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:[self.currentScene enemyBaseLocation]]];
        [self followPath:homePath isLooped:NO];
    }
	[self setMovingAIState:kMovingAIStateMining];
	miningState = kMiningStateReturning;
}

- (void)followPath:(NSArray *)array isLooped:(BOOL)looped {
	miningState = kMiningStateNone;
	[super followPath:array isLooped:looped];
}

- (void)stopFollowingCurrentPath {
	miningState = kMiningStateNone;
	[super stopFollowingCurrentPath];
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	[super updateObjectLogicWithDelta:aDelta];
    
    if ([self isOnScreen]) {
        BroggutObject* closestBrog = [[[self currentScene] collisionManager] closestSmallBroggutToLocation:objectLocation];
        if (isTouchable && closestBrog && !closestBrog.destroyNow) {
            if (GetDistanceBetweenPointsSquared(objectLocation, closestBrog.objectLocation) < POW2(attributeAttackRange / 2)) {
                if ( (attributePlayerCurrentCargo + closestBrog.broggutValue) < attributePlayerCargoCapacity) {
                    [self addCargo:closestBrog.broggutValue];
                    [closestBrog setDestroyNow:YES];
                    [[ParticleSingleton sharedParticleSingleton] createParticles:10 withType:kParticleTypeBroggut atLocation:closestBrog.objectLocation];
                }
            }
        }
    }
    
	// Mine from broggut when close and in mining state
	if (hasCurrentPathFinished && miningState == kMiningStateApproaching) {
		// Just arrived at the broggut location
		miningState = kMiningStateMining;
	}
	
	// When arrived at broggut, start mining
	if (hasCurrentPathFinished && miningState == kMiningStateMining) {
		[self setMovingAIState:kMovingAIStateMining];
		// Harvest some brogguts!
		MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:miningLocation];
		if (broggut->broggutValue > 0) {
			// There are still brogguts left...
            if (miningCooldownTimer <= 0) {
                miningCooldownTimer = attributeMiningCooldown;
                attributePlayerCurrentCargo += CLAMP(1, 0, broggut->broggutValue);
                attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo, 0, attributePlayerCargoCapacity);
                broggut->broggutValue -= CLAMP(1, 0, attributePlayerCargoCapacity);
            } else {
                miningCooldownTimer--;
            }
		}
		// Check if the broggut is out
		if (broggut->broggutValue <= 0) {
			// The broggut is dead and should be destroyed...
			[[self.currentScene collisionManager] removeMediumBroggutWithID:broggut->broggutID];
			// Return home
			[self returnBroggutsHome];
		}
		// Check if cargo has full brogguts
		if (attributePlayerCurrentCargo == attributePlayerCargoCapacity) {
			// Ship is full, bring her home
			[self returnBroggutsHome];
		}
	}
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    enablePrimitiveDraw();
    
    // Draw a line to the closest broggut
    BroggutObject* closestBrog = [[[self currentScene] collisionManager] closestSmallBroggutToLocation:objectLocation];
    if (closestBrog && GetDistanceBetweenPointsSquared(objectLocation, closestBrog.objectLocation) < POW2(attributeAttackRange)) {
        glColor4f(1.0f, 1.0f, 0.0f, 0.75f);
        drawLine(objectLocation, closestBrog.objectLocation, scroll);
    }
    
	if (miningState == kMiningStateMining) {
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		float randX = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_WIDTH) / 4);
		float randY = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_HEIGHT) / 4);
		glLineWidth(3.0f);
		drawLine(objectLocation, CGPointMake(miningLocation.x + randX, miningLocation.y + randY), scroll);
		glLineWidth(1.0f);
	}
    
    disablePrimitiveDraw();
}

- (void)renderUnderObjectWithScroll:(Vector2f)scroll {
    [super renderUnderObjectWithScroll:scroll];
    if (isBeingDragged) {
		[[self.currentScene collisionManager] drawValidityRectForLocation:dragLocation forMining:YES];
	}
    
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	if (isBeingDragged) {
		[self startMiningBroggutWithLocation:location];
	}
	[super touchesEndedAtLocation:location];
}

@end
