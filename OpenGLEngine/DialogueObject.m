//
//  DialogueObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "DialogueObject.h"
#import "TextObject.h"
#import "BitmapFont.h"
#import "TiledButtonObject.h"
#import "ImageRenderSingleton.h"
#import "Image.h"
#import "AnimatedImage.h"

#define TILED_BACKGROUND_INSET_AMOUNT 12.0f
#define DIALOUGE_PORTRAIT_COUNT 2

NSString* const kDialogueDismissalString = @"(Hold to Dismiss)";

NSString* const kDialougePortraitFilenames[DIALOUGE_PORTRAIT_COUNT] = {
    @"defaultportrait.png",
    @"anon.png",
};

int const kDialougePortraitImageCount[DIALOUGE_PORTRAIT_COUNT] = {
    4,
    5,
};

@implementation DialogueObject
@synthesize dialogueActivateTime, dialogueText, hasBeenDismissed;
@synthesize isWantingToBeDismissed;

- (void)dealloc {
    [dialogueText release];
    [dialogueTextObject release];
    [dialogueBackgroundImage release];
    [fadedBackgroundImage release];
    [portraitBackgroundImage release];
    [portraitImage release];
    [super dealloc];
}

- (void)initializeMe {
    CGPoint screenCenter = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    
    totalRect = CGRectMake(screenCenter.x - (kDialogueDimensionTotalWidth/2),
                           screenCenter.y - (kDialogueDimensionTotalHeight/2), 
                           kDialogueDimensionTotalWidth, 
                           kDialogueDimensionTotalHeight);
    
    CGRect portraitRect = CGRectMake(totalRect.origin.x,
                                     screenCenter.y - (kDialogueDimensionTotalHeight/2), 
                                     kDialogueDimensionPortraitWidth, 
                                     kDialogueDimensionTotalHeight);
    
    CGRect dialogueRect = CGRectMake(totalRect.origin.x + kDialogueDimensionPortraitWidth,
                                     screenCenter.y - (kDialogueDimensionTotalHeight/2), 
                                     kDialogueDimensionDialogueWidth, 
                                     kDialogueDimensionTotalHeight);
    
    portraitImage = [[AnimatedImage alloc]
                     initWithFileName:kDialougePortraitFilenames[kDialoguePortraitBase]
                     withSubImageCount:kDialougePortraitImageCount[kDialoguePortraitBase]];
    [portraitImage setAnimationSpeed:0.05f];
    CGSize imageSize = [portraitImage imageSize];
    float desiredWidth = (float)kDialogueDimensionPortraitWidth - (2 * BUTTON_UNSCALED_SIZE);
    float desiredHeight = (float)kDialogueDimensionTotalHeight - (2 * BUTTON_UNSCALED_SIZE);
    isWantingToBeDismissed = NO;
    isZoomingBoxIn = YES;
    isZoomingBoxOut = NO;
    isShowingHoldToDismiss = YES;
    zoomingCounterMax = kDialogueDimensionTotalWidth / BUTTON_SCALED_SIZE;
    zoomingCounter = kDialogueDimensionTotalWidth / BUTTON_SCALED_SIZE;
    
    [portraitImage setScale:Scale2fMake((desiredWidth / imageSize.width),
                                        (desiredHeight / imageSize.height))];
    
    dialogueTextObject = [[TextObject alloc] initWithFontID:kFontGothicID
                                                       Text:dialogueText
                                               withLocation:CGPointMake(dialogueRect.origin.x + 26.0f,
                                                                        dialogueRect.origin.y + dialogueRect.size.height - 48.0f)
                                               withDuration:-1.0f];
    [dialogueTextObject setTextWidthLimit:kDialogueDimensionDialogueWidth - 62.0f];
    
    fadedBackgroundImage = [[TiledButtonObject alloc] initWithRect:totalRect];
    [fadedBackgroundImage setColor:Color4fMake(0.65f, 0.65f, 0.65f, 1.0f)];
    portraitBackgroundImage = [[TiledButtonObject alloc] initWithRect:CGRectInset(portraitRect,
                                                                                  TILED_BACKGROUND_INSET_AMOUNT,TILED_BACKGROUND_INSET_AMOUNT)];
    [portraitBackgroundImage setColor:Color4fMake(0.75f, 0.75f, 0.75f, 1.0f)];
    dialogueBackgroundImage = [[TiledButtonObject alloc] initWithRect:CGRectInset(dialogueRect,
                                                                                  TILED_BACKGROUND_INSET_AMOUNT,TILED_BACKGROUND_INSET_AMOUNT)];
    [dialogueBackgroundImage setColor:Color4fMake(0.75f, 0.75f, 0.75f, 1.0f)];
    
    [fadedBackgroundImage setRenderLayer:kLayerHUDBottomLayer];
    [portraitBackgroundImage setRenderLayer:kLayerHUDMiddleLayer];
    [dialogueBackgroundImage setRenderLayer:kLayerHUDMiddleLayer];
    [dialogueTextObject setRenderLayer:kLayerHUDTopLayer];
    [portraitImage setRenderLayer:kLayerHUDTopLayer];
}

- (void)setDialogueText:(NSString *)newText {
    [dialogueText autorelease];
    dialogueText = [newText copy];
    [dialogueTextObject setObjectText:dialogueText];
}

- (void)setDialogueImageIndex:(enum kDialoguePortraitImages)index {
    NSString* filename = kDialougePortraitFilenames[index];
    if (portraitImage) {
        [portraitImage release];
    }
    portraitImage = [[AnimatedImage alloc] initWithFileName:filename
                                          withSubImageCount:kDialougePortraitImageCount[index]];
    [portraitImage setAnimationSpeed:0.05f];
    CGSize imageSize = [portraitImage imageSize];
    float desiredWidth = (float)kDialogueDimensionPortraitWidth - (2 * BUTTON_UNSCALED_SIZE);
    float desiredHeight = (float)kDialogueDimensionTotalHeight - (2 * BUTTON_UNSCALED_SIZE);    
    [portraitImage setScale:Scale2fMake((desiredWidth / imageSize.width),
                                        (desiredHeight / imageSize.height))];
    [portraitImage setRenderLayer:kLayerHUDTopLayer];
}

- (id)init {
    self = [super init];
    if (self) {
        isCurrentlyActive = NO;
        hasBeenDismissed = NO;
        dialogueActivateTime = MAXFLOAT;
        dialogueImageIndex = 0;
        self.dialogueText = [NSString string];
        [self initializeMe];
    }
    return self;
}

// Used for saving/loading
- (id)initWithInfoArray:(NSArray*)infoArray {
    self = [super init];
    if (self) {
        isCurrentlyActive = NO; // Can't be loaded active
        hasBeenDismissed = [[infoArray objectAtIndex:1] boolValue];
        dialogueActivateTime = [[infoArray objectAtIndex:2] floatValue];
        dialogueImageIndex = [[infoArray objectAtIndex:3] intValue];
        self.dialogueText = [infoArray objectAtIndex:4];
        
        [self initializeMe];
    }
    return self;
}


- (NSArray*)infoArrayFromDialogue {
    NSMutableArray* infoArray = [[NSMutableArray alloc] init];
    /*
     isCurrentlyActive = NO;
     hasBeenDismissed = NO;
     dialogueActivateTime = MAXFLOAT;
     dialogueImageIndex = 0;
     self.dialogueText = [NSString string];
     */
    
    NSNumber* activeNumber = [NSNumber numberWithBool:isCurrentlyActive];
    NSNumber* dismissedNumber = [NSNumber numberWithBool:hasBeenDismissed];
    NSNumber* dialogueTimeNumber = [NSNumber numberWithFloat:dialogueActivateTime];
    NSNumber* dialogueImageNumber = [NSNumber numberWithInt:dialogueImageIndex];
    NSString* dialogueString = [NSString stringWithString:dialogueText];
    
    [infoArray addObject:activeNumber];
    [infoArray addObject:dismissedNumber];
    [infoArray addObject:dialogueTimeNumber];
    [infoArray addObject:dialogueImageNumber];
    [infoArray addObject:dialogueString];
    
    return [infoArray autorelease];
}

- (BOOL)shouldDisplayDialogueObjectWithTotalTime:(float)sceneTime {
    if ( (sceneTime >= dialogueActivateTime) && (!isCurrentlyActive) ) {
        if (!hasBeenDismissed) {
            isCurrentlyActive = YES;
            return YES;
        }
    }
    return NO;
}

- (void)setHasBeenDismissed:(BOOL)dismissed {
    if (isCurrentlyActive && dismissed) {
        isCurrentlyActive = NO;
        isZoomingBoxIn = NO;
        zoomingCounter = 0;
        isZoomingBoxOut = YES;
    }
    hasBeenDismissed = dismissed;
}

- (void)updateDialogueObjectWithDelta:(float)aDelta {
    if (!isZoomingBoxIn && !isZoomingBoxOut) {
        [portraitImage updateAnimatedImageWithDelta:aDelta];
    }
    
    if (isZoomingBoxIn) {
        zoomingCounter--;
        CGRect thisRect = CGRectInset(totalRect, BUTTON_SCALED_SIZE * zoomingCounter, 0);
        [fadedBackgroundImage setDrawRect:thisRect];
        if (zoomingCounter <= 0) {
            isZoomingBoxIn = NO;
            zoomingCounter = 0;
        }
    }
    
    if (isZoomingBoxOut) {
        zoomingCounter++;
        CGRect thisRect = CGRectInset(totalRect, BUTTON_SCALED_SIZE * zoomingCounter, 0);
        [fadedBackgroundImage setDrawRect:thisRect];
        if (zoomingCounter >= zoomingCounterMax) {
            isZoomingBoxOut = NO;
            zoomingCounter = zoomingCounterMax;
        }
    }
}

- (void)renderDialogueObjectWithFont:(BitmapFont*)font {
    [fadedBackgroundImage renderCenteredAtPoint:fadedBackgroundImage.objectLocation
                               withScrollVector:Vector2fZero];
    if (!isZoomingBoxIn && !isZoomingBoxOut) {
        [portraitBackgroundImage renderCenteredAtPoint:portraitBackgroundImage.objectLocation 
                                      withScrollVector:Vector2fZero];
        [dialogueBackgroundImage renderCenteredAtPoint:dialogueBackgroundImage.objectLocation
                                      withScrollVector:Vector2fZero];
        
        [dialogueTextObject renderWithFont:font];
        [portraitImage renderCurrentSubImageAtPoint:portraitBackgroundImage.objectLocation];
        if (isShowingHoldToDismiss) {
            [font setFontColor:Color4fMake(1.0f, 1.0f, 1.0f, 0.8f)];
            float width = [font getWidthForString:kDialogueDismissalString];
            [font renderStringAt:CGPointMake((kPadScreenLandscapeWidth-width)/2, kPadScreenLandscapeHeight*(1.0f/4.0f)) text:kDialogueDismissalString onLayer:kLayerHUDTopLayer];
        }
    }
}

- (void)presentDialogue {
    [self setDialogueActivateTime:0.0f];
}

- (void)touchesBeganAtLocation:(CGPoint)location {
    
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
    
}

- (void)touchesEndedAtLocation:(CGPoint)location {
    
}

@end
