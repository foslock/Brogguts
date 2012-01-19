//
//  NotificationObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "NotificationObject.h"
#import "BroggutScene.h"
#import "CraftAndStructures.h"
#import "Image.h"
#import "Global.h"
#import "ImageRenderSingleton.h"

@implementation NotificationObject
@synthesize notificationLocation;


- (id)initWithLocation:(CGPoint)location withDuration:(float)duration {
    Image* image = [[Image alloc] initWithImageNamed:@"spritenotificationarrow.png" filter:GL_LINEAR];
    self = [super initWithImage:image withLocation:location withObjectType:kObjectNotificationID];
    [image release];
    if (self) {
        isCheckedForCollisions = NO;
        notificationLocation = location;
        isRenderedInOverview = NO;
        notificationDuration = duration;
        notificationTimer = duration;
        objectAttachedTo = nil;
        objectImage.color = Color4fMake(1.0f, 1.0f, 1.0f, 0.75f);
        [objectImage setRenderLayer:kLayerHUDBottomLayer];
    }
    return self;
}

- (void)attachToObject:(CollidableObject *)object {
    objectAttachedTo = object;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {    
    [super updateObjectLogicWithDelta:aDelta];
    
    if (notificationDuration != -1.0f) {
        if (notificationTimer > 0.0f) {
            notificationTimer -= aDelta;
            if (notificationTimer < 0.75f) {
                Color4f color = [objectImage color];
                [objectImage setColor:Color4fMake(color.red, color.green, color.blue, notificationTimer)];
            }
        } else if (notificationTimer <= 0.0f) {
            [self setDestroyNow:YES];
        }
    }
    
    if (objectAttachedTo) {
        notificationLocation = objectAttachedTo.objectLocation;
    }
    
    CGRect visibleBounds = [[self currentScene] visibleScreenBounds];
    float xLowLimit = visibleBounds.origin.x + objectImage.imageSize.width;
    float yLowLimit = visibleBounds.origin.y + objectImage.imageSize.height;
    float xHighLimit = visibleBounds.origin.x + visibleBounds.size.width - objectImage.imageSize.width;
    float yHighLimit = visibleBounds.origin.y + visibleBounds.size.height - objectImage.imageSize.height;
    
    float xPos = CLAMP(notificationLocation.x, xLowLimit, xHighLimit);
    float yPos = CLAMP(notificationLocation.y, yLowLimit, yHighLimit);
    self.objectLocation = CGPointMake(xPos, yPos);
    
    float radDir = atan2f(notificationLocation.y - yPos, notificationLocation.x - xPos);
    self.objectRotation = RADIANS_TO_DEGREES(radDir);
    
    if (CGRectContainsPoint(visibleBounds, notificationLocation)) {
        isHidden = YES;
    } else {
        isHidden = NO;
    }
}

@end
