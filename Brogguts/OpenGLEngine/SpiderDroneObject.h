//
//  SpiderDroneObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

enum DroneAIStates {
	kDroneAIStateHidden,
	kDroneAIStateApproaching,
	kDroneAIStateReturning,
};

@class SpiderCraftObject;

@interface SpiderDroneObject : CraftObject {
	SpiderCraftObject* mySpiderCraft;	// The spider craft that controls this drone
	Vector2f droneBayLocation;			// The vector relative to the spider CRAFT that the drone should return to
    int droneIndex;                     // Index drone of the spider craft
	int droneAIState;					// The AI state the the drone is currently in
}

@property (nonatomic, assign) int droneIndex;
@property (nonatomic, assign) SpiderCraftObject* mySpiderCraft;
@property (nonatomic, assign) Vector2f droneBayLocation;
@property (nonatomic, assign) int droneAIState;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;


@end
