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

@implementation MonarchCraftObject

- (void)dealloc {
    [craftUnderAura release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftMonarchID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
        effectRadius = kCraftMonarchAuraRangeLimit;
        craftUnderAura = [[NSMutableArray alloc] initWithCapacity:kCraftMonarchAuraNumberLimit];
	}
	return self;
}

- (void)objectEnteredEffectRadius:(TouchableObject *)other {
    [super objectEnteredEffectRadius:other];
    if ([other isKindOfClass:[CraftObject class]]) {
        CraftObject* craft = (CraftObject*)other;
        if (craft.objectType != kObjectCraftMonarchID) {
            if ([craftUnderAura count] < kCraftMonarchAuraNumberLimit) {
                if (![craftUnderAura containsObject:craft] && ![craft isUnderAura]) {
                    [craft setIsUnderAura:YES];
                    [craftUnderAura addObject:craft];
                }
            }
        }
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    for (int i = 0; i < [craftUnderAura count]; i++) {
        CraftObject* craft = [craftUnderAura objectAtIndex:i];
        if (GetDistanceBetweenPointsSquared(objectLocation, craft.objectLocation) > POW2(effectRadius)) {
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
