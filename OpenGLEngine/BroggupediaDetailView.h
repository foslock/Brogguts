//
//  BroggupediaDetailView.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/5/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitPowerView;

@interface BroggupediaDetailView : UIViewController {
    int currentObjectID;
    float currentRotation;
    NSTimer* timer;
}

@property (assign) IBOutlet UIImageView* unitImageView;
@property (assign) IBOutlet UITextView* unitTextView;
@property (assign) IBOutlet UIImageView* broggutImage;
@property (assign) IBOutlet UIImageView* metalImage;
@property (assign) IBOutlet UILabel* unitBroggutsCostLabel;
@property (assign) IBOutlet UILabel* unitMetalCostLabel;
@property (assign) IBOutlet UnitPowerView* unitPowerView;

- (id)initWithObjectType:(int)objectID;
- (void)setLabelsWithObjectID:(int)objectID;
- (void)rotateObject:(NSTimer*)timer;

@end
