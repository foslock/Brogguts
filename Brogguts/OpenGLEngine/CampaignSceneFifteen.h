//
//  CampaignSceneFifteen.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CampaignScene.h"

@class AntCraftObject;
@class SpawnerObject;
@class BaseStationStructureObject;

@interface CampaignSceneFifteen : CampaignScene {
    AntCraftObject* npcAnt;
    AntCraftObject* closestAnt;
    BaseStationStructureObject* enemyBase;
    BOOL boomGoesTheDynamite;
}

@end
