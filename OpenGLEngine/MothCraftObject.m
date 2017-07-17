//
//  MothCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MothCraftObject.h"
#import "BroggutScene.h"
#import "UpgradeManager.h"

@implementation MothCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftMothID withLocation:location isTraveling:traveling];
	if (self) {
		[self createTurretLocationsWithCount:1];
	}
	return self;
}

- (BOOL)attackedByEnemy:(TouchableObject *)enemy withDamage:(int)damage {
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType] && objectAlliance == kAllianceFriendly) {
        // Evade a percent of the time!
        int rand = arc4random() % 100;
        if (rand < kCraftMothEvadePercentage) {
            return NO;
        }
        return [super attackedByEnemy:enemy withDamage:damage];
    } else {
        return [super attackedByEnemy:enemy withDamage:damage];
    }
}


@end
