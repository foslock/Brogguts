//
//  TutorialSceneOne.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialScene.h"

#define TUTORIAL_INTRO_SKIP_TIME 100
#define TUTORIAL_SKIP_CIRCLE_SEGMENTS 40
#define TUTORIAL_INTRO_TEXT_TIME 120.0f
#define TUTORIAL_INTRO_SCROLL_SPEED 0.18f
#define TUTORIAL_INTRO_SCROLL_SPEED_FAST 2.0f
#define TUTORIAL_INTRO_LINE_COUNT 20
#define TUTORIAL_INTRO_SPACE_BETWEEN_LINES 48.0f

extern NSString* kIntroSceneText[TUTORIAL_INTRO_LINE_COUNT];

@class TextObject;

@interface TutorialSceneOne : TutorialScene {
    NSMutableArray* textObjects;
    int skipTimer;
    float textTimer;
    BOOL isHoldingTouch;
    CGPoint holdLocation;
    BOOL introIsOver;
}

@end
