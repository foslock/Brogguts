//
//  TutorialSceneOne.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneOne.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"

@implementation TutorialSceneOne

- (id)init {
    CGRect screenBounds = CGRectMake(0, 0, kPadScreenLandscapeHeight, kPadScreenLandscapeWidth);
    CGRect mapBounds = CGRectMake(0, 0, kPadScreenLandscapeHeight, kPadScreenLandscapeWidth);
    self = [super initWithScreenBounds:screenBounds withFullMapBounds:mapBounds withName:@"Tutorial 1" withNextScene:@"Tutorial 2"];
    if (self) {
        antTrigger = nil;
    }
    return self;
}

- (BOOL)checkObjective {
    
    return NO;
}

@end
