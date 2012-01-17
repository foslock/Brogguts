//
//  MissileObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/15/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"

#define MISSILE_ACCELERATION_RATE 0.01f
#define MISSILE_DETONATION_DISTANCE 64.0f
#define MISSILE_MAX_SPEED 8.0f

@class TouchableObject;

@interface MissileObject : CollidableObject {
    TouchableObject* ownerObject;
    TouchableObject* targetObject;
    CGPoint detonationLocation;
    int missileDamage;
}

- (id)initWithOwner:(TouchableObject*)owner withTarget:(TouchableObject*)target;

@end
