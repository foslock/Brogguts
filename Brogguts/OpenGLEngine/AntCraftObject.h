//
//  AntCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

@interface AntCraftObject : CraftObject {
	
	// Variable attributes that are specific to this craft
	int attributeMiningCooldown;		// Time it takes to mine 1 brogguts (in ms)
	
	// Mining varaibles
	int miningState;				// The state of the craft, enum vars are in implementation
    int miningCooldownTimer;        // The timer that decides the cooldown timer
	int miningBroggutID;			// The ID of the medium broggut that is currently being mined
	CGPoint miningLocation;			// The center of the broggut currently being mined
    float miningAIValue;            // Value that the AI values this miner
    
    float randomMiningValueX;        // Generated for mining animation
    float randomMiningValueY;        // Generated for mining animation
}

@property (readonly) CGPoint miningLocation;
@property (readonly) int miningState;
@property (nonatomic, assign) float miningAIValue;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

// If called, the craft will mine the broggut in the middle, but also check the adjacent brogguts if the middle is empty.
- (void)tryMiningBroggutsWithCenter:(CGPoint)location wasCommanded:(BOOL)commanded;
// Will either mine the broggut at the location or nothing.
- (BOOL)startMiningBroggutWithLocation:(CGPoint)location wasCommanded:(BOOL)commanded;

- (void)returnBroggutsHome;

@end
