//
//  TutorialSceneThirteen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneThirteen.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneThirteen

- (id)init {
    self = [super initWithTutorialIndex:12];
    if (self) {
        isAllowingOverview = YES;
        isShowingBroggutCount = YES;
        isShowingMetalCount = YES;
        isShowingSupplyCount = YES;
        isAllowingSidebar = YES;
        isAllowingCraft = YES;
        isAllowingStructures = YES;
        
        [helpText setObjectText:@"Metal is needed to build more advanced craft and structures. You must have a refinery built to access the Refining menu. Build one and refine 200 brogguts into 20 Metal."];
    }
    return self;
}

- (BOOL)checkObjective {
    if ([[sharedGameController currentProfile] metalCount] >= 20) {
        return YES;
    } else {
        return NO;
    }
}

@end
