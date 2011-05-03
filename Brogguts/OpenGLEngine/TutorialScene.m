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
#import "TextObject.h"

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
    [helpText release];
    [nextSceneName release];
    [super dealloc];
}

- (id)initWithTutorialIndex:(int)tutIndex {
    self = [super initWithFileName:kTutorialSceneFileNames[tutIndex]];
    if (self) {
        if (tutIndex >= TUTORIAL_SCENES_COUNT - 1) {
            nextSceneName = [[kBaseCampFileName stringByDeletingPathExtension] copy];
        } else {
            nextSceneName = kTutorialSceneFileNames[tutIndex+1];
        }
        sceneType = kSceneTypeTutorial;
        tutorialIndex = tutIndex;
        isObjectiveComplete = NO;
        helpTextRect = CGRectMake(visibleScreenBounds.size.width,
                                  (COLLISION_CELL_HEIGHT / 2),
                                  1, 1);
        helpText = [[TextObject alloc] initWithFontID:TUTORIAL_HELP_FONT
                                                 Text:@"" 
                                             withRect:helpTextRect
                                         withDuration:-1.0f];
        [helpText setScrollWithBounds:NO];
        [self addTextObject:helpText];
        
        // Turn off the complicated stuff
        isAllowingSidebar = NO;
        isShowingBroggutCount = NO;
        isShowingMetalCount = NO;
        isAllowingOverview = NO;
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (helpTextRect.origin.x > -[self getWidthForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]]) {
        helpTextRect = CGRectOffset(helpTextRect, -TUTORIAL_HELP_TEXT_SCROLL_SPEED, 0);
    } else {
        helpTextRect = CGRectMake(visibleScreenBounds.size.width,
                                  (COLLISION_CELL_HEIGHT / 2),
                                  1, 1);
    }
    [helpText setTextRect:helpTextRect];
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            if (tutorialIndex < TUTORIAL_SCENES_COUNT - 1) {
                [[GameController sharedGameController] loadTutorialLevelsForIndex:tutorialIndex + 1];
                [[GameController sharedGameController] transitionToSceneWithFileName:nextSceneName sceneType:kSceneTypeTutorial isNew:NO];
            } else {
                [[GameController sharedGameController] transitionToSceneWithFileName:nextSceneName sceneType:kSceneTypeBaseCamp isNew:NO];
            }
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
