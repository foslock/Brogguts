//
//  TutorialSceneOne.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneOne.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "Primitives.h"
#import "TextObject.h"
#import "TiledButtonObject.h"

NSString* kIntroSceneText[TUTORIAL_INTRO_LINE_COUNT] = {
    @"Space is polluted",
    @"Yada yada yada",
    @"You must build an empire and clean it",
    @"Space trash = brogguts",
    @"Blah blah blah",
    @"Evil pirates will try and take over your station",
    @"Kill them before they kill you",
    @"Blah blah blah...",
    @"Almost there...",
    @"Finally, end of the intro.",
};

@implementation TutorialSceneOne

- (id)init {
    self = [super initWithTutorialIndex:0];
    if (self) {        
        skipTimer = 0;
        isHoldingTouch = NO;
        introIsOver = NO;
        holdLocation = CGPointZero;
        for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
            float xLoc = (kPadScreenLandscapeWidth - [self getWidthForFontID:kFontBlairID withString:kIntroSceneText[i]]) / 2;
            TextObject* introText = [[TextObject alloc] initWithFontID:kFontBlairID
                                                                  Text:kIntroSceneText[i]
                                                          withLocation:CGPointMake(xLoc, -32 - (TUTORIAL_INTRO_SPACE_BETWEEN_LINES * i))
                                                          withDuration:TUTORIAL_INTRO_TEXT_TIME];
            
            [introText setObjectVelocity:Vector2fMake(0.0f, TUTORIAL_INTRO_SCROLL_SPEED)];
            [self addTextObject:introText];
        }
        textTimer = TUTORIAL_INTRO_TEXT_TIME;
    }
    return self;
}

- (BOOL)checkObjective {
    return introIsOver;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (textTimer > 0.0f) {
        textTimer -= aDelta;
    } else {
        textTimer = 0.0f;
        introIsOver = YES;
    }
    
    [super updateSceneWithDelta:aDelta];
}

- (void)renderScene {
    [super renderScene];
    
    if (isHoldingTouch) {
        skipTimer++;
        Circle newCircle;
        newCircle.x = holdLocation.x;
        newCircle.y = holdLocation.y;
        newCircle.radius = 64.0f;
        enablePrimitiveDraw();
        glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
        glLineWidth(3.0f);
        drawPartialDashedCircle(newCircle,
                                (skipTimer / (float)TUTORIAL_INTRO_SKIP_TIME) * TUTORIAL_SKIP_CIRCLE_SEGMENTS,
                                TUTORIAL_SKIP_CIRCLE_SEGMENTS,
                                Color4fOnes,
                                Color4fMake(0.0f, 0.0f, 0.0f, 0.0f),
                                Vector2fZero);
        glLineWidth(1.0f);
        disablePrimitiveDraw();
    }
    
    if (skipTimer >= TUTORIAL_INTRO_SKIP_TIME) {
        introIsOver = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(id)event view:(id)aView {
    isHoldingTouch = YES;
    UITouch* touch = [touches anyObject];
    CGPoint location = [[GameController sharedGameController] adjustTouchOrientationForTouch:[touch locationInView:aView] inScreenBounds:visibleScreenBounds];
    holdLocation = location;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(id)event view:(id)aView {
    skipTimer = 0;
    isHoldingTouch = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(id)event view:(id)aView {
    isHoldingTouch = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(id)event view:(id)aView {
    skipTimer = 0;
    isHoldingTouch = NO;
}

@end
