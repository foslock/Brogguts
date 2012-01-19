//
//  CampaignScene.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/22/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BroggutScene.h"
#import "NotificationObject.h"
#import "DialogueObject.h"

#define CAMPAIGN_SCENES_COUNT 16
#define CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE 2.0f

@class StartMissionObject;
@class SpawnerObject;

extern NSString* kCampaignSceneFileNames[CAMPAIGN_SCENES_COUNT];
extern NSString* kCampaignSceneSaveTitles[CAMPAIGN_SCENES_COUNT];

@interface CampaignScene : BroggutScene {
    int campaignIndex; 
    NSString* nextSceneFileName;
    BOOL isStartingMission;
    BOOL isMissionPaused;
    BOOL isObjectiveComplete;
    BOOL isAdvancingOrReset;
    StartMissionObject* startObject;
}

@property (nonatomic, assign) BOOL isStartingMission;
@property (nonatomic, assign) BOOL isMissionPaused;
@property (nonatomic, assign) int campaignIndex;

- (void)addSpawner:(SpawnerObject*)spawner;
- (SpawnerObject*)spawnerWithID:(int)spawnerID;
- (void)updateSpawnersWithDelta:(float)aDelta;

- (id)initWithCampaignIndex:(int)campIndex wasLoaded:(BOOL)loaded;
- (id)initWithLoaded:(BOOL)loaded;
- (BOOL)checkObjective;
- (BOOL)checkFailure;
- (BOOL)checkDefaultFailure;
- (void)advanceToNextLevel;
- (void)restartCurrentLevel;

@end