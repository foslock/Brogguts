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

#define CAMPAIGN_SCENES_COUNT 15

extern NSString* kCampaignSceneFileNames[CAMPAIGN_SCENES_COUNT + 1];

@interface CampaignScene : BroggutScene {
    int campaignIndex; 
    NSString* nextSceneName;
    BOOL isObjectiveComplete;
    BOOL isAdvancingOrReset;
}

- (id)initWithCampaignIndex:(int)campIndex;
- (BOOL)checkObjective;
- (BOOL)checkFailure;
- (void)advanceToNextLevel;
- (void)restartCurrentLevel;

@end