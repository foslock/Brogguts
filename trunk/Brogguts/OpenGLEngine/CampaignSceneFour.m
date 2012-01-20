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

#define CAMPAIGN_FOUR_WAVE_TIME 8.0f

@implementation CampaignSceneFour

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:3 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:[NSString stringWithFormat:@"- Survive the wave approaching in %i minutes",(int)CAMPAIGN_FOUR_WAVE_TIME]];
        [startObject setMissionTextTwo:@"- Destroy all 15 enemy Ants in the wave"];
        [startObject setMissionTextThree:@"- Destroy both enemy Beetles in the wave"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"Well, it seems that you are climbing the commanding ladder faster than anyone could have imagined. You're already becoming an invaluable resource to our company. We've put you in charge of defending another colony that will be getting attacked. Watch out this time though, the pirates come in greater numbers and with stronger craft."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:(CAMPAIGN_FOUR_WAVE_TIME / 2) * 60.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"We've picked up strong signals reflecting those of enemy Beetle craft. The Beetle is slow, but can take a beating and delivers some serious firepower. Read about it in the Broggupedia for more information."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:1];
            [spawnerOne pauseSpawnerForDuration:(CAMPAIGN_FOUR_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerOne setSendingLocation:homeBaseLocation];
            [spawnerOne setSendingLocationVariance:128.0f];
            [spawnerOne setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerOne];
            [spawnerOne release];
            
            SpawnerObject* spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:8];
            [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:1];
            [spawnerTwo pauseSpawnerForDuration:(CAMPAIGN_FOUR_WAVE_TIME * 60.0f) + 1.0f];
            [spawnerTwo setSendingLocation:homeBaseLocation];
            [spawnerTwo setSendingLocationVariance:128.0f];
            [spawnerTwo setStartingLocationVariance:128.0f];
            [self addSpawner:spawnerTwo];
            [spawnerTwo release];
        }
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    if (isStartingMission || isMissionPaused || isShowingDialogue || isObjectiveComplete) {
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
    if ([[self spawnerWithID:0] isDoneSpawning] && [[self spawnerWithID:1] isDoneSpawning] && enemyShipCount == 0) {
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