//
//  TutorialSceneEleven.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/17/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneEleven.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneEleven

- (id)init {
    self = [super initWithTutorialIndex:10];
    if (self) {
        isAllowingOverview = YES;
        isShowingBroggutCount = YES;
        isAllowingSidebar = YES;
        isAllowingCraft = YES;
        isAllowingStructures = NO;
        
        [helpText setObjectText:@"Tap the button in the top left to open the auxilury menu, select craft, and drag the craft you want onto the screen, then it will travel to that location. Create three new Ants. Make sure you have enough brogguts!"];
    }
    return self;
}

- (BOOL)checkObjective {
    if (numberOfCurrentShips >= 4)
        return YES;
    else
        return NO;
}

@end
