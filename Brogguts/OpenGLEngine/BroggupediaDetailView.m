//
//  BroggupediaDetailView.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/5/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggupediaDetailView.h"
#import "Image.h"
#import "GameController.h"
#import "SoundSingleton.h"


@implementation BroggupediaDetailView
@synthesize unitImageView, unitBroggutsCostLabel, unitLabel, unitMetalCostLabel;
@synthesize broggutImage, metalImage;

- (id)initWithObjectType:(int)objectID
{
    self = [super initWithNibName:@"BroggupediaDetailView" bundle:nil];
    if (self) {
        currentObjectID = objectID;
        currentRotation = 0.0f;
    }
    return self;
}

- (void)setLabelsWithObjectID:(int)objectID {
    switch (objectID) {
            // CRAFT
        case kObjectCraftAntID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftAntSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftAntCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftAntCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Ant is a very common craft. Used mostly for mining operations, this ship has a cargo capacity of %i brogguts. It also is equipped with a quick release bay that can transport whatever is in its bay to a neighboring base station.", kCraftAntCargoSpace];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftMothID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftMothSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftMothCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftMothCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Moth first appeared as a racing craft on the outskirts of the solar system, but soon was adopted as a scouting ship for the local companies. It is very fast, very weak, and very replacable."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftBeetleID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftBeetleSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftBeetleCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftBeetleCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Beetle used to be used as a military transport, but since all of the corporate takeovers they have been converted to slow and powerful monsters. These space tanks are slow, but pack quite a punch. One thing is for sure, you do not want to take one of these on alone."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftMonarchID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftMonarchSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftMonarchCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftMonarchCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Monarch is a recent breakthrough in wireless technology. Not only can it transmit information as light speed, it can provide protection for all nearby friendly ships. Having just a few of these ships can turn one battle completely around."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftCamelID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftCamelSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftCamelCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftCamelCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Camel is a company's attempt at creating a mining craft superior to the Ant. Built from the same frame, but loaded with many more auxilury systems, this craft has a cargo capacity of %i. The addition of these bonuses come at a price.",kCraftCamelCargoSpace];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftRatID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftRatSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftRatCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftRatCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Rat is another brand new company invention. While seemingly harmless, this craft has the passive ability to remain cloaked and hidden from its enemies. Only an enemy radar structure will be able to detect it."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftSpiderID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftSpiderSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftSpiderCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftSpiderCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Spider is the largest craft that the companies have been able to build. It has eight bays where it stores eight separate attack drones. Instead of the ship being equipped with a weapon, these drones will swarm any enemy that comes near it."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectCraftEagleID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectCraftEagleSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kCraftEagleCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kCraftEagleCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Eagle is the most desirable and multipurpose craft available. It is fast, strong, and can single handedly destroy almost any other ship it comes up against. It does come at quite a price though."];
            [unitLabel setText:description];
            [image release];
            break;
        }
            
            // Structures
        case kObjectStructureBaseStationID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureBaseStationSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:@"Brogguts Cost: N/A"];
            [unitMetalCostLabel setText:@"Metal Cost: N/A"];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Base Station is the standard in commanding stations. It provides storage for all mined brogguts, it builds craft and other important structures that help progress the current mission. Each commander may only have one Base Station at a time. It initially supports up to %i ships.", kStructureBaseStationSupplyBonus];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureBlockID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureBlockSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureBlockCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureBlockCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Block is essentially a storage cube that is deployed into nearby space. Each block allows for %i additional ships to be built. By making more space inside of the space station, complicated communication systems can be installed. This is the most common and cheapest structure.", kStructureBlockSupplyBonus];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureRefineryID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureRefinerySprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureRefineryCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureRefineryCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Refinery is required to refine brogguts back into useable metal. Metal is required to build most craft and structures, and will be refined faster the more of these you build."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureCraftUpgradesID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureCraftUpgradesSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureCraftUpgradesCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureCraftUpgradesCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Craft Upgrades structure provides an opporunity to strengthen the abilities of all of the commander's crafts. Each upgrade costs brogguts in addition to the cost of this structure."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureStructureUpgradesID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureStructureUpgradesSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureStructureUpgradesCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureStructureUpgradesCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Structure Upgrades structure provides an opporunity to strengthen the abilities of all of the commander's structures. Each upgrade costs brogguts in addition to the cost of this structure."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureTurretID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureTurretSprite ofType:nil];
            NSString* filename2 = [[NSBundle mainBundle] pathForResource:kObjectStructureTurretGunSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            UIImage* image2 = [[UIImage alloc] initWithContentsOfFile:filename2];
            UIImageView* gunView = [[UIImageView alloc] initWithImage:image2];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [self.view addSubview:gunView];
            [gunView setCenter:center];
            [gunView release];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureTurretCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureTurretCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Turret is the basic defensive structure to defend a Base Station. It attacks quickly, and having a large array of these makes a Base Station almost impossible to destroy."];
            [unitLabel setText:description];
            [image release];
            [image2 release];
            break;
        }
        case kObjectStructureRadarID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureRadarSprite ofType:nil];
            NSString* filename2 = [[NSBundle mainBundle] pathForResource:kObjectStructureRadarDishSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            UIImage* image2 = [[UIImage alloc] initWithContentsOfFile:filename2];
            UIImageView* dishView = [[UIImageView alloc] initWithImage:image2];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [self.view addSubview:dishView];
            [dishView setCenter:center];
            [dishView release];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureRadarCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureRadarCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tRadar is used purely to detect enemy units. It will alert the commander when an enemy ship enters its radar detection field. The Rat craft must be detected using this structure."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectStructureFixerID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureFixerSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureFixerCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureFixerCostMetal]];
            NSString* description = [NSString stringWithFormat:@"\t\tThe Fixer is a useful structure that repairs the closest damaged friendly craft. Even though it repairs fairly slowly, it can repair %i ships at once.", kStructureFixerFriendlyTargetLimit];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectBroggutSmallID: {
            [broggutImage setHidden:YES];
            [metalImage setHidden:YES];
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectBroggutSmallSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Collectable Brogguts Range: %i to %i",kBroggutYoungSmallMinValue, kBroggutYoungSmallMaxValue]];
            [unitBroggutsCostLabel setCenter:CGPointMake([unitImageView center].x, [unitBroggutsCostLabel center].y)];
            [unitMetalCostLabel setText:@""];
            NSString* description = [NSString stringWithFormat:@"\t\tThis is a common piece of space trash that one might find floating around in space. Once a clean and empty void, space is now full of these."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectBroggutMediumYoungID: {
            [broggutImage setHidden:YES];
            [metalImage setHidden:YES];
            NSString* filename = [[NSBundle mainBundle] pathForResource:@"broggutmediumyoung.png" ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Minable Brogguts Range: %i to %i",kBroggutYoungMediumMinValue, kBroggutYoungMediumMaxValue]];
            [unitBroggutsCostLabel setCenter:CGPointMake([unitImageView center].x, [unitBroggutsCostLabel center].y)];
            [unitMetalCostLabel setText:@""];
            NSString* description = [NSString stringWithFormat:@"\t\tA relatively young collection of space trash either placed here by mankind, or just accumulated over time. These can be mined by either of the mining ships."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectBroggutMediumOldID: {
            [broggutImage setHidden:YES];
            [metalImage setHidden:YES];
            NSString* filename = [[NSBundle mainBundle] pathForResource:@"broggutmediumold.png" ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Minable Brogguts Range: %i to %i",kBroggutOldMediumMinValue, kBroggutOldMediumMaxValue]];
            [unitBroggutsCostLabel setCenter:CGPointMake([unitImageView center].x, [unitBroggutsCostLabel center].y)];
            [unitMetalCostLabel setText:@""];
            NSString* description = [NSString stringWithFormat:@"\t\tAn older collection of space trash either placed here by mankind, or just accumulated over time. These can be mined by either of the mining ships."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        case kObjectBroggutMediumAncientID: {
            [broggutImage setHidden:YES];
            [metalImage setHidden:YES];
            NSString* filename = [[NSBundle mainBundle] pathForResource:@"broggutmediumancient.png" ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Minable Brogguts Range: %i to %i",kBroggutAncientMediumMinValue, kBroggutAncientMediumMaxValue]];
            [unitBroggutsCostLabel setCenter:CGPointMake([unitImageView center].x, [unitBroggutsCostLabel center].y)];
            [unitMetalCostLabel setText:@""];
            NSString* description = [NSString stringWithFormat:@"\t\tAn ancient collection of space trash either placed here by mankind, or just accumulated over time. These can be mined by either of the mining ships."];
            [unitLabel setText:description];
            [image release];
            break;
        }
        default:
            break;
    }
}

- (void)rotateObject:(NSTimer*)timer {
    if (currentRotation < (M_PI * 2)) {
        currentRotation += (M_PI * 2) / (60.0f * 10.0f);
    } else {
        currentRotation = 0.0f;
    }
    
    [unitImageView setTransform:CGAffineTransformMakeRotation(currentRotation)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
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
    // Do any additional setup after loading the view from its nib.
    [self setLabelsWithObjectID:currentObjectID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    timer = [NSTimer timerWithTimeInterval:(1.0f/60.0f) target:self selector:@selector(rotateObject:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode: NSDefaultRunLoopMode];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [timer invalidate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

@end
