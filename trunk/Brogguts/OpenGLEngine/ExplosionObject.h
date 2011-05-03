//
//  ExplosionObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

enum kExplosionSizes {
    kExplosionSizeSmall,
    kExplosionSizeMedium,
    kExplosionSizeLarge,
};

@class AnimatedImage;

@interface ExplosionObject : CollidableObject {
    AnimatedImage* animatedImage;
}

- (id)initWithLocation:(CGPoint)location withSize:(int)size;


@end
