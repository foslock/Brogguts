//
//  RatCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

@class RadarStructureObject;

@interface RatCraftObject : CraftObject {
    BOOL isCloaked;
    float cloakAlpha;
    RadarStructureObject* nearbyEnemyRadar;
}

@property (readonly) BOOL isCloaked;
@property (nonatomic, assign) float cloakAlpha;
@property (nonatomic, assign) RadarStructureObject* nearbyEnemyRadar;

- (void)setIsCloaked:(BOOL)isCloaked withRadar:(RadarStructureObject*)radar;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

@end
