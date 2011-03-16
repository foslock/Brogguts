//
//  TutorialScene.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialScene.h"
#import "GameController.h"
#import "TriggerObject.h"

@implementation TutorialScene

- (void)dealloc {
    [nextSceneName release];
    [super dealloc];
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString *)sName withNextScene:(NSString*)nextName {
    self = [super initWithScreenBounds:screenBounds withFullMapBounds:mapBounds withName:sName];
    if (self) {
        nextSceneName = [nextName copy];
        isObjectiveComplete = NO;
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            [[GameController sharedGameController] transitionToSceneWithFileName:nextSceneName];
            return;
        }
    }
    [super updateSceneWithDelta:aDelta];
}

- (BOOL)checkObjective {
    // OVERRIDE, return YES if the objective is complete, and the level should transition.
    return NO;
}

@end
