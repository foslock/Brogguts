//
//  BaseStationStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BaseStationStructureObject.h"
#import "AntCraftObject.h"

@implementation BaseStationStructureObject

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// For mining ships, turn in brogguts
	if (objectAlliance == kAllianceFriendly) {
		if ([other isKindOfClass:[AntCraftObject class]]) {
			AntCraftObject* otherCraft = (AntCraftObject*)other;
			[otherCraft cashInBrogguts];
		}
	}
}

@end
