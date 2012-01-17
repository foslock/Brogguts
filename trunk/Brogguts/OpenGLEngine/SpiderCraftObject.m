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
#import "UpgradeManager.h"

@implementation SpiderCraftObject

- (void)dealloc {
	[droneArray release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftSpiderID withLocation:location isTraveling:traveling];
	if (self) {
        craftDoesRotate = NO;
		droneArray = [[NSMutableArray alloc] initWithCapacity:SPIDER_NUMBER_OF_DRONES];
		droneCount = 0;
        droneBroggutCost = kCraftSpiderDroneCostBrogguts;
        droneBuildTime = kCraftSpiderDroneRebuildTime;
		droneCountLimit = SPIDER_NUMBER_OF_DRONES;
        droneBuildTimer = kCraftSpiderDroneRebuildTime;
        for (int i = 0; i < SPIDER_NUMBER_OF_DRONES; i++) {
            droneBayContainment[i] = NO;
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

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll withAlpha:(float)alpha {
    [super drawHoverSelectionWithScroll:scroll withAlpha:alpha];
    for (SpiderDroneObject* drone in droneArray) {
		[drone drawHoverSelectionWithScroll:scroll withAlpha:alpha];
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
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        droneBroggutCost = kCraftSpiderDroneCostBroggutsUpgraded;
        droneBuildTime = kCraftSpiderDroneRebuildTimeUpgraded;
    }
	
    if (droneBuildTimer <= 0) {
        droneBuildTimer = droneBuildTime;
        if (objectAlliance == kAllianceFriendly) {
            if (droneCount < droneCountLimit) {
                if ([[[GameController sharedGameController] currentProfile] subtractBrogguts:droneBroggutCost metal:kCraftSpiderDroneCostMetal] == kProfileNoFail) {
                    [self addNewDroneToBay];
                    [[self currentScene] addBroggutTextValue:-droneBroggutCost atLocation:objectLocation withAlliance:kAllianceFriendly];
                }
            }
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
