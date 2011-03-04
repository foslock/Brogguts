//
//  SpiderCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"
#import "SpiderDroneObject.h"

#define SPIDER_NUMBER_OF_DRONES 8

@interface SpiderCraftObject : CraftObject {
	NSMutableArray* droneArray;		// Array of spider drones for this ship
	int droneCount;					// Current number of drone owned by this ship
	int droneCountLimit;			// Limit to the number of drones this ship can hold
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)addNewDroneToBay;
- (void)removeDrone:(SpiderDroneObject*)drone;

@end
