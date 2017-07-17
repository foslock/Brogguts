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
#define REPAIR_LASER_FRAMES 40
#define REPAIR_LASER_WIDTH 8.0f

@interface FixerStructureObject : StructureObject {
	// Reparing vars
	int repairCountdownTimer;
    int laserCountdownTimer[REPAIR_MAX_CRAFT_COUNT];
	BOOL isRepairingCraft;
	NSMutableArray* closeFriendlyCraft;
	int currentRepairCount;
	
	int attributeRepairAmount;
	int attributeRepairMaxCount;
	int attributeRepairRange;
    int attributeRepairCooldown;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

@end
