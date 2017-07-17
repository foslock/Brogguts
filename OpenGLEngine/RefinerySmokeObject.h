//
//  RefinerySmokeObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/27/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "CollidableObject.h"

@interface RefinerySmokeObject : CollidableObject {
    float lifeTimer;
    float maxAlpha;
}

- (id)initWithLocation:(CGPoint)location;

@end
