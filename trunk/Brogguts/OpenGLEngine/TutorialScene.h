//
//  TutorialScene.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/15/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BroggutScene.h"

@class TriggerObject;

@interface TutorialScene : BroggutScene {
    NSString* nextSceneName;
    BOOL isObjectiveComplete;
}

- (id)initWithScreenBounds:(CGRect)screenBounds withFullMapBounds:(CGRect)mapBounds withName:(NSString *)sName withNextScene:(NSString*)nextName;
- (BOOL)checkObjective;

@end
