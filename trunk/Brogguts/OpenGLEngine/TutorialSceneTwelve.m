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
        
        [helpText setObjectText:@"Structures are built the same way, although only one can be travelling at a time. The farther from your Base Station, the longer the wait. Build three new Blocks. Check the Broggupedia for a detailed description."];
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
