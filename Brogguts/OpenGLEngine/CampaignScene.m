//
//  CampaignScene.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/22/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignScene.h"
#import "GameController.h"
#import "TriggerObject.h"
#import "TextObject.h"
#import "EndMissionObject.h"

NSString* kCampaignSceneFileNames[CAMPAIGN_SCENES_COUNT + 1] = {
    @"Campaign 1",
    @"Campaign 2",
    @"Campaign 3",
    @"Campaign 4",
    @"Campaign 5",
    @"Campaign 6",
    @"Campaign 7",
    @"Campaign 8",
    @"Campaign 9",
    @"Campaign 10",
    @"Campaign 11",
    @"Campaign 12",
    @"Campaign 13",
    @"Campaign 14",
    @"Campaign 15",
    @"Credits",
};

@implementation CampaignScene

- (id)initWithCampaignIndex:(int)campIndex wasLoaded:(BOOL)loaded {
    self = [super initWithFileName:kCampaignSceneFileNames[campIndex] wasLoaded:loaded];
    if (self) {
        nextSceneName = kCampaignSceneFileNames[campIndex+1];
        
        sceneType = kSceneTypeCampaign;
        campaignIndex = campIndex;
        isObjectiveComplete = NO;
        isAdvancingOrReset = NO;
        
        // Turn off the complicated stuff
        isAllowingSidebar = YES;
        isShowingBroggutCount = YES;
        isShowingMetalCount = YES;
        isAllowingOverview = YES;
        
        [self setCameraLocation:homeBaseLocation];
        [self setMiddleOfVisibleScreenToCamera];
    }
    return self;
}

- (id)initWithLoaded:(BOOL)loaded {
    return nil; // OVERRIDE!
}

- (void)updateSceneWithDelta:(float)aDelta {
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            isMissionOver = YES;
            [endMissionObject setWasSuccessfulMission:YES];
            [endMissionObject setCurrentScene:self];
        }
    }
    if ([self checkFailure]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            isMissionOver = YES;
            [endMissionObject setWasSuccessfulMission:NO];
            [endMissionObject setCurrentScene:self];
        }
    }
    [super updateSceneWithDelta:aDelta];
}

- (BOOL)checkObjective {
    // OVERRIDE, return YES if the objective is complete, and the level should transition.
    return NO;
}

- (BOOL)checkFailure {
    // OVERRIDE, return YES if the mission has failed, and the level should restart.
    return NO;
}

- (void)advanceToNextLevel {
    if (!isAdvancingOrReset) {
        isAdvancingOrReset = YES;
        if (campaignIndex < CAMPAIGN_SCENES_COUNT - 1) {
            [[GameController sharedGameController] loadCampaignLevelsForIndex:campaignIndex + 1 withLoaded:NO];
            [[GameController sharedGameController] transitionToSceneWithFileName:nextSceneName sceneType:kSceneTypeCampaign withIndex:campaignIndex + 1 isNew:NO isLoading:NO];
        }
    }
}

- (void)restartCurrentLevel {
    if (!isAdvancingOrReset) {
        isAdvancingOrReset = YES;
        [[GameController sharedGameController] loadCampaignLevelsForIndex:campaignIndex withLoaded:NO];
        [[GameController sharedGameController] transitionToSceneWithFileName:sceneName sceneType:kSceneTypeCampaign withIndex:campaignIndex isNew:NO isLoading:NO];
    }
}

@end
