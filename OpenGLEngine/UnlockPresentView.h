//
//  UnlockPresentView.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/25/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnlockPresentView : UIView {
    // Main view
    UIView *view;
    
    // Craft column
    UIImageView* craftOneView;
    UILabel* craftOneLabel;
    UIImageView* craftTwoView;
    UILabel* craftTwoLabel;
    
    // Structure column
    UIImageView* structureOneView;
    UILabel* structureOneLabel;
    UIImageView* structureTwoView;
    UILabel* structureTwoLabel;
    
    // Upgrade column
    UIImageView* upgradeOneView;
    UILabel* upgradeOneLabel;
    UIImageView* upgradeTwoView;
    UILabel* upgradeTwoLabel;
    
    UIImageView* plusOneView;
    UIImageView* plusTwoView;
}

@property (nonatomic, retain) IBOutlet UIView *view;

@property (nonatomic, retain) IBOutlet UIImageView* craftOneView;
@property (nonatomic, retain) IBOutlet UILabel* craftOneLabel;
@property (nonatomic, retain) IBOutlet UIImageView* craftTwoView;
@property (nonatomic, retain) IBOutlet UILabel* craftTwoLabel;

@property (nonatomic, retain) IBOutlet UIImageView* structureOneView;
@property (nonatomic, retain) IBOutlet UILabel* structureOneLabel;
@property (nonatomic, retain) IBOutlet UIImageView* structureTwoView;
@property (nonatomic, retain) IBOutlet UILabel* structureTwoLabel;

@property (nonatomic, retain) IBOutlet UIImageView* upgradeOneView;
@property (nonatomic, retain) IBOutlet UILabel* upgradeOneLabel;
@property (nonatomic, retain) IBOutlet UIImageView* upgradeTwoView;
@property (nonatomic, retain) IBOutlet UILabel* upgradeTwoLabel;

@property (nonatomic, retain) IBOutlet UIImageView* plusOneView;
@property (nonatomic, retain) IBOutlet UIImageView* plusTwoView;


// Returns true if there are any new unlocks
- (BOOL)setUnlocksForNextSceneIndex:(int)nextIndex;

- (void)orientationChanged:(NSNotification*)notification;

@end
