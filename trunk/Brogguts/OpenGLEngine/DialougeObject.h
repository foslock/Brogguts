//
//  DialougeObject.h
//  OpenGLEngine
//
//  Created by James Lockwood on 8/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

enum kDialougeDimensionValues {
    kDialougeDimensionTotalWidth = 600,
    kDialougeDimensionTotalHeight = 304,
    kDialougeDimensionPortraitWidth = 200,
    kDialougeDimensionDialougeWidth = 400,
};

@class TiledButtonObject;
@class TextObject;
@class BitmapFont;
@class AnimatedImage;

@interface DialougeObject : NSObject {
    // Saved information
    BOOL isCurrentlyActive;
    BOOL hasBeenDismissed;
    float dialougeActivateTime;
    int dialougeImageIndex;
    NSString* dialougeText;
    
    // Dynamic stuff that doesn't need to be saved
    TextObject* dialougeTextObject;
    AnimatedImage* portraitImage;
    TiledButtonObject* fadedBackgroundImage;
    TiledButtonObject* portraitBackgroundImage;
    TiledButtonObject* dialougeBackgroundImage;
}

@property (nonatomic, assign) float dialougeActivateTime;
@property (nonatomic, assign) int dialougeImageIndex;
@property (nonatomic, copy) NSString* dialougeText;
@property (nonatomic, assign) BOOL hasBeenDismissed;

- (BOOL)shouldDisplayDialougeObjectWithTotalTime:(float)sceneTime;
- (void)updateDialougeObjectWithDelta:(float)aDelta;
- (void)renderDialougeObjectWithFont:(BitmapFont*)font;

// Used for saving/loading
- (id)initWithInfoArray:(NSArray*)infoArray;
- (NSArray*)infoArrayFromDialouge;

@end
