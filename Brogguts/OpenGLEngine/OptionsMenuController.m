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
@synthesize fxVolumeSlider, musicVolumeSlider, gridSwitch, sideBarControl;

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
    [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileExplosionSound]];
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
    doesSceneShowGrid = [gSwitch isOn];
}

- (IBAction)setSideBarButtonLocation:(id)sender {
    UISegmentedControl* segControl = (UISegmentedControl*)sender;
    sideBarButtonLocation = [segControl selectedSegmentIndex]; // 0 - Top, 1 - Bottom
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
    [gridSwitch setOn:doesSceneShowGrid];
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
