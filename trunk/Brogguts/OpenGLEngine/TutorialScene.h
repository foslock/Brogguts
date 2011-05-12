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

#define TUTORIAL_SCENES_COUNT 13
#define TUTORIAL_HELP_FONT kFontBlairID
#define TUTORIAL_HELP_TEXT_SCROLL_SPEED 1.5f

extern NSString* kTutorialSceneFileNames[TUTORIAL_SCENES_COUNT];

@class TriggerObject;
@class TextObject;

@interface TutorialScene : BroggutScene {
    int tutorialIndex; 
    NSString* nextSceneName;
    BOOL isObjectiveComplete;
    TextObject* helpText;
    Image* blackBar;
    CGRect helpTextRect;
}

- (id)initWithTutorialIndex:(int)tutIndex;
- (BOOL)checkObjective;

@end
