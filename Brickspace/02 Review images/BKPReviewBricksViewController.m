//
//  BKPReviewBricksViewController.m
//  Scanning Final
//
//  Created by Anson Jablinski on 7/3/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPReviewBricksViewController.h"
#import "BKPScannedImageCollection.h"
#import "BKPLegoView.h"
#import "BKPScannedImageAndBricks.h"

@interface BKPReviewBricksViewController ()
// Two image views, one temporary since UITableView is not in use yet
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editingImageView;

// Buttons for adding and removing bricks from processed image
@property (weak, nonatomic) IBOutlet UIButton *addBrickButton;
@property (weak, nonatomic) IBOutlet UIButton *removeBrickButton;

// Edit area
@property (weak, nonatomic) IBOutlet BKPLegoView *currentBrickView;
@property (weak, nonatomic) IBOutlet UILabel *brickSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *brickColorLabel;

// Edit area steppers
@property (weak, nonatomic) IBOutlet UIStepper *shortSideStepper;
@property (weak, nonatomic) IBOutlet UIStepper *longSideStepper;
@property (weak, nonatomic) IBOutlet UIStepper *colorStepper;

// Result summary areas
@property (weak, nonatomic) IBOutlet UITextView *thisImageSummary;
@property (weak, nonatomic) IBOutlet UITextView *allImagesSummary;

@end

@implementation BKPReviewBricksViewController {
	BKPScannedImageCollection *imageCollection;
	int indexOfCurrentlyActiveImageInCollection;
}

#pragma mark - Synthesizers

@synthesize thumbImageView, editingImageView;
@synthesize addBrickButton, removeBrickButton;
@synthesize currentBrickView, brickSizeLabel, brickColorLabel;
@synthesize shortSideStepper, longSideStepper, colorStepper;
@synthesize thisImageSummary, allImagesSummary;

#pragma mark - Inits and viewDidThings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		imageCollection = [BKPScannedImageCollection emptyCollection];
    }
    return self;
}

- (void)loadCapturedImages:(NSMutableArray *)arrayOfImages {
	assert(imageCollection);
	assert(arrayOfImages);
	
	if ([arrayOfImages count] > 0)
		[[imageCollection imageCollection] addObjectsFromArray:arrayOfImages];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[colorStepper setMaximumValue:[BKPBrickColorOptions colorCount]-1];
	indexOfCurrentlyActiveImageInCollection = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"ProcessedImageUpdated" object:nil];

	[self updateUI];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	NSLog(@"⚠️ %@ got a memory warning.", self);
}

#pragma mark - Button handlers

- (IBAction)addBrickButtonPressed:(id)sender {
	//TODO: implement adding a brick by tapping the image
	NSLog(@"➕ I don't know how to add bricks yet.");
//	[self updateUI];
}

- (IBAction)removeBrickButtonPressed:(id)sender {
	//TODO: implement removing a brick by tapping the image
	NSLog(@"➖ I don't know how to remove bricks yet.");
//	[self updateUI];
}

- (IBAction)resetScanningForThisImageButtonPressed:(id)sender {
	//TODO: use an UIAlertView later
	//TODO: implement this, there is some error
	NSLog(@"✖️ I don't know how to reset processing yet.");
//	[[self currentlyActiveImage] resetProcessedImage];
//	[self updateUI];
}

- (IBAction)editPreviousBrickButtonPressed:(id)sender {
	[[self currentlyActiveImage] highlightPreviousKeypoint];
	[self updateUI];
}

- (IBAction)editNextBrickButtonPressed:(id)sender {
	[[self currentlyActiveImage] highlightNextKeypoint];
	[self updateUI];
}

- (IBAction)stepperPressed:(id)sender {
	//TODO: need some logic that prevents you from screwing with the short/long order
	
	BKPBrick *currentBrick = [[[self currentlyActiveImage] getCurrentlyHighlightedKeypointPair] brick];
	
	[currentBrick setShortSideLength:[shortSideStepper value]];
	[currentBrick setLongSideLength:[longSideStepper value]];
	[currentBrick setColor:(BKPBrickColor)[colorStepper value]];
	
	[self updateUI];
}

#pragma mark - What image are we currently looking at?

- (BKPScannedImageAndBricks *)currentlyActiveImage {
	return [[imageCollection imageCollection] objectAtIndex:indexOfCurrentlyActiveImageInCollection];
}

#pragma mark - Update UI

- (void)updateUI {
	BKPScannedImageAndBricks *currentImage = [self currentlyActiveImage];
	BKPBrick *currentBrick = [[currentImage getCurrentlyHighlightedKeypointPair] brick];
	
//	NSLog(@"I'm in \n%@\n looking at \n%@\n", currentImage, currentBrick);
	
	// update both image views
	[thumbImageView setImage:[currentImage thumbnailImage]];
	[editingImageView setImage:[currentImage processedImage]];
	
	if (currentBrick) {
	// update the brick display
	[currentBrickView displayBricks:[NSSet setWithObject:currentBrick]];
	
	// update the short, long side lengths, and color
	[brickSizeLabel setText:[NSString stringWithFormat:@"%d x %d", currentBrick.shortSideLength, currentBrick.longSideLength]];
	[brickColorLabel setText:[BKPBrickColorOptions stringForColor:currentBrick.color]];
	
	// you also have to update the steppers
	[shortSideStepper setValue:currentBrick.shortSideLength];
	[longSideStepper setValue:currentBrick.longSideLength];
	[colorStepper setValue:currentBrick.color];
	}
		
	// update the current image summary
	[thisImageSummary setText:[NSString stringWithFormat:@"%@", [currentImage bricksFromImage]]];
	
	// update the all images summary
	[allImagesSummary setText:[NSString stringWithFormat:@"%@", [imageCollection allBricksFromAllImages]]];
}

@end
