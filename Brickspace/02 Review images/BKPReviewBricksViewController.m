//
//  BKPReviewBricksViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 7/3/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSetSummarizer.h"
#import "BKPCapturingViewController.h"
#import "BKPInstructionsViewController.h"
#import "BKPLegoView.h"
#import "BKPReviewBricksViewController.h"
#import "BKPScannedImageAndBricks.h"
#import "BKPScannedImageCollection.h"

@interface BKPReviewBricksViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *editingImageView;

@property (weak, nonatomic) IBOutlet BKPLegoView *currentBrickView;
@property (weak, nonatomic) IBOutlet UILabel *brickSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *brickColorLabel;

@property (weak, nonatomic) IBOutlet UIStepper *shortSideStepper;
@property (weak, nonatomic) IBOutlet UIStepper *longSideStepper;
@property (weak, nonatomic) IBOutlet UIStepper *colorStepper;

@property (weak, nonatomic) IBOutlet UITextView *thisImageSummary;
@end

@implementation BKPReviewBricksViewController {
	BKPScannedImageCollection *_imageCollection;
	int _indexOfCurrentlyActiveImageInCollection;
	
	UIAlertView *_resetThisImageAlertView;
	UIAlertView *_retakePictureAlertView;
}

#pragma mark - Synthesizers

@synthesize editingImageView;
@synthesize currentBrickView, brickSizeLabel, brickColorLabel;
@synthesize shortSideStepper, longSideStepper, colorStepper;
@synthesize thisImageSummary;

#pragma mark - Inits and viewDidThings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_imageCollection = [BKPScannedImageCollection emptyCollection];
		
		[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    }
    return self;
}

- (void)loadCapturedImages:(NSMutableArray *)arrayOfImages {
	assert(_imageCollection);
	assert(arrayOfImages);
	
	if ([arrayOfImages count] > 0)
		[[_imageCollection imageCollection] addObjectsFromArray:arrayOfImages];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// The color stepper will run from -1 to the number above the highest color index.
	// If the min or max is reached, the stepper will wrap around to the other side.
	[colorStepper setMinimumValue:-1];
	[colorStepper setMaximumValue:[BKPBrickColorOptions colorCount]];
	
	_indexOfCurrentlyActiveImageInCollection = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:@"ProcessedImageUpdated" object:nil];

	[self updateUI];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	NSLog(@"⚠️ %@ got a memory warning.", self);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		if (alertView == _resetThisImageAlertView) {
			[[self currentlyActiveImage] resetProcessedImage];
			[self updateUI];
		} else if (alertView == _retakePictureAlertView) {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

#pragma mark - Button handlers

- (IBAction)goBackAndRetakePicturePressed:(id)sender {
	_retakePictureAlertView = [[UIAlertView alloc] initWithTitle:@"Retake picture?" message:@"Are you sure you want to give up on this image and any edits you've made?" delegate:self cancelButtonTitle:@"No, keep editing" otherButtonTitles:@"Yes, retake", nil];
	[_retakePictureAlertView show];
}

- (IBAction)deleteThisBrickButtonPressed:(id)sender {
	[[self currentlyActiveImage] removeCurrentlyHighlightedKeypoint];
	[self updateUI];
}

- (IBAction)resetScanningForThisImageButtonPressed:(id)sender {
	_resetThisImageAlertView = [[UIAlertView alloc] initWithTitle:@"Reset all bricks?" message:@"Are you sure you want to give up on all your edits and reset? This will redetect any bricks you've deleted." delegate:self cancelButtonTitle:@"No, keep editing" otherButtonTitles:@"Yes, reset", nil];
	[_resetThisImageAlertView show];
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
	// Adjust the color stepper, in case it needs to wrap around.
	if ([colorStepper value] == [colorStepper maximumValue])
		[colorStepper setValue:0];
	else if ([colorStepper value] == [colorStepper minimumValue])
		[colorStepper setValue:([colorStepper maximumValue] - 1)];
	
	// Set the properties of the brick.
	BKPBrick *currentBrick = [[[self currentlyActiveImage] getCurrentlyHighlightedKeypointPair] brick];
	
	[currentBrick setShortSideLength:[shortSideStepper value]];
	[currentBrick setLongSideLength:[longSideStepper value]];
	[currentBrick setColor:(BKPBrickColor)[colorStepper value]];
	
	[self updateUI];
}

- (IBAction)buildButtonPressed:(id)sender {
	NSSet *allBricks = [_imageCollection allBricksFromAllImages];
	
	// Make sure each brick's short side is shorter than its long side.
	for (BKPBrick *brick in allBricks) {
		if ([brick shortSideLength] > [brick longSideLength]) {
			int tempSideLength = brick.shortSideLength;
			brick.shortSideLength = brick.longSideLength;
			brick.longSideLength = tempSideLength;
		}
	}
	
	BKPInstructionsViewController *instructionsVC = [[BKPInstructionsViewController alloc] init];
	[instructionsVC setUpWithCountedBricks:allBricks];
	
	[self presentViewController:instructionsVC animated:YES completion:nil];
}

#pragma mark - What image are we currently looking at?

- (BKPScannedImageAndBricks *)currentlyActiveImage {
	return [[_imageCollection imageCollection] objectAtIndex:_indexOfCurrentlyActiveImageInCollection];
}

#pragma mark - Update UI

- (void)updateUI {
	dispatch_async(dispatch_get_main_queue(), ^{
		BKPScannedImageAndBricks *currentImage = [self currentlyActiveImage];
		BKPBrick *currentBrick = [[currentImage getCurrentlyHighlightedKeypointPair] brick];
		
		// Update both image views.
		[editingImageView setImage:[currentImage processedImage]];
		
		if (currentBrick) {
			// Update the brick display.
			[currentBrickView displayBricks:[NSSet setWithObject:currentBrick]];
			
			// Update the short, long side lengths, and color.
			[brickSizeLabel setText:[NSString stringWithFormat:@"%d x %d", currentBrick.shortSideLength, currentBrick.longSideLength]];
			[brickColorLabel setText:[BKPBrickColorOptions stringForColor:currentBrick.color]];
			
			// You also have to update the steppers.
			[shortSideStepper setValue:currentBrick.shortSideLength];
			[longSideStepper setValue:currentBrick.longSideLength];
			[colorStepper setValue:currentBrick.color];
		} else {
			[currentBrickView displayBricks:[NSSet set]];
			
			[brickSizeLabel setText:@""];
			[brickColorLabel setText:@""];
			
			// No need to update the steppers here.
			// We don't have a brick selected, so the steppers have nothing to do.
		}
		
		// Update the current image summary.
		[thisImageSummary setText:[BKPBrickSetSummarizer niceDescriptionOfBricksInSet:[currentImage bricksFromImage] withTotalLine:YES]];
	});
}

@end
