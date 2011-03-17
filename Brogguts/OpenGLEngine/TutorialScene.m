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

NSString* kTutorialSceneFileNames[TUTORIAL_SCENES_COUNT] = {
    @"Tutorial 1",
    @"Tutorial 2",
    @"Tutorial 3",
    @"Tutorial 4",
    @"Tutorial 5",
    @"Tutorial 6",
    @"Tutorial 7",
    @"Tutorial 8",
    @"Tutorial 9",
    @"Tutorial 10",
    @"Tutorial 11",
};


@implementation TutorialScene

- (void)dealloc {
    [nextSceneName release];
    [super dealloc];
}

- (id)initWithTutorialIndex:(int)tutIndex {
    self = [super initWithFileName:kTutorialSceneFileNames[tutIndex]];
    if (self) {
        if (tutIndex >= TUTORIAL_SCENES_COUNT - 1) {
            nextSceneName = kBaseCampFileName;
        } else {
            nextSceneName = kTutorialSceneFileNames[tutIndex+1];
        }
        isTutorial = YES;
        tutorialIndex = tutIndex;
        isObjectiveComplete = NO;
        
        // Turn off the complicated stuff
        isShowingSidebar = NO;
        isShowingBroggutCount = NO;
        isShowingMetalCount = NO;
        isAllowingOverview = NO;
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            if (tutorialIndex < TUTORIAL_SCENES_COUNT - 1) {
                [[GameController sharedGameController] loadTutorialLevelsForIndex:tutorialIndex + 1];
            }
            [[GameController sharedGameController] transitionToSceneWithFileName:nextSceneName isTutorial:YES];
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
