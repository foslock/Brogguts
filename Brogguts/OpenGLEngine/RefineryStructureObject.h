//
//  RefineryStructureObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

@class AnimatedImage;

@interface RefineryStructureObject : StructureObject {
    AnimatedImage* animatedImage;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;


@end
