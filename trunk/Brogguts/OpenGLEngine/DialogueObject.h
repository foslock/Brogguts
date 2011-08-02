//
//  DialogueObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DIALOGUE_SKIP_TIMER 1.5f

enum kDialogueDimensionValues {
    kDialogueDimensionTotalWidth = 600,
    kDialogueDimensionTotalHeight = 304,
    kDialogueDimensionPortraitWidth = 200,
    kDialogueDimensionDialogueWidth = 400,
};

// Portrait images should be 152 x 256

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
    TextObject* dialogueTextObject;
    AnimatedImage* portraitImage;
    TiledButtonObject* fadedBackgroundImage;
    TiledButtonObject* portraitBackgroundImage;
    TiledButtonObject* dialogueBackgroundImage;
}

@property (nonatomic, assign) float dialogueActivateTime;
@property (nonatomic, assign) int dialogueImageIndex;
@property (nonatomic, copy) NSString* dialogueText;
@property (nonatomic, assign) BOOL hasBeenDismissed;

- (BOOL)shouldDisplayDialogueObjectWithTotalTime:(float)sceneTime;
- (void)updateDialogueObjectWithDelta:(float)aDelta;
- (void)renderDialogueObjectWithFont:(BitmapFont*)font;

// Used for saving/loading
- (id)initWithInfoArray:(NSArray*)infoArray;
- (NSArray*)infoArrayFromDialogue;

@end