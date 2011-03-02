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

- (void)dealloc {
	[turretPointsArray release];
	[lightPointsArray release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftAntID withLocation:location isTraveling:traveling];
	if (self) {
		attributeCargoCapacity = kCraftAntCargoSpace;
		attributeCurrentCargo = 0;
		attributeMiningSpeed = kCraftAntMiningSpeed;
		miningState = kMiningStateNone;
	}
	return self;
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

- (void)startMiningBroggutWithLocation:(CGPoint)location {
	MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:location];
	if (broggut && broggut->broggutValue != -1 && broggut->broggutEdge != kMediumBroggutEdgeNone) {
		NSLog(@"Started object (%i) mining broggut (%i) with value (%i)", uniqueObjectID, broggut->broggutID, broggut->broggutValue);
		CGPoint broggutLoc = [[self.currentScene collisionManager] getBroggutLocationForID:broggut->broggutID];
		miningBroggutID = broggut->broggutID;
		miningLocation = broggutLoc;
		NSArray* pathArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:broggutLoc], nil];
		[self followPath:pathArray isLooped:NO];
		miningState = kMiningStateApproaching;
		friendlyAIState = kFriendlyAIStateMining;
	} else {
		miningState = kMiningStateNone;
		friendlyAIState = kFriendlyAIStateStill;
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
			[self startMiningBroggutWithLocation:miningLocation];
		}
	}
}

- (void)returnBroggutsHome {
	NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:[self.currentScene homeBaseLocation]]];
	[self followPath:homePath isLooped:NO];
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
	// Mine from broggut when close and in mining state
	if (hasCurrentPathFinished && miningState == kMiningStateApproaching) {
		// Just arrived at the broggut location
		miningState = kMiningStateMining;
	}
	
	// When arrived at broggut, start mining
	if (hasCurrentPathFinished && miningState == kMiningStateMining) {
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
	
	[super updateObjectLogicWithDelta:aDelta];
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
	if (isBeingDragged) {
		[self startMiningBroggutWithLocation:location];
	}
	
	[super touchesEndedAtLocation:location];
}

@end