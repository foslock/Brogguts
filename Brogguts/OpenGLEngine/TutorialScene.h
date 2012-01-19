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
#import "FogManager.h"

#define TUTORIAL_SCENES_COUNT 13
#define TUTORIAL_HELP_FONT kFontBlairID
#define TUTORIAL_HELP_TEXT_SCROLL_SPEED 1.5f
#define TUTORIAL_HELP_TEXT_ACCELERATION 0.1f

extern NSString* kTutorialSceneFileNames[TUTORIAL_SCENES_COUNT];

@class TriggerObject;
@class TextObject;

@interface TutorialScene : BroggutScene {
    int tutorialIndex; 
    NSString* nextSceneName;
    BOOL isObjectiveComplete;
    BOOL hasAddedTutorialDialogue;
    TextObject* helpText;
    float scrolledTextAmount;
    BOOL isTouchMovingText;
    Image* blackBar;
    CGPoint helpTextPoint;
}

- (id)initWithTutorialIndex:(int)tutIndex;
- (BOOL)checkObjective;

@end
