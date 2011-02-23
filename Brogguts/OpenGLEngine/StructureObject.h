//
//  StructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

@interface StructureObject : TouchableObject {
	
	// AI states
	int friendlyAIState;
	
	// Closest enemy object, within range
	TouchableObject* closestEnemyObject;
	
	// Variable attributes that all structure must implement
	int attributeBroggutCost;
	int attributeMetalCost;
	int attributeHullCapacity;
	int attributeHullCurrent;
	int attributeMovingTime;
}

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)updateObjectTargets;


@end
