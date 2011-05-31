//
//  TutorialSceneTwelve.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneTwelve.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneTwelve

- (id)init {
    self = [super initWithTutorialIndex:11];
    if (self) {
        isAllowingOverview = YES;
        isShowingBroggutCount = YES;
        isShowingSupplyCount = YES;
        isAllowingSidebar = YES;
        isAllowingCraft = YES;
        isAllowingStructures = YES;
        
        [helpText setObjectText:@"Structures are built the same way, except you can only build one at a time. Be careful how far you build it from your base station, or you will have to wait a long time! Build three new Blocks near your base station."];
    }
    return self;
}

- (BOOL)checkObjective {
    if (numberOfCurrentStructures >= 4 && !isBuildingStructure)
        return YES;
    else
        return NO;
}

@end
