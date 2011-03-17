//
//  TriggerObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "Image.h"
#import "Global.h"

@implementation TriggerObject
@synthesize isComplete;
@synthesize numberOfObjectsNeeded, objectIDNeeded;

- (void)dealloc {
    [nearbyObjects release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location {
    Image* image = [[Image alloc] initWithImageNamed:kObjectTriggerSprite filter:GL_LINEAR];
    self = [super initWithImage:image withLocation:location withObjectType:kObjectTriggerID];
    [image release];
    if (self) {
        isPaddedForCollisions = NO;
        pulsingUp = NO;
        pulsingDown = YES;
        isComplete = NO;
        currentTriggerAlpha = TRIGGER_MAX_ALPHA;
        numberOfObjectsNeeded = INT_MAX;
        objectIDNeeded = -1;
        nearbyObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)triggerIsComplete {
    if (!isComplete) {
        isComplete = YES;
        [self setDestroyNow:YES];
    }
}

- (void)collidedWithOtherObject:(CollidableObject *)other {
    if (other.objectType == objectIDNeeded) {
        if (![nearbyObjects containsObject:other]) {
            [nearbyObjects addObject:other];
        }
        // If the other object is what you want, complete it!
        if ([nearbyObjects count] >= numberOfObjectsNeeded) {
            int count = 0;
            for (int i = 0; i < [nearbyObjects count]; i++) {
                CollidableObject* obj = [nearbyObjects objectAtIndex:i];
                if (obj.objectType == objectIDNeeded) {
                    if (GetDistanceBetweenPointsSquared(objectLocation, obj.objectLocation) <= POW2(self.boundingCircle.radius))
                        count++;
                }
            }
            if (count >= numberOfObjectsNeeded) {
                [self triggerIsComplete];
                return;
            }
        }
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (pulsingUp) {
        currentTriggerAlpha += TRIGGER_PULSE_SPEED;
        if (currentTriggerAlpha >= TRIGGER_MAX_ALPHA) {
            currentTriggerAlpha = TRIGGER_MAX_ALPHA;
            pulsingUp = NO;
            pulsingDown = YES;
        }
    } else if (pulsingDown) {
        currentTriggerAlpha -= TRIGGER_PULSE_SPEED;
        if (currentTriggerAlpha <= TRIGGER_MIN_ALPHA) {
            currentTriggerAlpha = TRIGGER_MIN_ALPHA;
            pulsingDown = NO;
            pulsingUp = YES;
        }
    }
    currentTriggerAlpha = CLAMP(currentTriggerAlpha, TRIGGER_MIN_ALPHA, TRIGGER_MAX_ALPHA);
    [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, currentTriggerAlpha)];
}

@end
