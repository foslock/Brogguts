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

@implementation OpenGLEngineAppDelegate

@synthesize window;
@synthesize glView;

- (void)startGLAnimation {
    [window bringSubviewToFront:glView];
    glView.hidden = NO;
    [glView startAnimation];
}

- (void)stopGLAnimation {
    [window bringSubviewToFront:mainMenuController.view];
    [mainMenuController dismissModalViewControllerAnimated:NO];
    glView.hidden = YES;
    [glView stopAnimation];
}

- (void)saveSceneAndPlayer {
    [sharedGameController savePlayerProfile];
    if ([[sharedGameController currentScene] isBaseCamp]) {
        [sharedGameController saveCurrentSceneWithFilename:kBaseCampFileName allowOverwrite:YES];
    } else {
        if (![[sharedGameController currentScene] isMultiplayerMatch]) {
            NSString* dateString = [[NSDate date] description];
            [sharedGameController saveCurrentSceneWithFilename:dateString allowOverwrite:NO];
        }
    }
}

- (void)applicationEnded { // Custom method called whenever the application ends
    if (applicationSaved) return;
    applicationSaved = YES;
    [self saveSceneAndPlayer];
    [self stopGLAnimation];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
	// Seed the random numbers!
	srandom(time(NULL));
    
    viewInserted = NO;
    applicationSaved = NO;
	
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
	
	sharedGameController = [GameController sharedGameController];
    
    // Creates and tries to authenticate the local player
	sharedGCSingleton = [GameCenterSingleton sharedGCSingleton];
    
    mainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
    [window addSubview:mainMenuController.view];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[self applicationEnded];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self applicationEnded];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // [self startGLAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // [self startGLAnimation];
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