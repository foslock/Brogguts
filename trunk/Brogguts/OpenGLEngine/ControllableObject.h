//
//  ControllableObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

@interface ControllableObject : TouchableObject {
	BOOL isBeingControlled;
	BOOL isBeingDragged;
	float rotationAcceleration;
	float maxVelocity;
	CGPoint dragLocation;
}

@property (nonatomic, assign) float maxVelocity;
@property (nonatomic, assign) BOOL isBeingControlled;

- (id)initWithImage:(Image*)image withLocation:(CGPoint)location withObjectType:(int)objecttype;

- (void)rotateTowardsAngle:(float)angle;
- (void)accelerateTowardsLocation:(CGPoint)location withMaxVelocity:(float)otherMaxVelocity;
- (void)decelerate;


@end
