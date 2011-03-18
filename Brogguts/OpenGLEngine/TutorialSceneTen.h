//
//  TutorialSceneTen.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialScene.h"

@class TriggerObject;
@class FingerObject;

@interface TutorialSceneTen : TutorialScene {
    TriggerObject* mothTrigger;
    FingerObject* fingerOne;
    FingerObject* fingerTwo;
    FingerObject* fingerThree;
}

@end