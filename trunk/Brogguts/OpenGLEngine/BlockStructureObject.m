//
//  BlockStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BlockStructureObject.h"
#import "Image.h"
#import "Global.h"
#import "BroggutScene.h"
#import "UpgradeManager.h"

@implementation BlockStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureBlockID withLocation:location isTraveling:traveling];
	if (self) {
        hasBeenAdded = NO;
        hasBeenUpgraded = NO;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType] && objectAlliance == kAllianceFriendly) {
        attributeHullCapacity = kStructureBlockHullIncreaseUpgrade;
        if (!hasBeenUpgraded) {
            attributeHullCurrent += (kStructureBlockHullIncreaseUpgrade - kStructureBlockHull);
            hasBeenUpgraded = YES;
        }
    }
    
    if (!hasBeenAdded && !isTraveling) {
        hasBeenAdded = YES;
        [[self currentScene] addBlock:self];
    }
}

@end
