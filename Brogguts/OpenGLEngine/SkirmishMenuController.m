//
//  SkirmishMenuController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SkirmishMenuController.h"
#import "MapChoiceController.h"

@implementation SkirmishMenuController

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

- (IBAction)pushMapChoiceControllerSinglePlayer {
    MapChoiceController* mapchoice = [[MapChoiceController alloc] init];
    [mapchoice setOnlineMatch:NO];
    mapchoice.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mapchoice animated:YES];
    [mapchoice release];
}

- (IBAction)pushMapChoiceControllerMultiplayer {
    MapChoiceController* mapchoice = [[MapChoiceController alloc] init];
    [mapchoice setOnlineMatch:YES];
    mapchoice.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mapchoice animated:YES];
    [mapchoice release];
}

- (IBAction)popSkirmishController {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
