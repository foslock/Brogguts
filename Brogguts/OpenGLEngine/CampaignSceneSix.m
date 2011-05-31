//
//  CampaignSceneSix.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneSix.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

@implementation CampaignSceneSix

- (void)dealloc {
    [spawnerOne release];
    [spawnerTwo release];
    [spawnerThree release];
    [spawnerFour release];
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:5 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:@"- Survive the first wave in 8 minutes"];
        [startObject setMissionTextTwo:@"- Survive the second wave in 13 minutes"];
        [startObject setMissionTextThree:@"- Destroy all enemy craft in both waves"];
        
        spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:10];
        [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerOne pauseSpawnerForDuration:(13.0f * 60.0f) + 1.0f];
        [spawnerOne setSendingLocation:homeBaseLocation];
        [spawnerOne setSendingLocationVariance:128.0f];
        [spawnerOne setStartingLocationVariance:128.0f];
        
        spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerTwo pauseSpawnerForDuration:(8.0f * 60.0f) + 1.0f];
        [spawnerTwo setSendingLocation:homeBaseLocation];
        [spawnerTwo setSendingLocationVariance:128.0f];
        [spawnerTwo setStartingLocationVariance:128.0f];
        
        spawnerThree = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerThree addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerThree pauseSpawnerForDuration:(8.0f * 60.0f) + 1.0f];
        [spawnerThree setSendingLocation:homeBaseLocation];
        [spawnerThree setSendingLocationVariance:128.0f];
        [spawnerThree setStartingLocationVariance:128.0f];
        
        spawnerFour = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
        [spawnerFour addObjectWithID:kObjectCraftBeetleID withCount:2];
        [spawnerFour pauseSpawnerForDuration:(13.0f * 60.0f) + 1.0f];
        [spawnerFour setSendingLocation:homeBaseLocation];
        [spawnerFour setSendingLocationVariance:128.0f];
        [spawnerFour setStartingLocationVariance:128.0f];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission) {
        return;
    }
    
    int minutes = 0;
    int seconds = 0;
    
    if (![spawnerOne isDoneSpawning]) {
        minutes = [spawnerOne pauseTimeLeft] / 60.0f;
        seconds = [spawnerOne pauseTimeLeft] - (60.0f * minutes);
    } else {
        minutes = [spawnerTwo pauseTimeLeft] / 60.0f;
        seconds = [spawnerTwo pauseTimeLeft] - (60.0f * minutes);
    }
    
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
    [spawnerFour updateSpawnerWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([spawnerOne isDoneSpawning] && [spawnerTwo isDoneSpawning] && 
        [spawnerThree isDoneSpawning] && [spawnerFour isDoneSpawning] &&
        enemyShipCount == 0) {
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