//
//  RefinerySmokeObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/27/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "RefinerySmokeObject.h"
#import "CollidableObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"

#define REFINERY_SMOKE_LIFE_MIN_TIME 2.0f
#define REFINERY_SMOKE_MAX_SPEED 0.1f
#define REFINERY_SMOKE_MAX_ALPHA 0.5f
#define REFINERY_SMOKE_MIN_ALPHA 0.2f

@implementation RefinerySmokeObject

- (id)initWithLocation:(CGPoint)location {
    Image* image = [[Image alloc] initWithImageNamed:@"particlesmoke.png" filter:GL_LINEAR];
    self = [super initWithImage:image withLocation:location withObjectType:kObjectRefinerySmokeObjectID];
    if (self) {
        isCheckedForCollisions = NO;
        isCheckedForMultipleCollisions = NO;
        isRenderedInOverview = NO;
        lifeTimer = REFINERY_SMOKE_LIFE_MIN_TIME + RANDOM_0_TO_1();
        rotationSpeed = RANDOM_MINUS_1_TO_1() * 0.02f;
        objectVelocity = Vector2fMake(RANDOM_MINUS_1_TO_1() * REFINERY_SMOKE_MAX_SPEED,
                                      RANDOM_MINUS_1_TO_1() * REFINERY_SMOKE_MAX_SPEED);
        [self setRenderLayer:kLayerTopLayer];
        [self setObjectRotation:RANDOM_0_TO_1() * 360.0f];
        maxAlpha = CLAMP(RANDOM_0_TO_1(), REFINERY_SMOKE_MIN_ALPHA, REFINERY_SMOKE_MAX_ALPHA);
    }
    [image release];
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if (lifeTimer > 0.0f) {
        lifeTimer -= aDelta;
        [self.objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(lifeTimer, 0.0f, maxAlpha))];
    } else {
        [self setDestroyNow:YES];
    }
}

@end
