//
//  CraftUpgradesStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CraftUpgradesStructureObject.h"
#import "Image.h"
#import "BroggutScene.h"
#import "SideBarController.h"

@implementation CraftUpgradesStructureObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureCraftUpgradesID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
        isBeingPressed = NO;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    if (isBeingPressed) {
        [objectImage setColor:Color4fMake(0.8f, 0.8f, 0.8f, 1.0f)];
    } else {
        [objectImage setColor:Color4fMake(1.0f, 1.0f, 1.0f, 1.0f)];
    }
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    [super touchesBeganAtLocation:location];
    isBeingPressed = YES;
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    [super touchesEndedAtLocation:location];
    if (isBeingPressed && CircleContainsPoint([self touchableBounds], location)) {
        [[[self currentScene] sideBar] moveSideBarIn];
    }
    isBeingPressed = NO;
}

@end
