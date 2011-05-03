//
//  BroggupediaObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BroggupediaTableView;
@class BroggupediaDetailView;

@interface BroggupediaObject : NSObject <UISplitViewControllerDelegate> {
    UISplitViewController* splitController;
    BroggupediaTableView* tableController;
    BroggupediaDetailView* detailController;
}

@property (assign) UISplitViewController* splitController;

@end
