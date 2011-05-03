//
//  MapChoiceController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameController;

@interface MapChoiceController : UITableViewController {
    GameController* sharedGameController;
    int numberOfSavedScenes;
    int numberOfNewMaps;
    BOOL onlineMatch;
    NSMutableArray* savedScenesNames;
    NSMutableArray* newMapNames;
}

@property (assign) BOOL onlineMatch;

@end
