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
    BOOL hasBeenAdded;
    BOOL isRefining;
    int refiningTimer;
    int refiningCounter;
}

@property (nonatomic, assign) BOOL isRefining;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;
- (void)addRefiningCount:(int)counter;

@end
