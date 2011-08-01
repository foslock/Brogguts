//
//  CampaignSceneNine.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneNine.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

#define CAMPAIGN_NINE_WAVE_TIME 15.0f

@implementation CampaignSceneNine


- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:8 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@""];
        [startObject setMissionTextThree:@"- Destroy all 10 enemy Ants in the wave"];
        if (!loaded) {
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.2f withCount:10];
            [spawner addObjectWithID:kObjectCraftBeetleID withCount:10];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_NINE_WAVE_TIME * 60.0f) + 1.0f];
            [spawner setSendingLocation:homeBaseLocation];
            [spawner setSendingLocationVariance:100.0f];
            [spawner setStartingLocationVariance:128.0f];
            [self addSpawner:spawner];
            [spawner release];
        }
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission || isMissionPaused) {
        return;
    }
    int minutes = [[self spawnerWithID:0] pauseTimeLeft] / 60.0f;
    int seconds = [[self spawnerWithID:0] pauseTimeLeft] - (60.0f * minutes);
    NSString* countdown;
    
    if (seconds >= 10) {
        countdown = [NSString stringWithFormat:@"Wave: %i:%i", minutes, seconds];
    } else {
        countdown = [NSString stringWithFormat:@"Wave: %i:0%i", minutes, seconds];
    }
    
    if (minutes != 0 || seconds != 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }

    [self updateSceneWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int count = [[[GameController sharedGameController] currentProfile] broggutCount];
    if (count >= 2500) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if (numberOfCurrentStructures <= 0) {
        return YES;
    }
    return NO;
}

@end