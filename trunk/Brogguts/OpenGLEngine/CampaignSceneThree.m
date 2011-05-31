//
//  CampaignSceneThree.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneThree.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "TextObject.h"
#import "StartMissionObject.h"

@implementation CampaignSceneThree

- (void)dealloc {
    [spawner release];
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:2 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Survive the wave approaching in 5 minutes"];
        [startObject setMissionTextThree:@"- Destroy all 10 enemy Ants in the wave"];
        spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:10];
        [spawner pauseSpawnerForDuration:(5.0f * 60.0f) + 1.0f];
        [spawner setSendingLocation:homeBaseLocation];
        [spawner setSendingLocationVariance:100.0f];
        [spawner setStartingLocationVariance:128.0f];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission) {
        return;
    }
    int minutes = [spawner pauseTimeLeft] / 60.0f;
    int seconds = [spawner pauseTimeLeft] - (60.0f * minutes);
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
    [spawner updateSpawnerWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([spawner isDoneSpawning] && enemyShipCount == 0) {
        return YES;
    }
    return YES; // NO
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