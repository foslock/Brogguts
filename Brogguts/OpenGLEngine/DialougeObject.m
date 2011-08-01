//
//  DialougeObject.m
//  OpenGLEngine
//
//  Created by James Lockwood on 8/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "DialougeObject.h"
#import "TextObject.h"
#import "BitmapFont.h"
#import "TiledButtonObject.h"
#import "ImageRenderSingleton.h"
#import "Image.h"
#import "AnimatedImage.h"

#define TILED_BACKGROUND_INSET_AMOUNT 12.0f

@implementation DialougeObject
@synthesize dialougeActivateTime, dialougeImageIndex, dialougeText, hasBeenDismissed;

- (void)dealloc {
    [dialougeText release];
    [dialougeTextObject release];
    [dialougeBackgroundImage release];
    [fadedBackgroundImage release];
    [portraitBackgroundImage release];
    [portraitImage release];
    [super dealloc];
}

- (void)initializeMe {
    CGPoint screenCenter = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    
    CGRect totalRect = CGRectMake(screenCenter.x - (kDialougeDimensionTotalWidth/2),
                                  screenCenter.y - (kDialougeDimensionTotalHeight/2), 
                                  kDialougeDimensionTotalWidth, 
                                  kDialougeDimensionTotalHeight);
    
    CGRect portraitRect = CGRectMake(totalRect.origin.x,
                                     screenCenter.y - (kDialougeDimensionTotalHeight/2), 
                                     kDialougeDimensionPortraitWidth, 
                                     kDialougeDimensionTotalHeight);
    
    CGRect dialougeRect = CGRectMake(totalRect.origin.x + kDialougeDimensionPortraitWidth,
                                     screenCenter.y - (kDialougeDimensionTotalHeight/2), 
                                     kDialougeDimensionDialougeWidth, 
                                     kDialougeDimensionTotalHeight);
    
    portraitImage = [[AnimatedImage alloc] initWithFileName:@"" withSubImageCount:0];
    [portraitImage setAnimationSpeed:1.0f];
    dialougeTextObject = [[TextObject alloc] initWithFontID:kFontGothicID
                                                       Text:dialougeText
                                               withLocation:CGPointMake(dialougeRect.origin.x + 26.0f,
                                                                        dialougeRect.origin.y + dialougeRect.size.height - 48.0f)
                                               withDuration:-1.0f];
    [dialougeTextObject setTextWidthLimit:kDialougeDimensionDialougeWidth - 62.0f];
    
    fadedBackgroundImage = [[TiledButtonObject alloc] initWithRect:totalRect];
    [fadedBackgroundImage setColor:Color4fMake(0.6f, 0.6f, 0.6f, 1.0f)];
    portraitBackgroundImage = [[TiledButtonObject alloc] initWithRect:CGRectInset(portraitRect,
                                                                                  TILED_BACKGROUND_INSET_AMOUNT,TILED_BACKGROUND_INSET_AMOUNT)];
    [portraitBackgroundImage setColor:Color4fMake(0.85f, 0.85f, 0.85f, 1.0f)];
    dialougeBackgroundImage = [[TiledButtonObject alloc] initWithRect:CGRectInset(dialougeRect,
                                                                                  TILED_BACKGROUND_INSET_AMOUNT,TILED_BACKGROUND_INSET_AMOUNT)];
    [dialougeBackgroundImage setColor:Color4fMake(0.85f, 0.85f, 0.85f, 1.0f)];
    
    [fadedBackgroundImage setRenderLayer:kLayerHUDBottomLayer];
    [portraitBackgroundImage setRenderLayer:kLayerHUDMiddleLayer];
    [dialougeBackgroundImage setRenderLayer:kLayerHUDMiddleLayer];
    [dialougeTextObject setRenderLayer:kLayerHUDTopLayer];
    [portraitImage setRenderLayer:kLayerHUDTopLayer];
}

- (void)setDialougeText:(NSString *)newText {
    [dialougeText autorelease];
    dialougeText = [newText copy];
    [dialougeTextObject setObjectText:dialougeText];
}

- (id)init {
    self = [super init];
    if (self) {
        isCurrentlyActive = NO;
        hasBeenDismissed = NO;
        dialougeActivateTime = MAXFLOAT;
        dialougeImageIndex = 0;
        self.dialougeText = [NSString string];
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
        dialougeActivateTime = [[infoArray objectAtIndex:2] floatValue];
        dialougeImageIndex = [[infoArray objectAtIndex:3] intValue];
        self.dialougeText = [infoArray objectAtIndex:4];
        
        [self initializeMe];
    }
    return self;
}


- (NSArray*)infoArrayFromDialouge {
    NSMutableArray* infoArray = [[NSMutableArray alloc] init];
    /*
    isCurrentlyActive = NO;
    hasBeenDismissed = NO;
    dialougeActivateTime = MAXFLOAT;
    dialougeImageIndex = 0;
    self.dialougeText = [NSString string];
    */
    
    NSNumber* activeNumber = [NSNumber numberWithBool:isCurrentlyActive];
    NSNumber* dismissedNumber = [NSNumber numberWithBool:hasBeenDismissed];
    NSNumber* dialougeTimeNumber = [NSNumber numberWithFloat:dialougeActivateTime];
    NSNumber* dialougeImageNumber = [NSNumber numberWithInt:dialougeImageIndex];
    NSString* dialougeString = [NSString stringWithString:dialougeText];
    
    [infoArray addObject:activeNumber];
    [infoArray addObject:dismissedNumber];
    [infoArray addObject:dialougeTimeNumber];
    [infoArray addObject:dialougeImageNumber];
    [infoArray addObject:dialougeString];
    
    return [infoArray autorelease];
}

- (BOOL)shouldDisplayDialougeObjectWithTotalTime:(float)sceneTime {
    if ( (sceneTime >= dialougeActivateTime) && (!isCurrentlyActive) ) {
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
    }
    hasBeenDismissed = dismissed;
}

- (void)updateDialougeObjectWithDelta:(float)aDelta {
    [portraitImage updateAnimatedImageWithDelta:aDelta];
}

- (void)renderDialougeObjectWithFont:(BitmapFont*)font {
    [fadedBackgroundImage renderCenteredAtPoint:fadedBackgroundImage.objectLocation
                               withScrollVector:Vector2fZero];
    [portraitBackgroundImage renderCenteredAtPoint:portraitBackgroundImage.objectLocation 
                                  withScrollVector:Vector2fZero];
    [dialougeBackgroundImage renderCenteredAtPoint:dialougeBackgroundImage.objectLocation
                                  withScrollVector:Vector2fZero];

    [dialougeTextObject renderWithFont:font];
    [portraitImage renderCurrentSubImageAtPoint:portraitBackgroundImage.objectLocation];
}
     
     
     
     
     
     @end
