//
//  MapChoiceController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MapChoiceController.h"
#import "GameController.h"
#import "OpenGLEngineAppDelegate.h"

enum SectionNames {
    kSectionSavedScenes,
    kSectionNewMaps,
    kSectionExitButton,
};

@implementation MapChoiceController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        sharedGameController = [GameController sharedGameController];      
        NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedScenesFileName];
        NSString* mapsPath = [sharedGameController documentsPathWithFilename:kNewMapScenesFileName];
        NSArray* savedPlistArray = [NSArray arrayWithContentsOfFile:savedScenePath];
        NSArray* mapsPlistArray = [NSArray arrayWithContentsOfFile:mapsPath];
        savedScenesNames = [[NSMutableArray alloc] initWithArray:savedPlistArray];
        newMapNames = [[NSMutableArray alloc] initWithArray:mapsPlistArray];
        numberOfSavedScenes = [savedScenesNames count];
        numberOfNewMaps = [newMapNames count];
    }
    return self;
}

- (void)dealloc
{
    [savedScenesNames release];
    [newMapNames release];
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
        case kSectionSavedScenes:
            return @"Saved Games";
            break;
        case kSectionNewMaps:
            return @"New Game";
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
        case kSectionSavedScenes:
            return numberOfSavedScenes;
            break;
        case kSectionNewMaps:
            return numberOfNewMaps;
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
        case kSectionSavedScenes:
            cell.textLabel.text = [savedScenesNames objectAtIndex:indexPath.row];
            break;
        case kSectionNewMaps:
            cell.textLabel.text = [newMapNames objectAtIndex:indexPath.row];
            break;
        case kSectionExitButton:
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.backgroundColor = [UIColor redColor];
            cell.textLabel.text = @"Back";
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
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
        case kSectionSavedScenes: {
            NSString* name = [savedScenesNames objectAtIndex:indexPath.row];
            NSLog(@"Load the saved scene with name %@", name);
            NSString* savedScenePath = [sharedGameController documentsPathWithFilename:kSavedScenesFileName];
            [savedScenesNames removeObjectAtIndex:indexPath.row];
            if (![savedScenesNames writeToFile:savedScenePath atomically:YES]) {
                NSLog(@"Error overwriting previously saved scene: %@", name);
            }
            
            [sharedGameController transitionToSceneWithFileName:name isTutorial:NO];
        }
            break;
        case kSectionNewMaps: {
            NSString* name = [newMapNames objectAtIndex:indexPath.row];
            NSLog(@"Make a new scene with name %@", name);
            [(OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate] startGLAnimation];
            [sharedGameController transitionToSceneWithFileName:name isTutorial:NO];
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
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
