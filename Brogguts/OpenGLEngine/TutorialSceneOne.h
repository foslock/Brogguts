//
//  TutorialSceneOne.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialScene.h"

#define TUTORIAL_INTRO_SCROLL_SPEED 0.2f
#define TUTORIAL_INTRO_LINE_COUNT 20
#define TUTORIAL_INTRO_SPACE_BETWEEN_LINES 48.0f

extern NSString* kIntroSceneText[TUTORIAL_INTRO_LINE_COUNT];

@class TextObject;

@interface TutorialSceneOne : TutorialScene {
    NSMutableArray* textObjects;
    BOOL isHoldingTouch;
    float scrollTextAmount;
    float totalTextHeight;
    CGPoint holdLocation;
    BOOL introIsOver;
}

@end
