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

enum SectionNames {
    kSectionNewGame,
    kSectionSavedScenes,
    kSectionExitButton,
};

@implementation SavedGameChoiceController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        sharedGameController = [GameController sharedGameController];      
        NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedCampaignFileName];
        NSArray* savedPlistArray = [NSArray arrayWithContentsOfFile:savedScenePath];
        savedGamesNames = [[NSMutableArray alloc] initWithArray:savedPlistArray];
        numberOfSavedGames = [savedGamesNames count];
    }
    return self;
}

- (void)dealloc
{
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kSectionNewGame:
            return @"New Game";
            break;
        case kSectionSavedScenes:
            return @"Saved Games";
            break;
        default:
            return @"";
            break;
    }
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
        case kSectionNewGame:
            return 1;
            break;
        case kSectionSavedScenes:
            return numberOfSavedGames;
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) {
        case kSectionNewGame:
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = @"Start a New Game";
            cell.backgroundColor = [UIColor whiteColor];
            break;
        case kSectionSavedScenes:
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = [savedGamesNames objectAtIndex:indexPath.row];
            cell.backgroundColor = [UIColor whiteColor];
            break;
        case kSectionExitButton:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.backgroundColor = [UIColor redColor];
            cell.textLabel.text = @"Cancel";
            break;
        default:
            return 0;
            break;
    }    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kSectionNewGame: {
            [[GameController sharedGameController] fadeOutToSceneWithFilename:kCampaignSceneFileNames[0] sceneType:kSceneTypeCampaign withIndex:0 isNew:YES isLoading:NO];
        }
            break;
        case kSectionSavedScenes: {
            NSString* savedTitleName = [savedGamesNames objectAtIndex:indexPath.row];
            NSLog(@"Load the saved scene with name %@", savedTitleName);
            NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedCampaignFileName];
            [savedGamesNames removeObjectAtIndex:indexPath.row];
            if (![savedGamesNames writeToFile:savedScenePath atomically:YES]) {
                NSLog(@"Error overwriting previously saved scene: %@", savedTitleName);
            }
            int index = 0;
            NSString* savedFileName;
            for (int i = 0; i < CAMPAIGN_SCENES_COUNT; i++) {
                NSString* otherName = kCampaignSceneSaveTitles[i];
                if ([otherName caseInsensitiveCompare:savedTitleName] == NSOrderedSame) {
                    index = i;
                    savedFileName = otherName;
                    break;
                }
            }
            [sharedGameController fadeOutToSceneWithFilename:savedFileName sceneType:kSceneTypeCampaign withIndex:index isNew:YES isLoading:YES];
        }
            break;
        case kSectionExitButton: {
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:YES];
    [cell setSelected:NO];
}

@end
