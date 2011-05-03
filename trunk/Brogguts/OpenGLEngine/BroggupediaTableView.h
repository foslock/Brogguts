//
//  BroggupediaTableView.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BroggupediaDetailView;

@interface BroggupediaTableView : UITableViewController {
    BroggupediaDetailView* detailController;
}

- (void)closeBroggupedia:(id)sender;

@property (assign) BroggupediaDetailView* detailController;

@end
