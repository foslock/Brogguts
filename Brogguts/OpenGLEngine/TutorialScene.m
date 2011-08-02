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
        helpTextRect = CGRectMake(visibleScreenBounds.size.width,
                                  (COLLISION_CELL_HEIGHT / 2),
                                  1, 1);
        helpText = [[TextObject alloc] initWithFontID:TUTORIAL_HELP_FONT
                                                 Text:@"" 
                                             withRect:helpTextRect
                                         withDuration:-1.0f];
        [helpText setScrollWithBounds:NO];
        [helpText setRenderLayer:kLayerHUDMiddleLayer];
        [self addTextObject:helpText];
        
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

- (void)updateSceneWithDelta:(float)aDelta {
    if (!hasAddedTutorialDialogue && tutorialIndex != 0) {
        hasAddedTutorialDialogue = YES;
        /*
        DialogueObject* dia = [[DialogueObject alloc] init];
        [dia setDialogueActivateTime:0.0f];
        [dia setDialogueImageIndex:0];
        [dia setDialogueText:helpText.objectText];
        [sceneDialogues addObject:dia];
        [dia release];
         */
    }
    
    if (helpTextRect.origin.x > -[self getWidthForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]]) {
        helpTextRect = CGRectOffset(helpTextRect, -TUTORIAL_HELP_TEXT_SCROLL_SPEED, 0);
    } else {
        helpTextRect = CGRectMake(visibleScreenBounds.size.width,
                                  (COLLISION_CELL_HEIGHT / 2),
                                  1, 1);
    }
    [blackBar setScale:Scale2fMake(kPadScreenLandscapeWidth, [self getHeightForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]] + 2.0f)];
                                   
    [helpText setTextRect:helpTextRect];
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

- (void)renderScene {
    [blackBar renderAtPoint:CGPointMake(0.0f, [helpText objectLocation].y - ([self getHeightForFontID:TUTORIAL_HELP_FONT withString:[helpText objectText]] / 2) - 3.0f)];
    [super renderScene];
}

- (BOOL)checkObjective {
    // OVERRIDE, return YES if the objective is complete, and the level should transition.
    return NO;
}

@end
