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
#import "BroggutScene.h"
#import "CollisionManager.h"

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
        isRenderedInOverview = NO;
        isPaddedForCollisions = NO;
        isCheckedForCollisions = NO;
        pulsingUp = NO;
        pulsingDown = YES;
        isComplete = NO;
        currentTriggerAlpha = TRIGGER_MAX_ALPHA;
        numberOfObjectsNeeded = INT_MAX;
        objectIDNeeded = -1;
        nearbyObjects = [[NSMutableArray alloc] init];
        isCheckedForRadialEffect = YES;
        isTouchable = NO;
        attributeViewDistance = 512;
    }
    return self;
}

- (void)triggerIsComplete {
    if (!isComplete) {
        isComplete = YES;
        [self setDestroyNow:YES];
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
    effectRadius = ([objectImage imageSize].width / 2) * [objectImage scale].x;
    
    NSArray* queriedObjects = [[self.currentScene collisionManager] getArrayOfRadiiObjectsInCircle:[self boundingCircle]];
    int count = 0;
    for (TouchableObject* tobj in queriedObjects) {
        if (tobj.objectType == objectIDNeeded) {
            count++;
        }
    }
    if (count >= numberOfObjectsNeeded) {
        [self triggerIsComplete];
    }
}

@end
