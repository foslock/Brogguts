//
//  OpenGLEngineAppDelegate.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterSingleton.h"

@class EAGLView;
@class GameController;
@class MainMenuController;

@interface OpenGLEngineAppDelegate : NSObject <UIApplicationDelegate> {
    BOOL applicationSaved;
    MainMenuController* mainMenuController;
	GameController* sharedGameController;
    UIWindow *window;
    EAGLView *glView;
    BOOL viewInserted;
	GameCenterSingleton* sharedGCSingleton;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (void)startGLAnimation;
- (void)stopGLAnimation;

@end

