//
//  CampaignSceneTwo.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/22/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneTwo.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "StartMissionObject.h"
#import "SpawnerObject.h"
#import "TextObject.h"
#import "AIController.h"

@implementation CampaignSceneTwo

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:1 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Find the two abandoned pirate outposts"];
        [startObject setMissionTextThree:@"- Destroy all the enemy craft and structures"];
        [enemyAIController setIsPirateScene:NO];
        
        if (!loaded) {
            // New stuff!
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitBase];
            [dia1 setDialogueText:@"We have a small task for you. In your local space we have detected a few Ant craft left behind by some pirate factions. Don't worry, there aren't any colonies or strong craft nearby so you're relatively safe. Just take care of the junk they ditched for us to 'reclaim.'"];
            [sceneDialogues addObject:dia1];
            [dia1 release];
        }
    }
    return self;  
}

- (BOOL)checkObjective {
    if (numberOfEnemyShips == 0 && numberOfEnemyStructures == 0 && !doesExplosionExist) {
        return YES;
    }
    return NO; // NO
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    return NO;
}

@end
