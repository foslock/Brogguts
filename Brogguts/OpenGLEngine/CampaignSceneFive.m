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

#define CAMPAIGN_FIVE_WAVE_TIME 8.0f

@implementation CampaignSceneFive

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:4 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:[NSString stringWithFormat:@"- Survive the wave approaching in %i minutes",(int)CAMPAIGN_FIVE_WAVE_TIME]];
        [startObject setMissionTextThree:@"- Destroy all enemy craft in the wave"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"Commander, you have been put in charge of a base station farther from safe space, so pirates travel in larger fleets than you might be used to. Also, if it hasn't become clear, you should probably mine the brogguts that are closest to your base station first."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:(CAMPAIGN_FIVE_WAVE_TIME/2) * 60.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"This mission just got a lot messier. It seems that the enemy ships are converging from the entire upper region of space towards your colony. Think about how this might affect your current mining strategy."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:10];
            [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerOne pauseSpawnerForDuration:(CAMPAIGN_FIVE_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerOne setSendingLocation:homeBaseLocation];
            [spawnerOne setSendingLocationVariance:128.0f];
            [spawnerOne setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerOne];
            [spawnerOne release];
            
            SpawnerObject* spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width / 2, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerTwo pauseSpawnerForDuration:(CAMPAIGN_FIVE_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerTwo setSendingLocation:homeBaseLocation];
            [spawnerTwo setSendingLocationVariance:128.0f];
            [spawnerTwo setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerTwo];
            [spawnerTwo release];
            
            SpawnerObject* spawnerThree = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerThree addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerThree pauseSpawnerForDuration:(CAMPAIGN_FIVE_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerThree setSendingLocation:homeBaseLocation];
            [spawnerThree setSendingLocationVariance:128.0f];
            [spawnerThree setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerThree];
            [spawnerThree release];
        }
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission || isMissionPaused || isShowingDialogue) {
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
    
    if (minutes > 0 || seconds > 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }
    
    [self updateSpawnersWithDelta:aDelta];
}

- (BOOL)checkObjective {
    int enemyShipCount = [self numberOfEnemyShips];
    if ([[self spawnerWithID:0] isDoneSpawning] && [[self spawnerWithID:1] isDoneSpawning] && [[self spawnerWithID:2] isDoneSpawning] 
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