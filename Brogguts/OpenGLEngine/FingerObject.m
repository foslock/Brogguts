//
//  FingerObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "FingerObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"

@implementation FingerObject
@synthesize doesScrollWithScreen, startLocation, endLocation;

- (void)dealloc {
    [touchImage release];
    [super dealloc];
}

- (id)initWithStartLocation:(CGPoint)startLoc withEndLocation:(CGPoint)endLoc repeats:(BOOL)repeats {
    Image* image = [[Image alloc] initWithImageNamed:@"spritefinger.png" filter:GL_LINEAR];
    self = [super initWithImage:image withLocation:startLoc withObjectType:kObjectFingerObjectID];
    [image release];
    if (self) {
        isRenderedInOverview = NO;
        touchImage = [[Image alloc] initWithImageNamed:@"spritetouch.png" filter:GL_LINEAR];
        touchImage.color = Color4fMake(1.0f, 1.0f, 1.0f, 0.5f);
        [touchImage setRenderLayer:kLayerHUDBottomLayer];
        [self setRenderLayer:kLayerHUDMiddleLayer];
        startLocation = startLoc;
        endLocation = endLoc;
        objectImage.scale = Scale2fMake(2.0f, 2.0f);
        doesScrollWithScreen = YES;
        fingerMovementTimer = FINGER_PRESS_RELEASE_FRAMES;
        isPressingDown = YES;
        isReleasingUp = NO;
        isMovingAcross = NO;
        repeatsMovement = repeats;
        startObject = nil;
        endObject = nil;
    }
    return self;
}

- (void)attachStartObject:(CollidableObject*)object {
    startObject = object;
}
- (void)attachEndObject:(CollidableObject*)object {
    endObject = object;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    if (fingerMovementTimer > 0) {
        if (isPressingDown) {
            float scale = (fingerMovementTimer + FINGER_PRESS_RELEASE_FRAMES) / (float)FINGER_PRESS_RELEASE_FRAMES;
            objectImage.scale = Scale2fMake(scale, scale);
            float alpha = 1.0f - ( (fingerMovementTimer) / (float)FINGER_PRESS_RELEASE_FRAMES );
            objectImage.color = Color4fMake(1.0f, 1.0f, 1.0f, alpha);
        } else if (isMovingAcross) {
            float dx = (endLocation.x - startLocation.x) / (float)FINGER_MOVEMENT_FRAMES;
            float dy = (endLocation.y - startLocation.y) / (float)FINGER_MOVEMENT_FRAMES;
            [self setObjectLocation:CGPointMake(objectLocation.x + dx, objectLocation.y + dy)];
            objectImage.scale = Scale2fMake(1.0f, 1.0f);
        } else if (isReleasingUp) {
            float scale = 2.0f - ( (fingerMovementTimer) / (float)FINGER_PRESS_RELEASE_FRAMES );
            objectImage.scale = Scale2fMake(scale, scale);
            float alpha = ( (fingerMovementTimer) / (float)FINGER_PRESS_RELEASE_FRAMES );
            objectImage.color = Color4fMake(1.0f, 1.0f, 1.0f, alpha);
        }
        fingerMovementTimer--;
    } else if (fingerMovementTimer <= 0) {
        if (isPressingDown) {
            isPressingDown = NO;
            isMovingAcross = YES;
            fingerMovementTimer = FINGER_MOVEMENT_FRAMES;
            if (endObject) {
                endLocation = endObject.objectLocation;
            }
        } else if (isMovingAcross) {
            isMovingAcross = NO;
            isReleasingUp = YES;
            fingerMovementTimer = FINGER_PRESS_RELEASE_FRAMES;
        } else if (isReleasingUp) {
            isReleasingUp = NO;
            if (repeatsMovement) {
                isPressingDown = YES;
                if (startObject) {
                    startLocation = startObject.objectLocation;
                }
                [self setObjectLocation:startLocation];
                fingerMovementTimer = FINGER_PRESS_RELEASE_FRAMES;
            } else {
                [self setDestroyNow:YES];
            }
        }
    }
    [super updateObjectLogicWithDelta:aDelta];
}

- (BOOL)isOnScreen {
    return YES;
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    if (isHidden) {
        return;
    }
    if (doesScrollWithScreen) {
        if (isMovingAcross)
            [touchImage renderCenteredAtPoint:aPoint withScrollVector:vector];
        if (objectImage) 
            [objectImage renderCenteredAtPoint:aPoint withScrollVector:vector];
    } else {
        if (isMovingAcross)
            [touchImage renderCenteredAtPoint:aPoint];
        if (objectImage) {
            [objectImage renderCenteredAtPoint:aPoint];
        }
    }
}

@end
