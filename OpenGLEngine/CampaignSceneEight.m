//
//  CampaignSceneEight.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneEight.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "TextObject.h"
#import "StartMissionObject.h"

#define CAMPAIGN_EIGHT_WAVE_ONE_TIME 5.0f
#define CAMPAIGN_EIGHT_WAVE_TWO_TIME 10.0f
#define CAMPAIGN_EIGHT_WAVE_THREE_TIME 15.0f
#define CAMPAIGN_EIGHT_WAVE_FOUR_TIME 20.0f

@implementation CampaignSceneEight

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:7 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:@"- There are four waves coming to attack"];
        [startObject setMissionTextTwo:@"- They are planned to come every 5 minutes"];
        [startObject setMissionTextThree:@"- Destroy all enemy craft in all four waves"];
        
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"We need you on this emergency mission! An officer responsible for a base station out in dangerous space has just stepped down from his command and the station needs to be run with a keen eye."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitBase];
            [dia2 setDialogueText:@"There is a very important, and valuable, piece of data aboard that base station. Be cautious; reports indicate that multiple pirate factions have allied against us on this one. Expect multiple waves from any direction."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawnerOne = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawnerOne addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerOne addObjectWithID:kObjectCraftAntID withCount:3];
            [spawnerOne addObjectWithID:kObjectCraftMothID withCount:2];
            [spawnerOne pauseSpawnerForDuration:(CAMPAIGN_EIGHT_WAVE_ONE_TIME * 60.0f) + 1.0f];
            [spawnerOne setSendingLocation:homeBaseLocation];
            [spawnerOne setSendingLocationVariance:128.0f];
            [spawnerOne setStartingLocationVariance:512.0f];
            [self addSpawner:spawnerOne];
            [spawnerOne release];
            
            SpawnerObject* spawnerTwo = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawnerTwo addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerTwo addObjectWithID:kObjectCraftAntID withCount:3];
            [spawnerTwo addObjectWithID:kObjectCraftMothID withCount:2];
            [spawnerTwo pauseSpawnerForDuration:(CAMPAIGN_EIGHT_WAVE_TWO_TIME * 60.0f) + 1.0f];
            [spawnerTwo setSendingLocation:homeBaseLocation];
            [spawnerTwo setSendingLocationVariance:128.0f];
            [spawnerTwo setStartingLocationVariance:512.0f];
            [self addSpawner:spawnerTwo];
            [spawnerTwo release];
            
            SpawnerObject* spawnerThree = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawnerThree addObjectWithID:kObjectCraftBeetleID withCount:2];
            [spawnerThree addObjectWithID:kObjectCraftAntID withCount:3];
            [spawnerThree addObjectWithID:kObjectCraftMothID withCount:2];
            [spawnerThree pauseSpawnerForDuration:(CAMPAIGN_EIGHT_WAVE_THREE_TIME * 60.0f) + 1.0f];
            [spawnerThree setSendingLocation:homeBaseLocation];
            [spawnerThree setSendingLocationVariance:128.0f];
            [spawnerThree setStartingLocationVariance:256.0f];
            [self addSpawner:spawnerThree];
            [spawnerThree release];
            
            SpawnerObject* spawnerFour = [[SpawnerObject alloc] initWithLocation:CGPointMake(0.0f, 0.0f) objectID:kObjectCraftAntID withDuration:0.1f withCount:0];
            [spawnerFour addObjectWithID:kObjectCraftBeetleID withCount:4];
            [spawnerFour addObjectWithID:kObjectCraftAntID withCount:4];
            [spawnerFour addObjectWithID:kObjectCraftMothID withCount:3]; 
            [spawnerFour pauseSpawnerForDuration:(CAMPAIGN_EIGHT_WAVE_FOUR_TIME * 60.0f) + 1.0f];
            [spawnerFour setSendingLocation:homeBaseLocation];
            [spawnerFour setSendingLocationVariance:128.0f];
            [spawnerFour setStartingLocationVariance:256.0f];
            [self addSpawner:spawnerFour];
            [spawnerFour release];
        }

    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    
    if (isStartingMission || isMissionPaused || isShowingDialogue || isObjectiveComplete) {
        return;
    }
    
    int minutes = 0;
    int seconds = 0;
    
    if (![[self spawnerWithID:0] isDoneSpawning]) {
        minutes = [[self spawnerWithID:0] pauseTimeLeft] / 60.0f;
        seconds = [[self spawnerWithID:0] pauseTimeLeft] - (60.0f * minutes);
    } else if (![[self spawnerWithID:1] isDoneSpawning]) {
        minutes = [[self spawnerWithID:1] pauseTimeLeft] / 60.0f;
        seconds = [[self spawnerWithID:1] pauseTimeLeft] - (60.0f * minutes);
    } else if (![[self spawnerWithID:2] isDoneSpawning]) {
        minutes = [[self spawnerWithID:2] pauseTimeLeft] / 60.0f;
        seconds = [[self spawnerWithID:2] pauseTimeLeft] - (60.0f * minutes);
    } else if (![[self spawnerWithID:3] isDoneSpawning]) {
        minutes = [[self spawnerWithID:3] pauseTimeLeft] / 60.0f;
        seconds = [[self spawnerWithID:3] pauseTimeLeft] - (60.0f * minutes);
    }
    
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
    if ([[self spawnerWithID:0] isDoneSpawning] && [[self spawnerWithID:1] isDoneSpawning] && 
        [[self spawnerWithID:2] isDoneSpawning] && [[self spawnerWithID:3] isDoneSpawning] &&
        enemyShipCount == 0 && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    if (numberOfCurrentStructures <= 0 && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

@end