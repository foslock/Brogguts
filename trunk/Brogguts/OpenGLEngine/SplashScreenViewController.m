//
//  SplashScreenViewController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/31/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "SoundSingleton.h"

#define DEFAULT_FADE_OUT_TIME 0.5f

#define LOGO_WAIT_TIME 1.0f
#define LOGO_MASK_WAIT_TIME 1.0f
#define LOGO_FADE_IN_TIME 1.5f
#define FINAL_LOGO_WAIT_TIME 1.5f
#define FINAL_DARK_WAIT_TIME 2.0f

@implementation SplashScreenViewController

@synthesize defaultSplash, logoSplash, maskSplash;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        didSkipIntro = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)fadeDefaultOut {
    if (didSkipIntro) return;
    [UIView animateWithDuration:DEFAULT_FADE_OUT_TIME animations:^{
        defaultSplash.alpha = 0.0f;
    } completion:^(BOOL finished){
        [NSTimer scheduledTimerWithTimeInterval:LOGO_WAIT_TIME target:self selector:@selector(turnLogoSplashOn) userInfo:nil repeats:NO];
    }];
}

- (void)turnLogoSplashOn {
    if (didSkipIntro) return;
    // Play the light click sound
    [[SoundSingleton sharedSoundSingleton] playSoundWithKey:@"lightsound.wav"];
    maskSplash.alpha = 1.0f;
    logoSplash.alpha = 1.0f;
    [NSTimer scheduledTimerWithTimeInterval:LOGO_MASK_WAIT_TIME target:self selector:@selector(fadeLogoIn) userInfo:nil repeats:NO];
}

- (void)fadeLogoIn {
    if (didSkipIntro) return;
    [UIView animateWithDuration:LOGO_FADE_IN_TIME animations:^{
        maskSplash.alpha = 0.0f;
    } completion:^(BOOL finished){
        [NSTimer scheduledTimerWithTimeInterval:FINAL_LOGO_WAIT_TIME target:self selector:@selector(turnLogoOff) userInfo:nil repeats:NO];
    }];
}

- (void)turnLogoOff {
    if (didSkipIntro) return;
    // Play the door shut sound
    [[SoundSingleton sharedSoundSingleton] playSoundWithKey:@"doorclose.wav"];
    maskSplash.alpha = 0.0f;
    logoSplash.alpha = 0.0f;
    [NSTimer scheduledTimerWithTimeInterval:FINAL_DARK_WAIT_TIME target:self selector:@selector(endSplashSequence) userInfo:nil repeats:NO];
}

- (void)endSplashSequence {
    [self.parentViewController dismissModalViewControllerAnimated:NO];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasWatchedIntro"];
    [defaults synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fadeDefaultOut];    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL canSkip = [defaults boolForKey:@"hasWatchedIntro"];
    if (canSkip) {
        didSkipIntro = YES;
        [self endSplashSequence];
    }
}

@end
