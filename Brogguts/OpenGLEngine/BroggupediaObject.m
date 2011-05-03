//
//  BroggupediaObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/2/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggupediaObject.h"
#import "BroggupediaTableView.h"
#import "BroggupediaDetailView.h"


@implementation BroggupediaObject
@synthesize splitController;

- (id)init
{
    self = [super init];
    if (self) {
        splitController = [[UISplitViewController alloc] init];
        [splitController setDelegate:self];
        [splitController setTitle:@"Broggupedia"];
        tableController = [[BroggupediaTableView alloc] initWithStyle:UITableViewStylePlain];
        detailController = [[BroggupediaDetailView alloc] initWithNibName:@"BroggupediaDetailView" bundle:nil];
        [tableController setDetailController:detailController];
        NSArray* controllers = [[NSArray alloc] initWithObjects:tableController, detailController, nil];
        [splitController setViewControllers:controllers];
        [controllers release];
    }
    
    return self;
}

- (void)dealloc
{
    [splitController release];
    [tableController release];
    [detailController release];
    [super dealloc];
}

@end
