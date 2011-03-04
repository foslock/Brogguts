//
//  FixerStructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

#define REPAIR_MAX_CRAFT_COUNT 4

@interface FixerStructureObject : StructureObject {
	// Reparing vars
	int repairCountdownTimer;
	BOOL isRepairingCraft;
	NSMutableArray* closeFriendlyCraft;
	NSMutableArray* repairingCraft;
	
	int attributeRepairAmount;
	int attributeRepairMaxCount;
	int attributeRepairRange;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

@end
