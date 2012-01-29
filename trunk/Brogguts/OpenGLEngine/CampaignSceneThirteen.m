//
//  CampaignSceneThirteen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneThirteen.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"

#define CAMPAIGN_THIRTEEN_TIME_LIMIT 4.0f

@implementation CampaignSceneThirteen

- (void)dealloc {
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:12 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextOne:@"- An army of countless craft approaches"];
        [startObject setMissionTextTwo:@"- Destroy the enemy turrets to stop the waves"];
        [startObject setMissionTextThree:@"- Destroy any remaining enemy craft"];
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"It appears that a distant company base station has begun to produce and endless supply of Ant craft. As luck would have it, they're heading your way. You have a little time to build a defense, or you could focus on taking out the four turrets to stop the stream of Ants."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_THIRTEEN_TIME_LIMIT * 60.0f];
            [dia2 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia2 setDialogueText:@"The Ant craft have started to arrive in your local space. The may seem weak at first, but be sure to keep an eye on them. They are quite dangerous in masses."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            SpawnerObject* spawner = [[SpawnerObject alloc] initWithLocation:CGPointMake(fullMapBounds.size.width / 2, fullMapBounds.size.height) objectID:kObjectCraftAntID withDuration:4.0f withCount:-1];
            [spawner pauseSpawnerForDuration:(CAMPAIGN_THIRTEEN_TIME_LIMIT * 60.0f) + 1.0f];
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
    if (isStartingMission || isMissionPaused || isShowingDialogue || isObjectiveComplete) {
        return;
    }
    int minutes = [[self spawnerWithID:0] pauseTimeLeft] / 60.0f;
    int seconds = [[self spawnerWithID:0] pauseTimeLeft] - (60.0f * minutes);
    NSString* countdown;
    
    if (seconds >= 10) {
        countdown = [NSString stringWithFormat:@"Ants: %i:%i", minutes, seconds];
    } else {
        countdown = [NSString stringWithFormat:@"Ants: %i:0%i", minutes, seconds];
    }
    
    if (minutes > 0 || seconds > 0) {
        [countdownTimer setObjectText:countdown];
    } else {
        [countdownTimer setObjectText:@""];
    }
    
    if (numberOfEnemyStructures == 0) {
        [[self spawnerWithID:0] stopSpawnerAndClearCounts];
    }
    [self updateSpawnersWithDelta:aDelta];
}

- (BOOL)checkObjective {
    if (numberOfEnemyStructures == 0 &&
        numberOfEnemyShips == 0 && !doesExplosionExist) {
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