//
//  BroggupediaViewController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/5/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggupediaViewController.h"
#import "BroggupediaDetailView.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "BroggupediaButton.h"

@implementation BroggupediaViewController

- (id)init {
    self = [super initWithNibName:@"BroggupediaViewController" bundle:nil];
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

- (IBAction)backButtonPressed:(id)sender {
    [[GameController sharedGameController] dismissBroggupedia];
}

- (IBAction)buttonPressed:(id)sender {
    int objectID = (int)[sender tag];
    if ([[[GameController sharedGameController] currentProfile] isObjectUnlockedWithID:objectID]) {
        BroggupediaDetailView* controller = [[BroggupediaDetailView alloc] initWithObjectType:objectID];
        [controller setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentModalViewController:controller animated:YES];
        [controller release];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:@"You must complete more missions to unlock this ship or structure" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    for (UIButton* button in [self.view subviews]) {
        if ([button isKindOfClass:[BroggupediaButton class]]) {
            [(BroggupediaButton*)button updateViews];
        }
    }
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
