//
//  BuildingObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

#define BUILDING_OBJECT_MAX_ALPHA 0.4f
#define BUILDING_FADING_RADIUS 200.0f

@class TouchableObject;

@interface BuildingObject : CollidableObject {
    TouchableObject* creatingObject;
    int creatingCraftID;
    float currentAlpha;
}

@property (retain) TouchableObject* creatingObject;

- (id)initWithObject:(TouchableObject*)object withLocation:(CGPoint)location;

@end
