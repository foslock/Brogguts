//
//  DialogueObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DIALOGUE_SKIP_TIMER 1.0f

enum kDialogueDimensionValues {
    kDialogueDimensionTotalWidth = 600,
    kDialogueDimensionTotalHeight = 304,
    kDialogueDimensionPortraitWidth = 200,
    kDialogueDimensionDialogueWidth = 400,
};

// Portrait images should be 152 x 256
enum kDialoguePortraitImages {
    kDialoguePortraitBase,
    kDialoguePortraitAnon,
};

@class TiledButtonObject;
@class TextObject;
@class BitmapFont;
@class AnimatedImage;

@interface DialogueObject : NSObject {
    // Saved information
    BOOL isCurrentlyActive;
    BOOL hasBeenDismissed;
    float dialogueActivateTime;
    int dialogueImageIndex;
    NSString* dialogueText;
    
    // Dynamic stuff that doesn't need to be saved
    BOOL isWantingToBeDismissed;
    BOOL isZoomingBoxIn;
    BOOL isZoomingBoxOut;
    BOOL isShowingHoldToDismiss;
    int zoomingCounterMax;
    int zoomingCounter;
    CGRect totalRect;
    TextObject* dialogueTextObject;
    AnimatedImage* portraitImage;
    TiledButtonObject* fadedBackgroundImage;
    TiledButtonObject* portraitBackgroundImage;
    TiledButtonObject* dialogueBackgroundImage;
}

@property (nonatomic, assign) float dialogueActivateTime;
@property (nonatomic, copy) NSString* dialogueText;
@property (readonly) BOOL isWantingToBeDismissed;
@property (nonatomic, assign) BOOL hasBeenDismissed;

- (void)initializeMe;

- (BOOL)shouldDisplayDialogueObjectWithTotalTime:(float)sceneTime;
- (void)updateDialogueObjectWithDelta:(float)aDelta;
- (void)renderDialogueObjectWithFont:(BitmapFont*)font;
- (void)presentDialogue;

- (void)setDialogueImageIndex:(enum kDialoguePortraitImages)index;

// Used for saving/loading
- (id)initWithInfoArray:(NSArray*)infoArray;
- (NSArray*)infoArrayFromDialogue;

- (void)touchesBeganAtLocation:(CGPoint)location;
- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation;
- (void)touchesEndedAtLocation:(CGPoint)location;

@end
