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
#import "GameController.h"
#import "PlayerProfile.h"

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
        droneBuildTimer = kCraftSpiderBuildDroneTime;
        for (int i = 0; i < SPIDER_NUMBER_OF_DRONES; i++) {
            droneBayContainment[i] = NO;
            [self addNewDroneToBay];
        }
	}
	return self;
}

- (void)setObjectAlliance:(int)alliance {
    for (SpiderDroneObject* drone in droneArray) {
		[drone setObjectAlliance:alliance];
    }
    [super setObjectAlliance:alliance];
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

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
    [super drawHoverSelectionWithScroll:scroll];
    for (SpiderDroneObject* drone in droneArray) {
		[drone drawHoverSelectionWithScroll:scroll];
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
	
    if (droneBuildTimer <= 0) {
        droneBuildTimer = kCraftSpiderBuildDroneTime;
        if (droneCount < droneCountLimit) {
            [self addNewDroneToBay];
            [[self currentScene] addBroggutTextValue:-kCraftSpiderDroneCostBrogguts atLocation:objectLocation withAlliance:kAllianceFriendly];
            [[[GameController sharedGameController] currentProfile] addBrogguts:-kCraftSpiderDroneCostBrogguts];
        }
	} else if (!isTraveling) {
        droneBuildTimer -= 1;
    }
    
	// This ship does not rotate
	objectImage.rotation = 0;
}

- (void)addNewDroneToBay {
    int droneIndex = 0;
    for (int i = 0; i < SPIDER_NUMBER_OF_DRONES; i++) {
        if (droneBayContainment[i] == NO) {
            droneIndex = i;
            break;
        }
    }
	if (droneCount < droneCountLimit) {
		SpiderDroneObject* newDrone = [[SpiderDroneObject alloc] initWithLocation:objectLocation isTraveling:NO];
		[self.currentScene addTouchableObject:newDrone withColliding:NO];
		[droneArray addObject:newDrone];
        droneBayContainment[droneIndex] = YES;
		float radDir = 2 * M_PI * droneIndex / droneCountLimit;
		float xBay = cosf(radDir) * self.boundingCircle.radius;
		float yBay = sinf(radDir) * self.boundingCircle.radius;
		newDrone.droneBayLocation = Vector2fMake(xBay, yBay);
		newDrone.isHidden = YES;
		newDrone.mySpiderCraft = self;
		newDrone.objectAlliance = objectAlliance;
        newDrone.droneIndex = droneIndex;
        if (closestEnemyObject) {
            [newDrone setPriorityEnemyTarget:closestEnemyObject];
            [newDrone stopFollowingCurrentPath];
            if (newDrone.droneAIState == kDroneAIStateHidden) {
                [newDrone setDroneAIState:kDroneAIStateApproaching];
            }
        }
		[newDrone release];
		droneCount++;
	}
}

- (void)removeDrone:(SpiderDroneObject*)drone {
	if (drone)
		[droneArray removeObject:drone];
	droneCount = [droneArray count];
    droneBayContainment[drone.droneIndex] = NO;
}

- (void)objectWasDestroyed {
	for (SpiderDroneObject* drone in droneArray) {
		[drone setDestroyNow:YES];
	}
	[super objectWasDestroyed];
}

@end
