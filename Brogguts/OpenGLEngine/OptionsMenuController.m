//
//  OptionsMenuController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "OptionsMenuController.h"
#import "GameController.h"
#import "SoundSingleton.h"

@implementation OptionsMenuController
@synthesize fxVolumeSlider, musicVolumeSlider, gridSwitch, colorBlindSwitch, sideBarControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (IBAction)fxVolumeChanged:(id)sender {
    UISlider* slider = (UISlider*)sender;
    [[SoundSingleton sharedSoundSingleton] setFxVolume:[slider value]];
    [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileLaserAttack1]];
}

- (IBAction)musicVolumeChanged:(id)sender {
    UISlider* slider = (UISlider*)sender;
    [[SoundSingleton sharedSoundSingleton] setMusicVolume:[slider value]];
}

- (IBAction)popOptionsController {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)switchGrid:(id)sender {
    UISwitch* gSwitch = (UISwitch*)sender;
    doesSceneHideGrid = [gSwitch isOn];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:doesSceneHideGrid forKey:@"doesSceneHideGrid"];
    [defaults synchronize];
}

- (IBAction)switchColorBlind:(id)sender {
    UISwitch* cSwitch = (UISwitch*)sender;
    isColorBlindFriendlyOn = [cSwitch isOn];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isColorBlindFriendlyOn forKey:@"isColorBlindFriendlyOn"];
    [defaults synchronize];
}

- (IBAction)setSideBarButtonLocation:(id)sender {
    UISegmentedControl* segControl = (UISegmentedControl*)sender;
    sideBarButtonLocation = [segControl selectedSegmentIndex]; // 0 - Top, 1 - Bottom
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sideBarButtonLocation forKey:@"sideBarButtonLocation"];
    [defaults synchronize];
}

- (IBAction)resetProgress:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset All Progress"
                                                    message:@"Are you sure you want to reset ALL of your progress in Brogguts?"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Nevermind", @"I am sure", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // do nothing!
    } else if (buttonIndex == 1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Progress Reset"
                                                        message:@"All of your progress in Brogguts has been reset."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        // Reset stuff!
        [[GameController sharedGameController] resetAllProgress];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [fxVolumeSlider setValue:[[SoundSingleton sharedSoundSingleton] fxVolume]];
    [musicVolumeSlider setValue:[[SoundSingleton sharedSoundSingleton] musicVolume]];
    [gridSwitch setOn:doesSceneHideGrid];
    [colorBlindSwitch setOn:isColorBlindFriendlyOn];
    [sideBarControl setSelectedSegmentIndex:sideBarButtonLocation];
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

@end
