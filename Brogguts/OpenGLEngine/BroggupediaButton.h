//
//  BroggupediaButton.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/12/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BroggupediaButton : UIButton {
    UIImageView* iconView;
    UIImageView* altView;
    UILabel* labelView;
}

@property (assign) IBOutlet UIImageView* iconView;
@property (assign) IBOutlet UIImageView* altView;
@property (assign) IBOutlet UILabel* labelView;

- (void)updateViews;

@end
