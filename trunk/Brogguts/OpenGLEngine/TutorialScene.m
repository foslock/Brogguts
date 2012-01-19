//
//  TutorialScene.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialScene.h"
#import "GameController.h"
#import "TriggerObject.h"
#import "TextObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "DialogueObject.h"
#import "MainMenuController.h"

NSString* kTutorialSceneFileNames[TUTORIAL_SCENES_COUNT] = {
    @"Tutorial 1",
    @"Tutorial 2",
    @"Tutorial 3",
    @"Tutorial 4",
    @"Tutorial 5",
    @"Tutorial 6",
    @"Tutorial 7",
    @"Tutorial 8",
    @"Tutorial 9",
    @"Tutorial 10",
    @"Tutorial 11",
    @"Tutorial 12",
    @"Tutorial 13",
};


@implementation TutorialScene

- (void)dealloc {
    [blackBar release];
    [helpText release];
    [nextSceneName release];
    [super dealloc];
}

- (id)initWithTutorialIndex:(int)tutIndex {
    self = [super initWithFileName:kTutorialSceneFileNames[tutIndex] wasLoaded:NO];
    if (self) {
        if (tutIndex >= TUTORIAL_SCENES_COUNT - 1) {
            nextSceneName = [[kBaseCampFileName stringByDeletingPathExtension] copy];
        } else {
            nextSceneName = kTutorialSceneFileNames[tutIndex+1];
        }
        sceneType = kSceneTypeTutorial;
        tutorialIndex = tutIndex;
        isObjectiveComplete = NO;
        helpTextPoint = CGPointMake(visibleScreenBounds.size.width,
                                    (COLLISION_CELL_HEIGHT / 2));
        helpText = [[TextObject alloc] initWithFontID:TUTORIAL_HELP_FONT
                                                 Text:@""
                                         withLocation:helpTextPoint
                                         withDuration:-1.0f];
        [helpText setScrollWithBounds:NO];
        [helpText setRenderLayer:kLayerHUDMiddleLayer];
        [self addTextObject:helpText];
        scrolledTextAmount = 0.0f;
        isTouchMovingText = NO;
        
        blackBar = [[Image alloc] initWithImageNamed:@"blackpixel.png" filter:GL_LINEAR];
        [blackBar setRenderLayer:kLayerHUDBottomLayer];
        [blackBar setColor:Color4fMake(0.0f, 0.0f, 0.0f, 0.75f)];
        
        // Turn off the complicated stuff
        isShowingBroggutCount = NO;
        isShowingMetalCount = NO;
        isShowingSupplyCount = NO;
        isAllowingOverview = NO;
        isAllowingCraft = NO;
        isAllowingStructures = NO;
        
        hasAddedTutorialDialogue = NO;
    }
    return self;
}

- (void)sceneDidAppear {
    [super sceneDidAppear];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:tutorialIndex forKey:kTutorialExperienceKey];
    [defaults synchronize];
}

- (void)sceneDidDisappear {
    [super sceneDidDisappear];
    if (tutorialIndex == TUTORIAL_SCENES_COUNT - 1) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:0 forKey:kTutorialExperienceKey];
        [defaults synchronize];
    }
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (!hasAddedTutorialDialogue && tutorialIndex != 0) {
        hasAddedTutorialDialogue = YES;
        /*
         DialogueObject* dia = [[DialogueObject alloc] init];
         [dia setDialogueActivateTime:0.0f];
         [dia setDialogueImageIndex:kDialoguePortraitBase];
         [dia setDialogueText:helpText.objectText];
         [sceneDialogues addObject:dia];
         [dia release];
         */
    }
    
    if (!isTouchMovingText) {
        scrolledTextAmount -= TUTORIAL_HELP_TEXT_ACCELERATION;
        scrolledTextAmount = CLAMP(scrolledTextAmount, -TUTORIAL_HELP_TEXT_SCROLL_SPEED, TUTORIAL_HELP_TEXT_SCROLL_SPEED);
    }
    
    if (helpText.objectLocation.x > -[self getWidthForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]]) {
        helpTextPoint = CGPointMake(helpTextPoint.x + scrolledTextAmount, helpTextPoint.y);
    } else {
        helpTextPoint = CGPointMake(visibleScreenBounds.size.width, helpTextPoint.y);
    }
    
    [blackBar setScale:Scale2fMake(kPadScreenLandscapeWidth, [self getHeightForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]] + 2.0f)];
    
    [helpText setObjectLocation:helpTextPoint];
    
    if ([self checkObjective]) {
        if (!isObjectiveComplete) {
            isObjectiveComplete = YES;
            if (tutorialIndex < TUTORIAL_SCENES_COUNT - 1) {
                [[GameController sharedGameController] fadeOutToSceneWithFilename:nextSceneName sceneType:kSceneTypeTutorial withIndex:tutorialIndex + 1 isNew:YES isLoading:NO];
            } else {
                [[GameController sharedGameController] fadeOutToSceneWithFilename:nextSceneName sceneType:kSceneTypeBaseCamp withIndex:0 isNew:YES isLoading:YES];
            }
            return;
        }
    }
    [super updateSceneWithDelta:aDelta];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    UITouch* touch = [touches anyObject];
    CGPoint originalTouchLocation = [touch locationInView:aView];
    CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
    if (touchLocation.y <= [helpText objectLocation].y + [self getHeightForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]] + 2.0f) {
        isTouchMovingText = YES;
        scrolledTextAmount = 0.0f;
    } else {
        [super touchesBegan:touches withEvent:event view:aView];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isTouchMovingText) {
        UITouch* touch = [touches anyObject];
        CGPoint originalTouchLocation = [touch locationInView:aView];
        CGPoint originalPrevTouchLocation = [touch previousLocationInView:aView];
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation inScreenBounds:CGRectZero];
        CGPoint prevTouchLocation = [sharedGameController adjustTouchOrientationForTouch:originalPrevTouchLocation inScreenBounds:CGRectZero];
        float diff = (touchLocation.x - prevTouchLocation.x);
        helpTextPoint = CGPointMake(helpTextPoint.x + diff, helpTextPoint.y);
        if (helpTextPoint.x > visibleScreenBounds.size.width) {
            helpTextPoint = CGPointMake(-[self getWidthForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]], helpTextPoint.y);
        }
        scrolledTextAmount = 0.0f;
    } else {
        [super touchesMoved:touches withEvent:event view:aView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isTouchMovingText) {
        isTouchMovingText = NO;
    } else {
        [super touchesEnded:touches withEvent:event view:aView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *)aView {
    if (isTouchMovingText) {
        isTouchMovingText = NO;
    } else {
        [super touchesCancelled:touches withEvent:event view:aView];
    }
}

- (void)renderScene {
    [blackBar renderAtPoint:CGPointMake(0.0f, [helpText objectLocation].y - 3.0f)];
    [super renderScene];
}

- (BOOL)checkObjective {
    // OVERRIDE, return YES if the objective is complete, and the level should transition.
    return NO;
}

@end
