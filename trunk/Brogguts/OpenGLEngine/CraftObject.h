//
//  CraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControllableObject.h"

@interface CraftObject : ControllableObject {
	// Path variables
	NSMutableArray* pathPointArray;		// Array containing the points that this craft should follow
	int pathPointNumber;				// Which index of the path array we should be accelerating towards
	BOOL isFollowingPath;				// True if the craft should follow its current path (if any)
	BOOL isPathLooped;					// Should the unit repeat the path when finished
	BOOL hasCurrentPathFinished;		// True if the previous given path is done
	
	// AI states
	int friendlyAIState;
	
	// Closest enemy object, within range
	TouchableObject* closestEnemyObject;
	
	// Variable attributes that all craft must implement
	int attributeBroggutCost;
	int attributeMetalCost;
	int attributeEngines;
	int attributeWeapons;
	int attributeAttackRange;
	int attributeAttackRate;
	int attributeHullCapacity;
	int attributeHullCurrent;
	
	// Player cargo capacity
	int attributePlayerCurrentCargo;
	int attributePlayerCargoCapacity;
}

@property (readonly) int attributePlayerCargoCapacity;

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)addCargo:(int)cargo;
- (void)updateObjectTargets;

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped;
- (void)stopFollowingCurrentPath;
- (void)resumeFollowingCurrentPath;

@end
