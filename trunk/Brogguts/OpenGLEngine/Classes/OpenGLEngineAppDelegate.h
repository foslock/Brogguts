//
//  OpenGLEngineAppDelegate.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLView;
@class GameController;
@class GameCenterSingleton;
@class SoundSingleton;
@class MainMenuController;

@interface OpenGLEngineAppDelegate : NSObject <UIApplicationDelegate> {
    BOOL applicationSaved;
    BOOL resignStoppedAnimation;
    MainMenuController* mainMenuController;
	GameController* sharedGameController;
    UIWindow *window;
    EAGLView *glView;
    BOOL viewInserted;
	GameCenterSingleton* sharedGCSingleton;
    SoundSingleton* sharedSoundSingleton;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (UIViewController*)mainMenuController;
- (void)saveSceneAndPlayer;
- (void)startGLAnimation;
- (void)stopGLAnimation;

@end

