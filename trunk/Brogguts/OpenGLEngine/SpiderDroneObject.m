//
//  SpiderDroneObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SpiderDroneObject.h"
#import "SpiderCraftObject.h"


@implementation SpiderDroneObject
@synthesize mySpiderCraft, droneBayLocation, droneAIState;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftSpiderDroneID withLocation:location isTraveling:traveling];
	if (self) {
		renderLayer = -1;
		isTouchable = NO;
		droneAIState = kDroneAIStateHidden;
		droneBayLocation = Vector2fZero;
	}
	return self;
}

- (void)attackTarget {
	if (droneAIState == kDroneAIStateApproaching) {
		[super attackTarget];
		droneAIState = kDroneAIStateReturning;
	}
}

- (void)setPriorityEnemyTarget:(TouchableObject *)target {
	[super setPriorityEnemyTarget:target];
	droneAIState = kDroneAIStateApproaching;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	[super updateObjectLogicWithDelta:aDelta];
	
	if (droneAIState == kDroneAIStateHidden) {
		objectLocation = CGPointMake(mySpiderCraft.objectLocation.x + droneBayLocation.x,
									 mySpiderCraft.objectLocation.y + droneBayLocation.y);
		isHidden = YES;
	} else if (droneAIState == kDroneAIStateApproaching) {
		isHidden = NO;
		CGPoint attackLocation = CGPointMake(closestEnemyObject.objectLocation.x, closestEnemyObject.objectLocation.y);
		// Approaching the spider craft's target
		if (closestEnemyObject) {
			[self accelerateTowardsLocation:attackLocation];
		} else {
			droneAIState = kDroneAIStateReturning;
		}
		if (AreCGPointsEqual(attackLocation, objectLocation, attributeEngines)) {
			droneAIState = kDroneAIStateReturning;
		}
	} else if (droneAIState == kDroneAIStateReturning) {
		isHidden = NO;
		// Returning to the spider either to refuel weapons or target was destroyed
		CGPoint bayLocation = CGPointMake(mySpiderCraft.objectLocation.x + droneBayLocation.x,
										  mySpiderCraft.objectLocation.y + droneBayLocation.y);
		[self accelerateTowardsLocation:bayLocation];
		if (AreCGPointsEqual(bayLocation, objectLocation, attributeEngines)) {
			if (closestEnemyObject)
				droneAIState = kDroneAIStateApproaching;
			else 
				droneAIState = kDroneAIStateHidden;
		} 
	}
	
}

- (void)objectWasDestroyed {
	if (mySpiderCraft)
		[mySpiderCraft removeDrone:self];
	[super objectWasDestroyed];
}

@end
