//
//  CampaignSceneFive.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneFive.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

@implementation CampaignSceneFive

- (void)dealloc {
    [spawnerOne release];
    [spawnerTwo release];
    [spawnerThree release];
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:4 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Survive the wave in 8 minutes"];
        [startObject setMissionTextThree:@"- Destroy all enemy craft in the wave"];
        
        spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:10];
        [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerOne pauseSpawnerForDuration:(8.0f * 60.0f) + 1.0f];
        [spawnerOne setSendingLocation:homeBaseLocation];
        [spawnerOne setSendingLocationVariance:128.0f];
        [spawnerOne setStartingLocationVariance:128.0f];
        
        spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width / 2, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerTwo pauseSpawnerForDuration:(8.0f * 60.0f) + 1.0f];
        [spawnerTwo setSendingLocation:homeBaseLocation];
        [spawnerTwo setSendingLocationVariance:128.0f];
        [spawnerTwo setStartingLocationVariance:128.0f];
        
        spawnerThree = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerThree addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerThree pauseSpawnerForDuration:(8.0f * 60.0f) + 1.0f];
        [spawnerThree setSendingLocation:homeBaseLocation];
        [spawnerThree setSendingLocationVariance:128.0f];
        [spawnerThree setStartingLocationVariance:128.0f];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission) {
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
    [spawnerThree updateSpawnerWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([spawnerOne isDoneSpawning] && [spawnerTwo isDoneSpawning] && [spawnerThree isDoneSpawning] 
        && enemyShipCount == 0) {
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