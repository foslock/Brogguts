//
//  RatCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameplayConstants.h"
#import "RatCraftObject.h"
#import "Image.h"
#import "UpgradeManager.h"
#import "BroggutScene.h"
#import "RadarStructureObject.h"

@implementation RatCraftObject
@synthesize isCloaked, cloakAlpha, nearbyEnemyRadar;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftRatID withLocation:location isTraveling:traveling];
	if (self) {
        [self createTurretLocationsWithCount:1];
		isCloaked = YES;
        cloakAlpha = 0.0f;
        nearbyEnemyRadar = nil;
	}
	return self;
}

- (void)setIsCloaked:(BOOL)cloaked withRadar:(RadarStructureObject *)radar {
    isCloaked = cloaked;
    nearbyEnemyRadar = radar;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if (nearbyEnemyRadar || nearbyEnemyRadar.destroyNow) {
        if (GetDistanceBetweenPointsSquared(nearbyEnemyRadar.objectLocation, objectLocation) > POW2([nearbyEnemyRadar effectRadiusCircle].radius)) {
            nearbyEnemyRadar = nil;
            isCloaked = YES;
        } else {
            isCloaked = NO;
        }
    } else {
        nearbyEnemyRadar = nil;
        isCloaked = YES;
    }
    
    // Check for upgrade
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        attributeViewDistance = kCraftRatViewDistanceUpgraded;
    }
    
    if (isCloaked && cloakAlpha > 0.0f) {
        cloakAlpha -= aDelta;
    }
    if (!isCloaked && cloakAlpha <= 1.0f) {
        cloakAlpha += aDelta;
    }
    if (objectAlliance == kAllianceEnemy) {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(cloakAlpha, 0.1f, 1.0f))];
    } else if (objectAlliance == kAllianceFriendly) {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(cloakAlpha, 0.5f, 1.0f))];
    }
}

@end
