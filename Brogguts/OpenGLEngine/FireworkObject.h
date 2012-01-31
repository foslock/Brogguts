//
//  FireworkObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/29/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"

@interface FireworkObject : CollidableObject {
    float fireworkDuration;
    float fireworkTimer;
    float movingDirection;
    float movingSpeed;
    int subCount;
}

@property (nonatomic, assign) float movingDirection;

// Created at 'point' with 'count' sub fireworks that will take 'duration' seconds to explode. It moves at 'speed' speed
- (id)initWithLocation:(CGPoint)point withSubCount:(int)count withDuration:(float)duration withSpeed:(float)speed;

- (void)explodeFirework;

@end
