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
@synthesize miningLocation;

- (void)dealloc {
	[turretPointsArray release];
	[lightPointsArray release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftAntID withLocation:location isTraveling:traveling];
	if (self) {
		attributePlayerCargoCapacity = kCraftAntCargoSpace;
		attributePlayerCurrentCargo = 0;
		attributeMiningSpeed = kCraftAntMiningSpeed;
		miningState = kMiningStateNone;
	}
	return self;
}

- (void)updateCraftLightLocations { // Too Slow!!
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

- (CGPoint)miningLocation {
	return miningLocation;
}

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
		[self.currentScene addBroggutValue:attributePlayerCurrentCargo atLocation:objectLocation];
		attributePlayerCurrentCargo = 0;
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
			attributePlayerCurrentCargo += CLAMP(attributeMiningSpeed, 0, broggut->broggutValue);
			attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo, 0, attributePlayerCargoCapacity);
			broggut->broggutValue -= CLAMP(attributeMiningSpeed, 0, attributePlayerCargoCapacity);
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
        [[self currentScene] removeControlledCraft:self];
		[self startMiningBroggutWithLocation:location];
	}
	
	[super touchesEndedAtLocation:location];
}

@end
