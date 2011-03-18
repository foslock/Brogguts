//
//  TriggerObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

#define TRIGGER_PULSE_SPEED 0.01f // Speed at which the trigger will blink
#define TRIGGER_MAX_ALPHA 0.45f
#define TRIGGER_MIN_ALPHA 0.15f

@interface TriggerObject : CollidableObject {
    BOOL pulsingUp;
    BOOL pulsingDown;
    BOOL isComplete;
    float currentTriggerAlpha;
    int numberOfObjectsNeeded;
    int objectIDNeeded;
    NSMutableArray* nearbyObjects;
}

@property (nonatomic, assign) int numberOfObjectsNeeded;
@property (nonatomic, assign) int objectIDNeeded;
@property (readonly) BOOL isComplete;

- (id)initWithLocation:(CGPoint)location;

@end
