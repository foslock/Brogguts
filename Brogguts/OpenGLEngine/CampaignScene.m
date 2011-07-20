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
#import "PlayerProfile.h"
#import "StartMissionObject.h"

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

NSString* kCampaignSceneSaveTitles[CAMPAIGN_SCENES_COUNT + 1] = {
    @"Mission 1 - Another Man's Trash",
    @"Mission 2 - Garbage Collector",
    @"Mission 3 - The Tides",
    @"Mission 4 - Twice the Terror",
    @"Mission 5 - Promoted",
    @"Mission 6 - From All Sides",
    @"Mission 7 - On Your Own",
    @"Mission 8 - Without Representation",
    @"Mission 9 - Ancient Material",
    @"Mission 10 - Captive and Active",
    @"Mission 11 - Passive Aggressive",
    @"Mission 12 - There’s No Time",
    @"Mission 13 - Stand Your Ground",
    @"Mission 14 - Professional Escort",
    @"Mission 15 - An Important Delivery",
    @"Credits",
};

@implementation CampaignScene
@synthesize isStartingMission, isMissionPaused, campaignIndex;

- (void)dealloc {
    [startObject release];
    [super dealloc];
}

- (id)initWithCampaignIndex:(int)campIndex wasLoaded:(BOOL)loaded {
    if (!loaded) {
        self = [super initWithFileName:kCampaignSceneFileNames[campIndex] wasLoaded:loaded];
    } else {
        self = [super initWithFileName:kCampaignSceneSaveTitles[campIndex] wasLoaded:loaded];
    }
    if (self) {
        nextSceneFileName = kCampaignSceneFileNames[campIndex+1];
        sceneFileName = kCampaignSceneFileNames[campIndex];
        
        sceneType = kSceneTypeCampaign;
        campaignIndex = campIndex;
        isStartingMission = YES;
        isMissionPaused = YES;
        isObjectiveComplete = NO;
        isAdvancingOrReset = NO;
        
        // Turn on the complicated stuff
        isAllowingSidebar = YES;
        isShowingBroggutCount = YES;
        isShowingMetalCount = YES;
        isShowingSupplyCount = YES;
        isAllowingOverview = YES;
        
        startObject = [[StartMissionObject alloc] init];
        [startObject setMissionHeader:@"Mission Objectives"];
        
        [self setCameraLocation:homeBaseLocation];
        [self setMiddleOfVisibleScreenToCamera];
        
        int currentExperience = [[sharedGameController currentProfile] playerExperience];
        if (campaignIndex >= currentExperience) {
            [[sharedGameController currentProfile] setPlayerExperience:campaignIndex];
            [[sharedGameController currentProfile] updateSpaceYearUnlocks];
        }
    }
    return self;
}

- (id)initWithLoaded:(BOOL)loaded {
    return nil; // OVERRIDE!
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (isStartingMission || isMissionPaused) {
        [startObject updateObjectLogicWithDelta:aDelta];
        return;
    }
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            isMissionOver = YES;
            [endMissionObject setWasSuccessfulMission:YES];
            [endMissionObject setCurrentScene:self];
            int currentExperience = [[sharedGameController currentProfile] playerExperience];
            if (campaignIndex + 1 >= currentExperience) {
                [[sharedGameController currentProfile] setPlayerExperience:campaignIndex + 1];
                [[sharedGameController currentProfile] updateSpaceYearUnlocks];
            }
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

- (void)renderScene {
    if (isStartingMission || isMissionPaused) {
        Vector2f scroll = [self scrollVectorFromScreenBounds];
        [startObject renderCenteredAtPoint:[self middleOfVisibleScreen] withScrollVector:scroll];
    }
    [super renderScene];
}

- (BOOL)checkObjective {
    // OVERRIDE, return YES if the objective is complete, and the level should transition.
    return NO;
}

- (BOOL)checkFailure {
    // OVERRIDE, return YES if the mission has failed, and the level should restart.
    return NO;
}

- (BOOL)checkDefaultFailure {
    int brogCount = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (brogCount < kCraftAntCostBrogguts && numberOfCurrentShips == 0) {
        return YES;
    }
    if (!isFriendlyBaseStationAlive) {
        return YES;
    }
    return NO;
}

- (void)advanceToNextLevel {
    if (!isAdvancingOrReset) {
        isAdvancingOrReset = YES;
        if (campaignIndex < CAMPAIGN_SCENES_COUNT - 1) {
            [[GameController sharedGameController] fadeOutToSceneWithFilename:nextSceneFileName sceneType:kSceneTypeCampaign withIndex:campaignIndex + 1 isNew:YES isLoading:NO];
        }
    }
}

- (void)restartCurrentLevel {
    if (!isAdvancingOrReset) {
        isAdvancingOrReset = YES;
        [[GameController sharedGameController] fadeOutToSceneWithFilename:sceneFileName sceneType:kSceneTypeCampaign withIndex:campaignIndex isNew:YES isLoading:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isStartingMission || isMissionPaused) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([startObject rect], touchLocation)) {
            [startObject touchesBeganAtLocation:touchLocation];
        }
        return;
    }
    [super touchesBegan:touches withEvent:event view:aView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isStartingMission || isMissionPaused) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint previousOrigTouchLocation = [touch previousLocationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        CGPoint prevTouchLocation = [sharedGameController adjustTouchOrientationForTouch:previousOrigTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([startObject rect], touchLocation)) {
            [startObject touchesMovedToLocation:touchLocation from:prevTouchLocation];
        }
        return;
    }
    [super touchesMoved:touches withEvent:event view:aView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    [self touchesEnded:touches withEvent:event view:aView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isStartingMission || isMissionPaused) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        
        if (CGRectContainsPoint([startObject rect], touchLocation)) {
            [startObject touchesEndedAtLocation:touchLocation];
        }
        return;
    }
    [super touchesEnded:touches withEvent:event view:aView];
}



@end
