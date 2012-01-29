//
//  SavedGameChoiceController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SavedGameChoiceController.h"
#import "GameController.h"
#import "OpenGLEngineAppDelegate.h"
#import "GameCenterSingleton.h"
#import "PlayerProfile.h"
#import "CampaignScene.h"

#define OVERRIDE_PLAYER_EXPERIENCE_LIMIT 15
#define TABLEVIEW_CELL_BACKGROUND_COUNT 3

enum SectionNames {
    kSectionSavedScenes,
    kSectionUnlockedMissions,
    kSectionExitButton,
};

@implementation SavedGameChoiceController

@synthesize chosenLoadingMission;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        sharedGameController = [GameController sharedGameController];      
        NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedCampaignFileName];
        NSArray* savedPlistArray = [NSArray arrayWithContentsOfFile:savedScenePath];
        savedGamesNames = [[NSMutableArray alloc] initWithArray:savedPlistArray];
        numberOfSavedGames = [savedGamesNames count];
        self.chosenLoadingMission = nil;
        
        unlockedMissionNames = [[NSMutableArray alloc] init];
        // Add each name with index under the current player experience
        int playerExperience = [[[GameController sharedGameController] currentProfile] playerExperience];
        playerExperience = OVERRIDE_PLAYER_EXPERIENCE_LIMIT; // CHEATING
        playerExperience = CLAMP(playerExperience, 0, CAMPAIGN_SCENES_COUNT - 1);
        for (int i = 0 ; i <= playerExperience; i++) {
            NSString* mission = [NSString stringWithString:kCampaignSceneSaveTitles[i]];
            [unlockedMissionNames insertObject:mission atIndex:0];
        }
        
        numberOfUnlockedMissions = [unlockedMissionNames count];
    }
    return self;
}

- (void)dealloc
{
    [unlockedMissionNames release];
    [savedGamesNames release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* bgPath = [[NSBundle mainBundle] pathForResource:@"starbackground" ofType:@"png"];
    UIImage* starBGImage = [[UIImage alloc] initWithContentsOfFile:bgPath];
    UIImageView* starBGView = [[UIImageView alloc] initWithImage:starBGImage];
    [self.tableView setBackgroundView:starBGView];    
    [starBGImage release];
    [starBGView release];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 16.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kSectionSavedScenes:
            return numberOfSavedGames;
            break;
        case kSectionUnlockedMissions:
            return numberOfUnlockedMissions;
            break;
        case kSectionExitButton:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"broggutCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) {
        case kSectionSavedScenes:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = [savedGamesNames objectAtIndex:indexPath.row];
            cell.backgroundColor = [UIColor clearColor];
            break;
        case kSectionUnlockedMissions:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = [unlockedMissionNames objectAtIndex:indexPath.row];
            cell.backgroundColor = [UIColor clearColor];
            break;
        case kSectionExitButton:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = @"Cancel";
            break;
        default:
            return 0;
            break;
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setShadowColor:[UIColor blackColor]];
    [cell.textLabel setShadowOffset:CGSizeMake(2.0f, 2.0f)];
    return cell;
}

#pragma mark - Table view delegate

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString* text;
    NSString* cellName;
    switch (section) {
        case kSectionSavedScenes:
            text = @"Load a Saved Mission";
            cellName = @"oldcell";
            break;
        case kSectionUnlockedMissions:
            text = @"Start a New Mission";
            cellName = @"newcell";
            break;
        default:
            text = @"";
            cellName = @"oldcell";
            break;
    }
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 64)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 64)];
    [label setText:text];
    [label setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [label setShadowColor:[UIColor blackColor]];
    [label setShadowOffset:CGSizeMake(2.0f, 2.0f)];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [view addSubview:label];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@top", cellName]]];
    [view addSubview:image];
    [image setCenter:CGPointMake(tableView.frame.size.width / 2, 64-8)];
    [image release];
    
    return [view autorelease];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString* cellName;
    switch (section) {
        case kSectionSavedScenes:
            cellName = @"oldcell";
            break;
        case kSectionUnlockedMissions:
            cellName = @"newcell";
            break;
        default:
            cellName = @"oldcell";
            break;
    }
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 16)];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@bot", cellName]]];
    [view addSubview:image];
    [image setCenter:CGPointMake(tableView.frame.size.width / 2, 8)];
    [image release];
    
    return [view autorelease];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Change appearance of cells here
    int imageIndex = indexPath.row % TABLEVIEW_CELL_BACKGROUND_COUNT;
    NSString* bgPath;
    if (indexPath.section == kSectionSavedScenes || indexPath.section == kSectionExitButton) {
        bgPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"oldcell%d", imageIndex] ofType:@"png"];
    } else {
        bgPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"newcell%d", imageIndex] ofType:@"png"];
    }
    UIImage* trashImage = [[UIImage alloc] initWithContentsOfFile:bgPath];
    UIImageView* bgView = [[UIImageView alloc] initWithImage:trashImage];
    [cell setBackgroundView:bgView];
    [trashImage release];
    [bgView release];
}

- (void)loadSavedSceneWithName:(NSString*)savedSceneName {
    NSLog(@"Load the saved scene with name %@", savedSceneName);
    NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedCampaignFileName];
    int removeIndex = 0;
    for (int i = 0; i < [savedGamesNames count]; i++) {
        NSString* string = [savedGamesNames objectAtIndex:i];
        if ([string caseInsensitiveCompare:savedSceneName] == NSOrderedSame) {
            removeIndex = i;
        }
    }
    [savedGamesNames removeObjectAtIndex:removeIndex];
    if (![savedGamesNames writeToFile:savedScenePath atomically:YES]) {
        NSLog(@"Error overwriting previously saved scene: %@", savedSceneName);
    }
    int index = 0;
    NSString* savedFileName;
    for (int i = 0; i < CAMPAIGN_SCENES_COUNT; i++) {
        NSString* otherName = kCampaignSceneSaveTitles[i];
        if ([otherName caseInsensitiveCompare:savedSceneName] == NSOrderedSame) {
            index = i;
            savedFileName = otherName;
            break;
        }
    }
    [sharedGameController fadeOutToSceneWithFilename:savedFileName sceneType:kSceneTypeCampaign withIndex:index isNew:YES isLoading:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kSectionSavedScenes: {
            NSString* savedTitleName = [savedGamesNames objectAtIndex:indexPath.row];
            [self loadSavedSceneWithName:savedTitleName];
        }
            break;
        case kSectionUnlockedMissions: {
            NSString* savedSceneName = [unlockedMissionNames objectAtIndex:indexPath.row];
            BOOL hasSavedThisMission = NO;
            for (NSString* string in savedGamesNames) {
                if ([savedSceneName caseInsensitiveCompare:string] == NSOrderedSame) {
                    hasSavedThisMission = YES;
                }
            }
            if (!hasSavedThisMission) {
                int index = 0;
                for (int i = 0; i < CAMPAIGN_SCENES_COUNT; i++) {
                    NSString* otherName = kCampaignSceneSaveTitles[i];
                    if ([otherName caseInsensitiveCompare:savedSceneName] == NSOrderedSame) {
                        index = i;
                        break;
                    }
                }
                [sharedGameController fadeOutToSceneWithFilename:kCampaignSceneFileNames[index] sceneType:kSceneTypeCampaign withIndex:index isNew:YES isLoading:NO];
            } else {
                // Give the option to load old or start
                self.chosenLoadingMission = savedSceneName;
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mission In Progress" message:@"You have already started this mission, would you like to restart it or continue?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Restart Mission", @"Continue Mission", nil];
                [alert show];
                [alert release];
            }
        }
            break;
        case kSectionExitButton: {
            [self.presentingViewController dismissModalViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:YES];
    [cell setSelected:NO];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // Restart
        int index = 0;
        for (int i = 0; i < CAMPAIGN_SCENES_COUNT; i++) {
            NSString* otherName = kCampaignSceneSaveTitles[i];
            if ([otherName caseInsensitiveCompare:self.chosenLoadingMission] == NSOrderedSame) {
                index = i;
                break;
            }
        }
        [sharedGameController fadeOutToSceneWithFilename:kCampaignSceneFileNames[index] sceneType:kSceneTypeCampaign withIndex:index isNew:YES isLoading:NO];
    } else if (buttonIndex == 1) { // Continue
        if (self.chosenLoadingMission) {
            [self loadSavedSceneWithName:self.chosenLoadingMission];
        }
    }
}

@end
