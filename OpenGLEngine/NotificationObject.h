//
//  NotificationObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"


@interface NotificationObject : CollidableObject {
    float notificationDuration;
    float notificationTimer;
    CGPoint notificationLocation;
    CollidableObject* objectAttachedTo;
}

@property (readonly) CGPoint notificationLocation;

- (id)initWithLocation:(CGPoint)location withDuration:(float)duration;
- (void)attachToObject:(CollidableObject*)object;

@end
