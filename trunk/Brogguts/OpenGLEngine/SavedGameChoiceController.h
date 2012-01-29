//
//  SavedGameChoiceController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameController;

@interface SavedGameChoiceController : UITableViewController <UIAlertViewDelegate> {
    GameController* sharedGameController;
    int numberOfSavedGames;
    int numberOfUnlockedMissions;
    NSMutableArray* savedGamesNames;
    NSMutableArray* unlockedMissionNames;
}

@property (retain) NSString* chosenLoadingMission;

@end
