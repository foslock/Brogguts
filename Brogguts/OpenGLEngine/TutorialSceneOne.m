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
#import "FogManager.h"

NSString* kIntroSceneText[TUTORIAL_INTRO_LINE_COUNT] = {
    @"Long ago, when humans only lived on one planet.",
    @"the population started to grow beyond the Earth's capacity.",
    @"Landfills were overflowing with trash,",
    @"which eventually forced the colonization of other planets.",
    @"Inevitably the same happened, and as a result we ",
    @"took to jettisoning all our trash into the empty void of space.",
    @"Hundreds of years past that, the trash had accumulated ",
    @"and started forming large masses in space.",
    @"One day a single invention changed the galaxy:",
    @"A process that could convert any of this trash back into energy.",
    @"Instantly, the trash became a valuable commodity,",
    @"and someone coined the pseudonym 'Brogguts'.",
    @"Companies were formed solely around mining",
    @"and selling millions of these Brogguts.",
    @"Pirating and rogue colonies soon found their way into the picture.",
    @"Power struggles between the corporations and pirating factions have",
    @"recently divided the universe into two distinct sides.",
    @"Collect as many Brogguts as you can...",
    @"...and maybe you will be the next to make a real difference.",
};

@implementation TutorialSceneOne

- (void)dealloc {
    [textObjects release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:0];
    if (self) {        
        isHoldingTouch = NO;
        introIsOver = NO;
        isAllowingSidebar = NO;
        holdLocation = CGPointZero;
        textObjects = [[NSMutableArray alloc] init];
        totalTextHeight = 32.0f + (TUTORIAL_INTRO_SPACE_BETWEEN_LINES * TUTORIAL_INTRO_LINE_COUNT);
        scrollTextAmount = 0.0f;
        
        for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
            float xLoc = (kPadScreenLandscapeWidth - [self getWidthForFontID:kFontBlairID withString:kIntroSceneText[i]]) / 2;
            TextObject* introText = [[TextObject alloc] initWithFontID:kFontBlairID
                                                                  Text:kIntroSceneText[i]
                                                          withLocation:CGPointMake(xLoc, -32 - (TUTORIAL_INTRO_SPACE_BETWEEN_LINES * i))
                                                          withDuration:-1.0f];
            [self addTextObject:introText];
            [textObjects addObject:introText];
        }
        [fogManager clearAllFog];
    }
    return self;
}

- (BOOL)checkObjective {
    return introIsOver;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (!isHoldingTouch) {
        scrollTextAmount += TUTORIAL_INTRO_SCROLL_SPEED;
    } else {
        scrollTextAmount = CLAMP(scrollTextAmount, 0.0f, (totalTextHeight + visibleScreenBounds.size.height + 32.0f));
    }
    
    float diff = 0.0f;
    for (int i = 0; i < TUTORIAL_INTRO_LINE_COUNT; i++) {
        TextObject* introText = [textObjects objectAtIndex:i];
        CGPoint point = introText.objectLocation;
        [introText setObjectLocation:CGPointMake(introText.objectLocation.x, -32 - (TUTORIAL_INTRO_SPACE_BETWEEN_LINES * i) + scrollTextAmount)];
        CGPoint afterPoint = introText.objectLocation;
        diff = afterPoint.y - point.y;
        
    }
    [sharedStarSingleton scrollStarsWithVector:Vector2fMake(0.0f, diff)];
    
    if (scrollTextAmount > (totalTextHeight + visibleScreenBounds.size.height)) {
        introIsOver = YES;
    }
    
    [super updateSceneWithDelta:aDelta];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(id)event view:(id)aView {
    isHoldingTouch = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(id)event view:(id)aView {
    if (isHoldingTouch) {
        UITouch* touch = [touches anyObject];
        CGPoint point = [sharedGameController adjustTouchOrientationForTouch:[touch locationInView:aView] inScreenBounds:CGRectZero];
        CGPoint prevPoint = [sharedGameController adjustTouchOrientationForTouch:[touch previousLocationInView:aView] inScreenBounds:CGRectZero];
        float diff = (point.y - prevPoint.y);
        scrollTextAmount += diff;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(id)event view:(id)aView {
    isHoldingTouch = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(id)event view:(id)aView {
    isHoldingTouch = NO;
}

@end
