//
//  RatCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "RatCraftObject.h"
#import "Image.h"

@implementation RatCraftObject
@synthesize isCloaked, cloakAlpha;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftRatID withLocation:location isTraveling:traveling];
	if (self) {
		isCloaked = YES;
        cloakAlpha = 0.0f;
	}
	return self;
}

- (void)setIsCloaked:(BOOL)cloaked {
    isCloaked = cloaked;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (isCloaked && cloakAlpha > 0.0f) {
        cloakAlpha -= aDelta;
    }
    if (!isCloaked && cloakAlpha <= 1.0f) {
        cloakAlpha += aDelta;
    }
    if (objectAlliance == kAllianceEnemy) {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(cloakAlpha, 0.1f, 1.0f))];
    } else if (objectAlliance == kAllianceFriendly) {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(cloakAlpha, 0.5f, 1.0f))];
    }
}

@end
