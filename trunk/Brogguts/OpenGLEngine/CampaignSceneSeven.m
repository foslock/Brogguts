//
//  CampaignSceneSeven.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneSeven.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

#define CAMPAIGN_SEVEN_START_BROGGUTS 10000
#define CAMPAIGN_SEVEN_WAVE_TIME 10.0f

@implementation CampaignSceneSeven

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:6 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:@"- There are no minable brogguts nearby"];
        [startObject setMissionTextTwo:[NSString stringWithFormat:@"- You are provided with %i Brogguts",CAMPAIGN_SEVEN_START_BROGGUTS]];
        [startObject setMissionTextThree:[NSString stringWithFormat:@"- Survive the second wave at %i minutes",(int)CAMPAIGN_SEVEN_WAVE_TIME]];
        [startObject setMissionTextFour:@"- Destroy all enemy craft in the wave"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"The higher ups at the company have decided after so many successful defensive missions that you are the perfect man for this very special job. And old abandoned base station is sitting in empty space, having completely mined all of its surrounding brogguts."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"There is technology aboard this station that we do not want falling into the pirates' hands. You may use all the remaining brogguts held in this station to build a defense to hold out against the incoming invasion."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:3];
            [spawnerOne pauseSpawnerForDuration:(CAMPAIGN_SEVEN_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerOne setSendingLocation:homeBaseLocation];
            [spawnerOne setSendingLocationVariance:128.0f];
            [spawnerOne setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerOne];
            [spawnerOne release];
            
            SpawnerObject* spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width / 2, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:4];
            [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:1];
            [spawnerTwo addObjectWithID:kObjectCraftMothID withCount:2];
            [spawnerTwo pauseSpawnerForDuration:(CAMPAIGN_SEVEN_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerTwo setSendingLocation:homeBaseLocation];
            [spawnerTwo setSendingLocationVariance:128.0f];
            [spawnerTwo setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerTwo];
            [spawnerTwo release];
            
            SpawnerObject* spawnerThree = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerThree addObjectWithID:kObjectCraftBeetleID withCount:3];
            [spawnerThree pauseSpawnerForDuration:(CAMPAIGN_SEVEN_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerThree setSendingLocation:homeBaseLocation];
            [spawnerThree setSendingLocationVariance:128.0f];
            [spawnerThree setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerThree];
            [spawnerThree release];
        }
        if (!loaded) {
            [[[GameController sharedGameController] currentProfile] setBrogguts:CAMPAIGN_SEVEN_START_BROGGUTS];
            [[[GameController sharedGameController] currentProfile] setMetal:PROFILE_METAL_START_COUNT];
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
    
    if (minutes != 0 || seconds != 0) {
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