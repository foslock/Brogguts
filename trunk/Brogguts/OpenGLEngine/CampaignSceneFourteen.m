//
//  CampaignSceneFourteen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneFourteen.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"
#import "AntCraftObject.h"

#define CAMPAIGN_FOURTEEN_PATH_POINTS 15

const int kNPCAntPathData[CAMPAIGN_FOURTEEN_PATH_POINTS*2] = {
    52 * COLLISION_CELL_WIDTH, 33 * COLLISION_CELL_HEIGHT,
    36 * COLLISION_CELL_WIDTH, 33 * COLLISION_CELL_HEIGHT,
    36 * COLLISION_CELL_WIDTH, 21 * COLLISION_CELL_HEIGHT,
    52 * COLLISION_CELL_WIDTH, 21 * COLLISION_CELL_HEIGHT,
    52 * COLLISION_CELL_WIDTH, 15 * COLLISION_CELL_HEIGHT,
    36 * COLLISION_CELL_WIDTH, 15 * COLLISION_CELL_HEIGHT,
    36 * COLLISION_CELL_WIDTH, 9 * COLLISION_CELL_HEIGHT,
    28 * COLLISION_CELL_WIDTH, 9 * COLLISION_CELL_HEIGHT,
    28 * COLLISION_CELL_WIDTH, 39 * COLLISION_CELL_HEIGHT,
    12 * COLLISION_CELL_WIDTH, 39 * COLLISION_CELL_HEIGHT,
    12 * COLLISION_CELL_WIDTH, 27 * COLLISION_CELL_HEIGHT,
    20 * COLLISION_CELL_WIDTH, 27 * COLLISION_CELL_HEIGHT,
    20 * COLLISION_CELL_WIDTH, 15 * COLLISION_CELL_HEIGHT,
    12 * COLLISION_CELL_WIDTH, 15 * COLLISION_CELL_HEIGHT,
    12 * COLLISION_CELL_WIDTH, 0 * COLLISION_CELL_HEIGHT,
};

@implementation CampaignSceneFourteen

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:13 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Escort the neutral Ant to its destination"];
        [startObject setMissionTextThree:@"- Protect the Ant at all costs"];
        
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"I've got a special job for you this time around. We've given you command of a sizeable force in order to escort a very important Ant craft through this section of space. Unfortunately it is protected and patrolled by company forces."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia2 setDialogueText:@"This Ant contains some serious cargo, the details of which are a closely guarded secret. Do not let it get destroyed or worse, captured. We have big plans for it in the near future. And try to keep up with it, it may seem slow, but its path is hardwired and cannot be changed."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:CGPointMake(52 * COLLISION_CELL_WIDTH, fullMapBounds.size.height)
                                                                  isTraveling:NO];
            [newAnt setCraftSpeedLimit:kCraftSpiderEngines];
            npcAnt = newAnt;
            [newAnt setObjectAlliance:kAllianceNeutral];
            [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
            
            // Create path for newAnt
            NSMutableArray* pathArray = [NSMutableArray arrayWithCapacity:CAMPAIGN_FOURTEEN_PATH_POINTS];
            int index = 0;
            for (int i = 0; i < CAMPAIGN_FOURTEEN_PATH_POINTS; i++) {
                CGPoint point = CGPointMake(kNPCAntPathData[index++],
                                            kNPCAntPathData[index++]);
                [pathArray addObject:[NSValue valueWithCGPoint:point]];
            }
            [newAnt followPath:pathArray isLooped:NO];
        } else {
            // If it was loaded, set the only neutral ant to the the NPC
            for (int i = 0; i < [touchableObjects count]; i++) {
                TouchableObject* obj = [touchableObjects objectAtIndex:i];
                if (obj.objectAlliance == kAllianceNeutral &&
                    obj.objectType == kObjectCraftAntID) {
                    npcAnt = (AntCraftObject*)obj;
                    break;
                }
            }
        }
        [npcAnt setCraftSpeedLimit:kCraftAntEngines - 1];
        [enemyAIController setIsPirateScene:NO];
    }
    return self;
}

- (void)sceneDidAppear {
    [super sceneDidAppear];
    [self setCameraLocation:CGPointMake(52 * COLLISION_CELL_WIDTH, fullMapBounds.size.height)];
    [self setMiddleOfVisibleScreenToCamera];
}

- (BOOL)checkObjective {
    if (GetDistanceBetweenPointsSquared(npcAnt.objectLocation, CGPointMake(12 * COLLISION_CELL_WIDTH, 0 * COLLISION_CELL_HEIGHT)) < POW2(COLLISION_CELL_WIDTH)) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if (npcAnt.destroyNow) {
        return YES;
    }
    return NO;
}

@end