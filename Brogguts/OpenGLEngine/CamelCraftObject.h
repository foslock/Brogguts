//
//  CamelCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

@interface CamelCraftObject : CraftObject {
	
	// Variable attributes that are specific to this craft
	int attributeMiningSpeed;		// Time it takes to mine 1 brogguts (in ms)
	int attributeCargoCapacity;		// Amount of brogguts this craft can hold
	int attributeCurrentCargo;		// Amount the cargo currently holds
	
	// Mining varaibles
	int miningState;				// The state of the craft, enum vars are in implementation
	int miningBroggutID;			// The ID of the medium broggut that is currently being mined
	CGPoint miningLocation;			// The center of the broggut currently being mined
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

// If called, the craft will mine the broggut in the middle, but also check the adjacent brogguts if the middle is empty.
- (void)tryMiningBroggutsWithCenter:(CGPoint)location;
// Will either mine the broggut at the location or nothing.
- (BOOL)startMiningBroggutWithLocation:(CGPoint)location;

@end
