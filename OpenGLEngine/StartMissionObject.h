//
//  StartMissionObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/28/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

#define START_MISSION_BACKGROUND_WIDTH 600.0f
#define START_MISSION_BACKGROUND_HEIGHT 400.0f
#define START_MISSION_BUTTON_INSET 32.0f
#define START_MISSION_BUTTON_WIDTH 168.0f
#define START_MISSION_BUTTON_HEIGHT 64.0f

@class TextObject;
@class TiledButtonObject;

@interface StartMissionObject : TouchableObject {
    CGRect rect;
    TiledButtonObject* background; // Not pushable
    TiledButtonObject* menuButton; // Returns to the menu always (WITHOUT SAVING THE SCENE)
    TiledButtonObject* confirmButton; // Either retry or next level
    
    TextObject* headerText; // MISSION SUCCESS/FAILURE
    TextObject* missionTextOne;
    TextObject* missionTextTwo;
    TextObject* missionTextThree;
    TextObject* missionTextFour;

    NSMutableArray* buttonArray;
    NSMutableArray* textArray;
}

@property (readonly) CGRect rect;

- (void)setMissionHeader:(NSString*)header;
- (void)setMissionTextOne:(NSString*)text;
- (void)setMissionTextTwo:(NSString*)text;
- (void)setMissionTextThree:(NSString*)text;
- (void)setMissionTextFour:(NSString*)text;

@end
