//
//  MonarchCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MonarchCraftObject.h"
#import "Image.h"
#import "BroggutScene.h"
#import "UpgradeManager.h"
#import "GameController.h"
#import "CollisionManager.h"

@implementation MonarchCraftObject

+ (int)protectionAmount {
    BroggutScene* scene = [[GameController sharedGameController] currentScene];
    if ([[scene upgradeManager] isUpgradeCompleteWithID:kObjectCraftMonarchID]) {
        return kCraftMonarchAuraResistanceValueUpgraded;
    } else {
        return kCraftMonarchAuraResistanceValue;
    }
}

- (void)dealloc {
    [craftUnderAura release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftMonarchID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
        effectRadius = kCraftMonarchAuraRangeLimit;
        craftLimit = kCraftMonarchAuraNumberLimit;
        craftUnderAura = [[NSMutableArray alloc] initWithCapacity:craftLimit];
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    // Check for upgrade
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        craftLimit = kCraftMonarchAuraNumberLimitUpgraded;
    }
    
    Circle circle;
    circle.x = objectLocation.x;
    circle.y = objectLocation.y;
    circle.radius = kCraftMonarchAuraRangeLimit;
    NSArray* nearArray = [[[self currentScene] collisionManager] getArrayOfRadiiObjectsInCircle:circle];
    
    for (CraftObject* craft in nearArray) {
        if (craft.objectType != kObjectCraftMonarchID && 
            craft.objectType != kObjectCraftSpiderDroneID &&
            craft.objectAlliance == objectAlliance) {
            if ([craftUnderAura count] < craftLimit) {
                if (![craftUnderAura containsObject:craft] && ![craft isUnderAura]) {
                    [craft setIsUnderAura:YES];
                    [craftUnderAura addObject:craft];
                }
            }
        }
    }
    
    for (int i = 0; i < [craftUnderAura count]; i++) {
        CraftObject* craft = [craftUnderAura objectAtIndex:i];
        if (GetDistanceBetweenPointsSquared(objectLocation, craft.objectLocation) > POW2(kCraftMonarchAuraRangeLimit)) {
            [craftUnderAura removeObject:craft];
            [craft setIsUnderAura:NO];
        }
    }
}

- (void)objectWasDestroyed {
    [super objectWasDestroyed];
    for (CraftObject* craft in craftUnderAura) {
        [craft setIsUnderAura:NO];
    }
    [craftUnderAura removeAllObjects];
}



@end
