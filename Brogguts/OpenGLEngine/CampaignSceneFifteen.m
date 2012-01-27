//
//  CampaignSceneFifteen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "CampaignSceneFifteen.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "SpawnerObject.h"
#import "StartMissionObject.h"
#import "TextObject.h"
#import "AntCraftObject.h"
#import "CollisionManager.h"
#import "BaseStationStructureObject.h"
#import "Image.h"

@implementation CampaignSceneFifteen

- (void)dealloc {
    [super dealloc];
}

- (id)initWithLoaded:(BOOL)loaded {
    self = [super initWithCampaignIndex:14 wasLoaded:loaded];
    if (self) {
        [startObject setMissionTextTwo:@"- Bring the Ant to the enemy base station"];
        [startObject setMissionTextThree:@"- It must reach the station alive"];
        boomGoesTheDynamite = NO;
        enemyBase = nil;
        if (!loaded) {
            DialogueObject* dia1 = [[DialogueObject alloc] init];
            [dia1 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE];
            [dia1 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia1 setDialogueText:@"This is our final mission for you. As a commander you truly are talented and have completed many tasks that even the best in our faction wouldn't dream of attempting. I've decided to let you free if you are able to finish this last mission for me."];
            [sceneDialogues addObject:dia1];
            [dia1 release];
            
            DialogueObject* dia2 = [[DialogueObject alloc] init];
            [dia2 setDialogueActivateTime:CAMPAIGN_DEFAULT_WAIT_TIME_MESSAGE + 0.1f];
            [dia2 setDialogueImageIndex:kDialoguePortraitAnon];
            [dia2 setDialogueText:@"The Ant you escorted through the last area of space has something very... powerful in its cargo space. I want you to end your pirate career with a bang, so just lead it to the enemy base station and it will automatically detonate. Get it all the way there safely! It will follow the closest friendly Ant within its range."];
            [sceneDialogues addObject:dia2];
            [dia2 release];
            
            AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:CGPointMake(4 * COLLISION_CELL_WIDTH, 4 * COLLISION_CELL_HEIGHT)
                                                                  isTraveling:NO];
            npcAnt = newAnt;
            [newAnt setObjectAlliance:kAllianceNeutral];
            [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
        } else {
            // If it was loaded, set the only neutral ant to the the NPC
            for (int i = 0; i < [touchableObjects count]; i++) {
                TouchableObject* obj = [touchableObjects objectAtIndex:i];
                if (obj.objectAlliance == kAllianceNeutral &&
                    obj.objectType == kObjectCraftAntID) {
                    npcAnt = (AntCraftObject*)obj;
                    break;
                }
                if (obj.objectAlliance == kAllianceEnemy &&
                    obj.objectType == kObjectStructureBaseStationID) {
                    enemyBase = (BaseStationStructureObject*)obj;
                }
            }
        }
        [npcAnt setCraftSpeedLimit:kCraftAntEngines - 1];
        [enemyAIController setIsPirateScene:NO];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [super updateSceneWithDelta:aDelta];
    
    // Get enemybase if it doesn't exist
    if (!enemyBase) {
        for (int i = 0; i < [touchableObjects count]; i++) {
            TouchableObject* obj = [touchableObjects objectAtIndex:i];
            if ([obj isKindOfClass:[BaseStationStructureObject class]]) {
                BaseStationStructureObject* base = (BaseStationStructureObject*)obj;
                if (base.objectAlliance == kAllianceEnemy) {
                    enemyBase = base;
                }
            }
        }
    }
    
    // Find the closest friendly ant
    int size = kCraftAntViewDistance;
    CGRect rect = CGRectMake(npcAnt.objectLocation.x - (size / 2), npcAnt.objectLocation.y - (size / 2), size, size);
    NSArray* nearArray = [collisionManager getArrayOfRadiiObjectsInRect:rect];
    if ([nearArray count] <= 1) {
        closestAnt = nil;
    }
    
    int minDist = POW2(size);
    for (int i = 0; i < [nearArray count]; i++) {
        TouchableObject* obj = [nearArray objectAtIndex:i];
        if ([obj isKindOfClass:[AntCraftObject class]]) {
            if ([obj objectAlliance] == kAllianceFriendly) {
                if (GetDistanceBetweenPointsSquared(npcAnt.objectLocation, obj.objectLocation) < minDist) {
                    minDist = GetDistanceBetweenPointsSquared(npcAnt.objectLocation, obj.objectLocation);
                    closestAnt = (AntCraftObject*)obj;
                }
            }
        }
    }
    
    // Have him follow the nearest ship
    if (closestAnt && closestAnt.hasMovedThisStep) {
        [npcAnt accelerateTowardsLocation:closestAnt.objectLocation withMaxVelocity:-1.0f];
    } else {
        [npcAnt decelerate];
    }
    
    if (GetDistanceBetweenPointsSquared(npcAnt.objectLocation, enemyBaseLocation) < POW2(COLLISION_CELL_WIDTH*4)) {
        // Boom goes the dynamite
        boomGoesTheDynamite = YES;
        npcAnt.destroyNow = YES;
        enemyBase.destroyNow = YES;
        int size = enemyBase.objectImage.imageSize.width * 2;
        CGRect rect = CGRectMake(npcAnt.objectLocation.x - (size / 2), npcAnt.objectLocation.y - (size / 2), size, size);
        NSArray* nearbyStuff = [collisionManager getArrayOfRadiiObjectsInRect:rect];
        for (TouchableObject* obj in nearbyStuff) {
            obj.destroyNow = YES;
        }
    }
}

- (BOOL)checkObjective {
    if (!isEnemyBaseStationAlive && boomGoesTheDynamite && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

- (BOOL)checkFailure {
    if ([self checkDefaultFailure]) {
        return YES;
    }
    if (npcAnt.destroyNow && !boomGoesTheDynamite && !doesExplosionExist) {
        return YES;
    }
    if (numberOfCurrentStructures <= 0 && !doesExplosionExist) {
        return YES;
    }
    return NO;
}

@end