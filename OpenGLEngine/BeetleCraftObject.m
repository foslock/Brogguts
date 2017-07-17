//
//  BeetleCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BeetleCraftObject.h"
#import "UpgradeManager.h"
#import "BroggutScene.h"
#import "MissileObject.h"
#import "SoundSingleton.h"

@implementation BeetleCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftBeetleID withLocation:location isTraveling:traveling];
	if (self) {
		[self createTurretLocationsWithCount:1];
        hasUpgraded = NO;
	}
	return self;
}

- (void)attackTarget {
    if (![[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        [super attackTarget];
    } else {
        // Upgraded! Shoots missiles!
        [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileMissileFire]];
        MissileObject* missile = [[MissileObject alloc] initWithOwner:self withTarget:closestEnemyObject];
        [[self currentScene] addCollidableObject:missile];
        [missile release];
        attackCooldownTimer = attributeAttackCooldown * 2;
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType] && objectAlliance == kAllianceFriendly) {
        attributeAttackRange = kCraftBeetleMissileRange;
        if (!hasUpgraded) {
            hasUpgraded = YES;
            [self createTurretLocationsWithCount:0];
        }
    }
    [super updateObjectLogicWithDelta:aDelta];
}

@end
