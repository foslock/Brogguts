//
//  SkirmishMatchController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameCenterSingleton;

@interface SkirmishMatchController : UIViewController {
    GameCenterSingleton* sharedGCSingleton;
    UILabel* versusLabel;
    UIButton* cancelButton;
    UIButton* confirmButton;
    UIActivityIndicatorView* spinner;
    UILabel* waitingLabel;
}

@property (assign) IBOutlet UILabel* versusLabel;
@property (assign) IBOutlet UIButton* cancelButton;
@property (assign) IBOutlet UIButton* confirmButton;
@property (assign) IBOutlet UIActivityIndicatorView* spinner;
@property (assign) IBOutlet UILabel* waitingLabel;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)confirmPressed:(id)sender;
- (void)moveMatchToScene;
- (void)setPlayerText;

@end
