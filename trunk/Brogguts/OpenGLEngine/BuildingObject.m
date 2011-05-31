//
//  BuildingObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BuildingObject.h"
#import "TouchableObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "CraftObject.h"

@implementation BuildingObject

- (id)initWithObject:(TouchableObject*)object withLocation:(CGPoint)location {
    NSString* filename = [[object objectImage] imageFileName];
    Image* newImage = [[Image alloc] initWithImageNamed:filename filter:GL_LINEAR];
    self = [super initWithImage:newImage withLocation:location withObjectType:kObjectBuildingObjectID];
    if (self) {
        isCheckedForCollisions = NO;
        [objectImage setScale:[object objectImage].scale];
        if ([object isKindOfClass:[CraftObject class]]) {
            [self setObjectRotation:GetAngleInDegreesFromPoints(object.objectLocation, location)];
        }
        creatingObject = object;
        creatingCraftID = object.uniqueObjectID;
        currentAlpha = BUILDING_OBJECT_MAX_ALPHA;
        [objectImage setRenderLayer:kLayerBottomLayer];
    }
    [newImage release];
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    float distanceSquared = GetDistanceBetweenPointsSquared(objectLocation, creatingObject.objectLocation);
    if (distanceSquared < POW2(BUILDING_FADING_RADIUS)) {
        currentAlpha = CLAMP(distanceSquared / POW2(BUILDING_FADING_RADIUS), 0, BUILDING_OBJECT_MAX_ALPHA);
    }
    if (currentAlpha < 0.01f || distanceSquared < 4.0f) {
        destroyNow = YES;
    }
    [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, currentAlpha)];
}

@end
