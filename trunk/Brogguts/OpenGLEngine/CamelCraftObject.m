//
//  CamelCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CamelCraftObject.h"
#import "CollisionManager.h"
#import "BroggutScene.h"
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

@implementation CamelCraftObject

- (void)dealloc {
	[turretPointsArray release];
	[lightPointsArray release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftCamelID withLocation:location isTraveling:traveling];
	if (self) {
		attributeCargoCapacity = kCraftCamelCargoSpace;
		attributeCurrentCargo = 0;
		attributeMiningSpeed = kCraftCamelMiningSpeed;
		miningState = kMiningStateNone;
	}
	return self;
}

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location {
	if ([super performSpecialAbilityAtLocation:location]) {
		MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:location];
		if (broggut->broggutValue != -1) {
			broggut->broggutValue == -1;
			[[self.currentScene collisionManager] removeMediumBroggutWithID:broggut->broggutID];
		}
		return YES;
	}
	return NO;
}

- (void)updateCraftLightLocations {
	[lightPointsArray release];
	float radDir = DEGREES_TO_RADIANS(objectRotation);
	CGPoint lPoint1 = CGPointMake(objectLocation.x + (self.boundingCircle.radius * cosf(radDir)),
								  objectLocation.y + (self.boundingCircle.radius * sinf(radDir)));
	
	CGPoint lPoint2 = CGPointMake(objectLocation.x - (self.boundingCircle.radius * cosf(radDir)),
								  objectLocation.y - (self.boundingCircle.radius * sinf(radDir)));
	
	CGPoint lPoint3 = CGPointMake(objectLocation.x + (self.boundingCircle.radius * cosf(radDir)),
								  objectLocation.y + (self.boundingCircle.radius * sinf(radDir)));
	
	CGPoint lPoint4 = CGPointMake(objectLocation.x - (self.boundingCircle.radius * cosf(radDir)),
								  objectLocation.y - (self.boundingCircle.radius * sinf(radDir)));
	
	lightPointsArray = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:lPoint1],
						[NSValue valueWithCGPoint:lPoint2],
						[NSValue valueWithCGPoint:lPoint3],
						[NSValue valueWithCGPoint:lPoint4],
						nil];
}

- (void)updateCraftTurretLocations {
	[turretPointsArray release];
	float radDir = DEGREES_TO_RADIANS(objectRotation);
	CGPoint tPoint1 = CGPointMake((objectLocation.x) * cosf(radDir),
								  (objectLocation.y) * sinf(radDir));
	turretPointsArray = [[NSArray alloc] initWithObjects:[NSValue valueWithCGPoint:tPoint1],
						 nil];
}

- (void)tryMiningBroggutsWithCenter:(CGPoint)location {
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
		return YES;
	} else {
		miningState = kMiningStateNone;
		[self setMovingAIState:kMovingAIStateStill];
		return NO;
	}
}

- (void)addCargo:(int)cargo {
	attributeCurrentCargo = CLAMP(attributeCurrentCargo + cargo, 0, attributeCargoCapacity);
}

- (void)cashInBrogguts {
	if (attributeCurrentCargo > 0) {
		[self.currentScene addBroggutValue:attributeCurrentCargo atLocation:objectLocation];
		attributeCurrentCargo = 0;
		if (miningState == kMiningStateReturning) {
			[self tryMiningBroggutsWithCenter:miningLocation];
		}
	}
}

- (void)returnBroggutsHome {
	NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:[self.currentScene homeBaseLocation]]];
	[self followPath:homePath isLooped:NO];
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
			attributeCurrentCargo += CLAMP(attributeMiningSpeed, 0, broggut->broggutValue);
			attributeCurrentCargo = CLAMP(attributeCurrentCargo, 0, attributeCargoCapacity);
			broggut->broggutValue -= CLAMP(attributeMiningSpeed, 0, attributeCargoCapacity);
		}
		// Check if the broggut is out
		if (broggut->broggutValue <= 0) {
			// The broggut is dead and should be destroyed...
			[[self.currentScene collisionManager] removeMediumBroggutWithID:broggut->broggutID];
			// DESTROY BROGGUT
			[[ParticleSingleton sharedParticleSingleton] createParticles:10 withType:kParticleTypeBroggut atLocation:miningLocation];
			// Return home
			[self returnBroggutsHome];
		}
		// Check if cargo has full brogguts
		if (attributeCurrentCargo == attributeCargoCapacity) {
			// Ship is full, bring her home
			[self returnBroggutsHome];
		}
	}
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	if (isBeingDragged) {
		[[self.currentScene collisionManager] drawValidityRectForLocation:dragLocation forMining:YES];
	}
	if (miningState == kMiningStateMining) {
		enablePrimitiveDraw();
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		float randX = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_WIDTH) / 4);
		float randY = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_HEIGHT) / 4);
		glLineWidth(3.0f);
		drawLine(objectLocation, CGPointMake(miningLocation.x + randX, miningLocation.y + randY), vector);
		glLineWidth(1.0f);
		disablePrimitiveDraw();
	}
	[super renderCenteredAtPoint:aPoint withScrollVector:vector];
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	if (!isBeingControlled && isBeingDragged) {
		[self startMiningBroggutWithLocation:location];
	}
	
	[super touchesEndedAtLocation:location];
}

@end
