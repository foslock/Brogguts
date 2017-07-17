//
//  OptionsMenuController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OptionsMenuController : UIViewController <UIAlertViewDelegate> {
    UISlider* fxVolumeSlider;
    UISlider* musicVolumeSlider;
}

@property (assign) IBOutlet UISlider* fxVolumeSlider;
@property (assign) IBOutlet UISlider* musicVolumeSlider;
@property (assign) IBOutlet UISwitch* gridSwitch;
@property (assign) IBOutlet UISwitch* colorBlindSwitch;
@property (assign) IBOutlet UISegmentedControl* sideBarControl;

- (IBAction)popOptionsController;
- (IBAction)fxVolumeChanged:(id)sender;
- (IBAction)musicVolumeChanged:(id)sender;
- (IBAction)switchGrid:(id)sender;
- (IBAction)switchColorBlind:(id)sender;
- (IBAction)setSideBarButtonLocation:(id)sender;
- (IBAction)resetProgress:(id)sender;

@end
