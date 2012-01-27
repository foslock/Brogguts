//
//  RatCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

@class StructureObject;

@interface RatCraftObject : CraftObject {
    BOOL isCloaked;
    float cloakAlpha;
    StructureObject* nearbyEnemyRadar;
}

@property (readonly) BOOL isCloaked;
@property (nonatomic, assign) float cloakAlpha;
@property (nonatomic, assign) StructureObject* nearbyEnemyRadar;

- (void)setIsCloaked:(BOOL)isCloaked withRadar:(StructureObject*)radar;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

@end
