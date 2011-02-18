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

enum MiningStates {
	kMiningStateMining,
	kMiningStateApproaching,
	kMiningStateReturning,
	kMiningStateNone,
};

@implementation AntCraftObject

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
	// Check if returning cargo
	if (hasCurrentPathFinished && miningState == kMiningStateReturning) {
		// Cash in brogguts!
		[self.currentScene addBroggutValue:attributeCurrentCargo atLocation:objectLocation];
		attributeCurrentCargo = 0;
		[self startMiningBroggutWithLocation:miningLocation];
	}
	
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
		[[self.currentScene collisionManager] drawValidityRectForLocation:dragLocation];
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
