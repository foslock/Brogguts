//
//  TutorialScene.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BroggutScene.h"
#import "NotificationObject.h"

#define TUTORIAL_SCENES_COUNT 11

extern NSString* kTutorialSceneFileNames[TUTORIAL_SCENES_COUNT];

@class TriggerObject;

@interface TutorialScene : BroggutScene {
    int tutorialIndex; 
    NSString* nextSceneName;
    BOOL isObjectiveComplete;
}

- (id)initWithTutorialIndex:(int)tutIndex;
- (BOOL)checkObjective;

@end
