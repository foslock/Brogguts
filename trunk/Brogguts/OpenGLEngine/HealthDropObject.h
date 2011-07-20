//
//  HealthDropObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 6/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

#define HEALTH_DROP_TOTAL_TIME 1.0f

@class TouchableObject;

@interface HealthDropObject : CollidableObject {
    float expandTimer;
    float circleRadius;
    int filledSegments;
    int unfilledSegments;
    TouchableObject* followingObject;
}

@property (retain) TouchableObject* followingObject;

- (id)initWithTouchableObject:(TouchableObject*)object;

@end
