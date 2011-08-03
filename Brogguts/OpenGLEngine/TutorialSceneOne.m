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
#import "StarSingleton.h"

NSString* kIntroSceneText[TUTORIAL_INTRO_LINE_COUNT] = {
    @"Hundreds of years in the future, the human ",
    @" population grows beyond the planet's capacity.",
    @"Landfills were overflowing with our trash, ",
    @" eventually forcing the colonization of other planets.",
    @"Inevitably the same happened, and as a result we ",
    @" took to jettisoning all our trash into space.",
    @"Thousands of years past that, the trash had accumulated ",
    @" and started forming large masses in space.",
    @"One day a single invention changed the galaxy: ",
    @" A process that could convert any of this trash back into energy.",
    @"Instantly, the trash became a valuable commodity, ",
    @" and received the nickname 'Brogguts'.",
    @"Companies were formed solely around mining ",
    @" and selling millions of these Brogguts.",
    @"Pirating and rogue missions soon found their way into the picture.",
    @"Brogguts have become what all desire. ",
    @" Struggles, and even war have erupted over just a few mining operations.",
    @"You are an overseer of one of these large companies smaller base stations.",
    @"Collect as many Brogguts as you can...",
    @"...and maybe you will be the next to make a difference in this world.",
};

@implementation TutorialSceneOne

- (void)dealloc {
    [textObjects release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:0];
    if (self) {        
        skipTimer = 0;
        isHoldingTouch = NO;
        introIsOver = NO;
        isAllowingSidebar = NO;
        holdLocation = CGPointZero;
        textObjects = [[NSMutableArray alloc] init];
        for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
            float xLoc = (kPadScreenLandscapeWidth - [self getWidthForFontID:kFontBlairID withString:kIntroSceneText[i]]) / 2;
            TextObject* introText = [[TextObject alloc] initWithFontID:kFontBlairID
                                                                  Text:kIntroSceneText[i]
                                                          withLocation:CGPointMake(xLoc, -32 - (TUTORIAL_INTRO_SPACE_BETWEEN_LINES * i))
                                                          withDuration:TUTORIAL_INTRO_TEXT_TIME];
            
            [introText setObjectVelocity:Vector2fMake(0.0f, TUTORIAL_INTRO_SCROLL_SPEED)];
            [self addTextObject:introText];
            [textObjects addObject:introText];
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
    
    if (isHoldingTouch) {
        Vector2f scrollingVector = Vector2fMake(0.0f, TUTORIAL_INTRO_SCROLL_SPEED_FAST);
        for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
            TextObject* introText = [textObjects objectAtIndex:i];
            textTimer -= aDelta;
            [introText setObjectVelocity:scrollingVector];
        }
        [sharedStarSingleton scrollStarsWithVector:scrollingVector];
    } else {
        Vector2f scrollingVector = Vector2fMake(0.0f, TUTORIAL_INTRO_SCROLL_SPEED);
        for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
            TextObject* introText = [textObjects objectAtIndex:i];
            
            [introText setObjectVelocity:scrollingVector];
        }
        [sharedStarSingleton scrollStarsWithVector:scrollingVector];
    }
    
    [super updateSceneWithDelta:aDelta];
}

- (void)renderScene {
    [super renderScene];
    /*
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
        // introIsOver = YES;
    }
     */
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
