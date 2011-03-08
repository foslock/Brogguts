//
//  SpiderCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SpiderCraftObject.h"
#import "BroggutScene.h"
#import "Image.h"

@implementation SpiderCraftObject

- (void)dealloc {
	[droneArray release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftSpiderID withLocation:location isTraveling:traveling];
	if (self) {
		droneArray = [[NSMutableArray alloc] initWithCapacity:SPIDER_NUMBER_OF_DRONES];
		droneCount = 0;
		droneCountLimit = SPIDER_NUMBER_OF_DRONES;
	}
	return self;
}

- (void)setClosestEnemyObject:(TouchableObject *)target {
	[super setClosestEnemyObject:target];
	for (SpiderDroneObject* drone in droneArray) {
		[drone setPriorityEnemyTarget:target];
		[drone stopFollowingCurrentPath];
		if (drone.droneAIState == kDroneAIStateHidden) {
			[drone setDroneAIState:kDroneAIStateApproaching];
		}
	}
}

- (void)setPriorityEnemyTarget:(TouchableObject *)target {
	[super setPriorityEnemyTarget:target];
	for (SpiderDroneObject* drone in droneArray) {
		[drone setPriorityEnemyTarget:target];
		[drone stopFollowingCurrentPath];
	}
}

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location {
	if ([super performSpecialAbilityAtLocation:location]) {
		TouchableObject* enemy = [self.currentScene attemptToGetEnemyAtLocation:location];
		if (enemy) {
			[self setPriorityEnemyTarget:enemy];
			[self stopFollowingCurrentPath];
		}
		return YES;
	}
	return NO;
}

- (void)setObjectRotation:(float)rot {
	[super setObjectRotation:rot];
	objectImage.rotation = 0;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	[super updateObjectLogicWithDelta:aDelta];
	
	if (droneCount < droneCountLimit) {
		[self addNewDroneToBay];
	}
	
	// This ship does not rotate
	objectImage.rotation = 0;
}

- (void)addNewDroneToBay {
	if (droneCount < droneCountLimit) {
		SpiderDroneObject* newDrone = [[SpiderDroneObject alloc] initWithLocation:objectLocation isTraveling:NO];
		[self.currentScene addTouchableObject:newDrone withColliding:NO];
		[droneArray addObject:newDrone];
		float radDir = 2 * M_PI * droneCount / droneCountLimit;
		float xBay = cosf(radDir) * self.boundingCircle.radius;
		float yBay = sinf(radDir) * self.boundingCircle.radius;
		newDrone.droneBayLocation = Vector2fMake(xBay, yBay);
		newDrone.isHidden = YES;
		newDrone.mySpiderCraft = self;
		newDrone.objectAlliance = self.objectAlliance;
		[newDrone release];
		droneCount++;
	}
}

- (void)removeDrone:(SpiderDroneObject*)drone {
	if (drone)
		[droneArray removeObject:drone];
	droneCount = [droneArray count];
}

- (void)objectWasDestroyed {
	for (SpiderDroneObject* drone in droneArray) {
		[drone setDestroyNow:YES];
	}
	[super objectWasDestroyed];
}

@end
