//
//  FingerObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"
#import "Global.h"

#define FINGER_MOVEMENT_FRAMES 100
#define FINGER_PRESS_RELEASE_FRAMES 75

@class Image;

@interface FingerObject : CollidableObject {
    CGPoint startLocation;
    CGPoint endLocation;
    BOOL repeatsMovement;
    int fingerMovementTimer;
    BOOL isPressingDown;
    BOOL isReleasingUp;
    BOOL isMovingAcross;
    BOOL doesScrollWithScreen;
    Image* touchImage;
    CollidableObject* startObject;
    CollidableObject* endObject;
}

@property (nonatomic, assign) BOOL doesScrollWithScreen;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint endLocation;

- (id)initWithStartLocation:(CGPoint)startLoc withEndLocation:(CGPoint)endLoc repeats:(BOOL)repeats;
- (void)attachStartObject:(CollidableObject*)object;
- (void)attachEndObject:(CollidableObject*)object;

@end
