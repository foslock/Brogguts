//
//  EagleCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "EagleCraftObject.h"
#import "UpgradeManager.h"
#import "BroggutScene.h"


@implementation EagleCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftEagleID withLocation:location isTraveling:traveling];
	if (self) {
        [self createTurretLocationsWithCount:1];
		healTimer = 60;
        isHealingSelf = NO;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        isHealingSelf = YES;
    }
    
    if (isHealingSelf) {
        if (healTimer > 0) {
            healTimer--;
        } else {
            healTimer = 60;
            [self repairCraft:kCraftEagleSelfRepairAmountPerSecond];
        }
    }
    
    
}

@end
