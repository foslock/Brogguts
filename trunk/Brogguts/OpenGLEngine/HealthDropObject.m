//
//  HealthDropObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 6/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "HealthDropObject.h"
#import "TouchableObject.h"
#import "CraftObject.h"
#import "StructureObject.h"
#import "GameController.h"

@implementation HealthDropObject
@synthesize followingObject;

- (void)dealloc {
    [followingObject release];
    [super dealloc];
}

- (id)initWithTouchableObject:(TouchableObject*)object {
    self = [super initWithImage:nil withLocation:object.objectLocation withObjectType:kObjectHealthDropObjectID];
    if (self) {
        isCheckedForCollisions = NO;
        isRenderedInOverview = NO;
        if ([object isKindOfClass:[CraftObject class]]) {
            unfilledSegments = [(CraftObject*)object attributeHullCapacity] / CRAFT_HEALTH_PER_NOTCH;
            filledSegments = [(CraftObject*)object attributeHullCurrent] / CRAFT_HEALTH_PER_NOTCH;
        }
        
        if ([object isKindOfClass:[StructureObject class]]) {
            unfilledSegments = [(StructureObject*)object attributeHullCapacity] / STRUCTURE_HEALTH_PER_NOTCH;
            filledSegments = [(StructureObject*)object attributeHullCurrent] / STRUCTURE_HEALTH_PER_NOTCH;
        }
        
        self.followingObject = object;
        circleRadius = [object boundingCircle].radius + 4.0f;
        
        expandTimer = HEALTH_DROP_TOTAL_TIME;
        self.objectAlliance = followingObject.objectAlliance;
    }
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    circleRadius += 0.1f;
    expandTimer -= aDelta;
    if (expandTimer <= 0.0f) {
        [self setDestroyNow:YES];
    }
    objectLocation = followingObject.objectLocation;
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    enablePrimitiveDraw();
    Circle newCircle;
    newCircle.x = objectLocation.x;
    newCircle.y = objectLocation.y;
    newCircle.radius = circleRadius;
    glLineWidth(3.0f);
    float alpha = CLAMP(expandTimer * 2.0f, 0.0f, 1.0f);
    if (![followingObject destroyNow]) {
        if (objectAlliance == kAllianceFriendly) {
            drawDashedCircleWithColoredSegment(newCircle, filledSegments, unfilledSegments, [GameController getColorFriendly:alpha], Color4fMake(0.1f, 0.1f, 0.1f, 0.0f), scroll);
        } else if (objectAlliance == kAllianceEnemy) {
            drawDashedCircleWithColoredSegment(newCircle, filledSegments, unfilledSegments, [GameController getColorEnemy:alpha], Color4fMake(0.1f, 0.1f, 0.1f, 0.0f), scroll);
        }
    }
    glLineWidth(1.0f);
    disablePrimitiveDraw();
}

@end
