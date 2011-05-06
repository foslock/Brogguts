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


@implementation BroggupediaDetailView
@synthesize unitImageView, unitBroggutsCostLabel, unitLabel, unitMetalCostLabel;

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
            // [unitLabel setText:@""];
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
            [image release];
            break;
        }
        case kObjectStructureTurretID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureTurretSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureTurretCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureTurretCostMetal]];
            [image release];
            break;
        }
        case kObjectStructureRadarID: {
            NSString* filename = [[NSBundle mainBundle] pathForResource:kObjectStructureRadarSprite ofType:nil];
            UIImage* image = [[UIImage alloc] initWithContentsOfFile:filename];
            float width = [image size].width;
            float height = [image size].height;
            [unitImageView setImage:image];
            CGPoint center = [unitImageView center];
            [unitImageView setFrame:CGRectMake(unitImageView.frame.origin.x, unitImageView.frame.origin.y, width, height)];
            [unitImageView setCenter:center];
            [unitBroggutsCostLabel setText:[NSString stringWithFormat:@"Brogguts Cost: %i",kStructureRadarCostBrogguts]];
            [unitMetalCostLabel setText:[NSString stringWithFormat:@"Metal Cost: %i",kStructureRadarCostMetal]];
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
            [image release];
            break;
        }
        case kObjectBroggutSmallID: {
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
            [image release];
            break;
        }
        case kObjectBroggutMediumYoungID: {
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
            [image release];
            break;
        }
        case kObjectBroggutMediumOldID: {
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
            [image release];
            break;
        }
        case kObjectBroggutMediumAncientID: {
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
    [self.parentViewController dismissModalViewControllerAnimated:YES];
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
