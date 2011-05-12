//
//  EndMissionObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/28/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

#define END_MISSION_BACKGROUND_WIDTH 600.0f
#define END_MISSION_BACKGROUND_HEIGHT 400.0f
#define END_MISSION_BUTTON_INSET 32.0f
#define END_MISSION_BUTTON_WIDTH 128.0f
#define END_MISSION_BUTTON_HEIGHT 64.0f

@class TextObject;
@class TiledButtonObject;

@interface EndMissionObject : TouchableObject {
    CGRect rect;
    BOOL wasSuccessfulMission;
    BOOL didAppear;
    TiledButtonObject* background; // Not pushable
    TiledButtonObject* menuButton; // Returns to the menu always (WITHOUT SAVING THE SCENE)
    TiledButtonObject* confirmButton; // Either retry or next level
    
    TextObject* headerText; // MISSION SUCCESS/FAILURE
    TextObject* broggutsLeftLabel;
    TextObject* broggutsEarnedLabel;
    TextObject* broggutsTotalLabel;
    
    TextObject* broggutsLeftNumber;
    TextObject* broggutsEarnedNumber;
    TextObject* broggutsTotalNumber;
    
    NSMutableArray* buttonArray;
    NSMutableArray* textArray;
    
    int broggutsLeft;
    int broggutsEarned;
    int totalCount;
    int totalCounter;
}

@property (readonly) CGRect rect;
@property (assign) BOOL wasSuccessfulMission;

- (void)endMissionDidAppear;

@end
