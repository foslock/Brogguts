//
//  OptionsMenuController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OptionsMenuController : UIViewController {
    UISlider* fxVolumeSlider;
    UISlider* musicVolumeSlider;
}

@property (assign) IBOutlet UISlider* fxVolumeSlider;
@property (assign) IBOutlet UISlider* musicVolumeSlider;

- (IBAction)popOptionsController;
- (IBAction)fxVolumeChanged:(id)sender;
- (IBAction)musicVolumeChanged:(id)sender;
- (IBAction)switchGrid:(id)sender;

@end
