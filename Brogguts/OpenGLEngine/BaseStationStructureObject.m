//
//  BaseStationStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BaseStationStructureObject.h"
#import "CraftAndStructures.h"

@implementation BaseStationStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureBaseStationID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
		isTouchable = NO;
	}
	return self;
}

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// For mining ships, turn in brogguts
	if (objectAlliance == kAllianceFriendly) {
		if ([other isKindOfClass:[CraftObject class]]) {
			CraftObject* otherCraft = (CraftObject*)other;
			[otherCraft cashInBrogguts];
		}
	} else if (objectAlliance == kAllianceEnemy) {
        if ([other isKindOfClass:[CraftObject class]]) {
			CraftObject* otherCraft = (CraftObject*)other;
			[otherCraft cashInBrogguts];
		}
    }
}

@end