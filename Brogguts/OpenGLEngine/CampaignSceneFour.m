//
//  CampaignSceneFour.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneFour.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "TextObject.h"
#import "StartMissionObject.h"

#define CAMPAIGN_FOUR_WAVE_TIME 10.0f

@implementation CampaignSceneFour

- (void)dealloc {
    [spawnerOne release];
    [spawnerTwo release];
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:3 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:[NSString stringWithFormat:@"- Survive the wave approaching in %i minutes",(int)CAMPAIGN_FOUR_WAVE_TIME]];
        [startObject setMissionTextTwo:@"- Destroy all 15 enemy Ants in the wave"];
        [startObject setMissionTextThree:@"- Destroy both enemy Beetles in the wave"];
        
        spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:1];
        [spawnerOne pauseSpawnerForDuration:(CAMPAIGN_FOUR_WAVE_TIME * 60.0f) + 1.0f];
        [spawnerOne setSendingLocation:homeBaseLocation];
        [spawnerOne setSendingLocationVariance:128.0f];
        [spawnerOne setStartingLocationVariance:128.0f];
        
        spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:1];
        [spawnerTwo pauseSpawnerForDuration:(CAMPAIGN_FOUR_WAVE_TIME * 60.0f) + 1.0f];
        [spawnerTwo setSendingLocation:homeBaseLocation];
        [spawnerTwo setSendingLocationVariance:128.0f];
        [spawnerTwo setStartingLocationVariance:128.0f];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission || isMissionPaused) {
        return;
    }
    int minutes = [spawnerOne pauseTimeLeft] / 60.0f;
    int seconds = [spawnerOne pauseTimeLeft] - (60.0f * minutes);
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
    [spawnerOne updateSpawnerWithDelta:aDelta];
    [spawnerTwo updateSpawnerWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([spawnerOne isDoneSpawning] && [spawnerTwo isDoneSpawning] && enemyShipCount == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    if (numberOfCurrentStructures <= 0) {
        return YES;
    }
    return NO;
}

@end