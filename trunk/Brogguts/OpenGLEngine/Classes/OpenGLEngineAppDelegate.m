//
//  OpenGLEngineAppDelegate.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "OpenGLEngineAppDelegate.h"
#import "EAGLView.h"
#import "GameController.h"
#import "MainMenuController.h"
#import "SplashScreenViewController.h"
#import "GameCenterSingleton.h"
#import "SoundSingleton.h"

@implementation OpenGLEngineAppDelegate

@synthesize window;
@synthesize glView;

- (void)startGLAnimation {
    [window bringSubviewToFront:glView];
    [mainMenuController dismissModalViewControllerAnimated:NO];
    glView.hidden = NO;
    [glView startAnimation];
}

- (void)stopGLAnimation {
    [window bringSubviewToFront:mainMenuController.view];
    [mainMenuController updateCountLabels];
    [mainMenuController dismissModalViewControllerAnimated:NO];
    glView.hidden = YES;
    [glView stopAnimation];
}

- (void)saveSceneAndPlayer {
    [sharedGameController savePlayerProfile];
    if ([[sharedGameController currentScene] sceneType] == kSceneTypeBaseCamp) {
        [sharedGameController saveCurrentSceneWithFilename:kBaseCampFileName allowOverwrite:YES];
    } else {
        if (![[sharedGameController currentScene] isMultiplayerMatch]) {
            NSString* dateString = [[NSDate date] description];
            NSString* nameString = [[[sharedGameController currentScene] sceneName] stringByAppendingFormat:@" (%@)", dateString];
            if ([sharedGameController currentScene].sceneType != kSceneTypeCampaign) {
                [sharedGameController saveCurrentSceneWithFilename:nameString allowOverwrite:NO];
            } else {
                NSString* sceneFileName = [[sharedGameController currentScene] sceneName];
                [sharedGameController saveCurrentSceneWithFilename:sceneFileName allowOverwrite:YES];
            }
        }
    }
}

- (void)applicationEnded { // Custom method called whenever the application ends
    if (applicationSaved) return;
    
    applicationSaved = YES;
    [[GameCenterSingleton sharedGCSingleton] disconnectFromGame];
    [self saveSceneAndPlayer];
    [self stopGLAnimation];
    [[SoundSingleton sharedSoundSingleton] shutdownSoundManager];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
	// Seed the random numbers!
	srandom(time(NULL));
    
    viewInserted = NO;
    applicationSaved = NO;
    resignStoppedAnimation = NO;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// Set the orientation!
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Get current orientation
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	// If the device is already landscape, set it to the current
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		[[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
	} else {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
	}
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // Initialize the game controller
    sharedGameController = [GameController sharedGameController];
    // Initialize the sound manager
    sharedSoundSingleton = [SoundSingleton sharedSoundSingleton];
    // Start the game center
    sharedGCSingleton = [GameCenterSingleton sharedGCSingleton];
    
    mainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
    [window addSubview:mainMenuController.view];
    
    SplashScreenViewController* splash = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:nil];
    [mainMenuController presentModalViewController:splash animated:NO];
    [splash release];
    return YES;
}

- (UIViewController*)mainMenuController {
    return mainMenuController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// [self applicationEnded];
    if ([glView isAnimating]) {
        [glView stopAnimation];
        resignStoppedAnimation = YES;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // [self applicationEnded];
    if ([glView isAnimating]) {
        [glView stopAnimation];
        resignStoppedAnimation = YES;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // [self startGLAnimation];
    if (resignStoppedAnimation) {
        [glView startAnimation];
        resignStoppedAnimation = NO;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // [self startGLAnimation];
    if (resignStoppedAnimation) {
        [glView startAnimation];
        resignStoppedAnimation = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self applicationEnded];
}

- (void)dealloc
{
    [mainMenuController release];
    [window release];
    [glView release];
    [super dealloc];
}

@end
