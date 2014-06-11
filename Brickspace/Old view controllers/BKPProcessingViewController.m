//
//  BKPProcessingViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPProcessingViewController.h"
#import "BKPBrickCounter.h"
#import "BKPDoneViewController.h"

@interface BKPProcessingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *thresholdStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *minThresholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxThresholdLabel;
@property (weak, nonatomic) IBOutlet UILabel *minRepeatabilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *minDistBetweenBlobsLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterByColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *blobColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterByAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *minAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAreaLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterByCircularityLabel;
@property (weak, nonatomic) IBOutlet UILabel *minCircularityLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxCircularityLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterByInertiaLabel;
@property (weak, nonatomic) IBOutlet UILabel *minInertiaRatioLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxInertiaRatioLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterByConvexityLabel;
@property (weak, nonatomic) IBOutlet UILabel *minConvexityLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxConvexityLabel;

@property (weak, nonatomic) IBOutlet UILabel *nowEditingLabel;
@property (weak, nonatomic) IBOutlet UILabel *blobCountLabel;

@end

@implementation BKPProcessingViewController {
	BKPBrickCounter *brickCounter;
	
	int nowEditing;
	NSArray *editingNames;
}

@synthesize imageView;
@synthesize thresholdStepLabel, minThresholdLabel, maxThresholdLabel;
@synthesize minRepeatabilityLabel;
@synthesize minDistBetweenBlobsLabel;
@synthesize filterByColorLabel, blobColorLabel;
@synthesize filterByAreaLabel, minAreaLabel, maxAreaLabel;
@synthesize filterByCircularityLabel, minCircularityLabel, maxCircularityLabel;
@synthesize filterByInertiaLabel, minInertiaRatioLabel, maxInertiaRatioLabel;
@synthesize filterByConvexityLabel, minConvexityLabel, maxConvexityLabel;
@synthesize nowEditingLabel;
@synthesize blobCountLabel;

#pragma mark - Basic stuff

- (void)setUpModelWithImage:(UIImage *)incomingImage {
	brickCounter = [[BKPBrickCounter alloc] initWithSourceImage:incomingImage];
	
	nowEditing = 0;
	editingNames = @[@"thresholdStep",@"minThreshold",@"maxThreshold",@"minRepeatability",@"minDistBetweenBlobs",@"filterByColor",@"blobColor",@"filterByArea",@"minArea",@"maxArea",@"filterByCircularity",@"minCircularity",@"maxCircularity",@"filterByInertia",@"minInertiaRatio",@"maxInertiaRatio",@"filterByConvexity",@"minConvexity",@"maxConvexity"];
//	editingNames = @[@"thresholdStep",@"minThreshold",@"maxThreshold",@"minRepeatability",@"filterByArea",@"minArea",@"maxArea"];


	[self updateUI];
}

- (void)updateUI {
	[imageView setImage:[brickCounter processedImage]];
	
	// update every single label's value
	[thresholdStepLabel setText:[NSString stringWithFormat:@"thresholdStep = %f", brickCounter.det_thresholdStep]];
	[minThresholdLabel setText:[NSString stringWithFormat:@"minThreshold = %f", brickCounter.det_minThreshold]];
	[maxThresholdLabel setText:[NSString stringWithFormat:@"maxThreshold = %f", brickCounter.det_maxThreshold]];
	[minRepeatabilityLabel setText:[NSString stringWithFormat:@"minRepeatability = %zu", brickCounter.det_minRepeatability]];
	[minDistBetweenBlobsLabel setText:[NSString stringWithFormat:@"minDistBetweenBlobs = %f", brickCounter.det_minDistBetweenBlobs]];
	[filterByColorLabel setText:[NSString stringWithFormat:@"filterByColor = %d", brickCounter.det_filterByColor]];
	[blobColorLabel setText:[NSString stringWithFormat:@"blobColor = %u", brickCounter.det_blobColor]];
	[filterByAreaLabel setText:[NSString stringWithFormat:@"filterByArea = %d", brickCounter.det_filterByArea]];
	[minAreaLabel setText:[NSString stringWithFormat:@"minArea = %f", brickCounter.det_minArea]];
	[maxAreaLabel setText:[NSString stringWithFormat:@"maxArea = %f", brickCounter.det_maxArea]];
	[filterByCircularityLabel setText:[NSString stringWithFormat:@"filterByCircularity = %d", brickCounter.det_filterByCircularity]];
	[minCircularityLabel setText:[NSString stringWithFormat:@"minCircularity = %f", brickCounter.det_minCircularity]];
	[maxCircularityLabel setText:[NSString stringWithFormat:@"maxCircularity = %f", brickCounter.det_maxCircularity]];
	[filterByInertiaLabel setText:[NSString stringWithFormat:@"filterByInertia = %d", brickCounter.det_filterByInertia]];
	[minInertiaRatioLabel setText:[NSString stringWithFormat:@"minInertiaRatio = %f", brickCounter.det_minInertiaRatio]];
	[maxInertiaRatioLabel setText:[NSString stringWithFormat:@"maxInertiaRatio = %f", brickCounter.det_maxInertiaRatio]];
	[filterByConvexityLabel setText:[NSString stringWithFormat:@"filterByConvexity = %d", brickCounter.det_filterByConvexity]];
	[minConvexityLabel setText:[NSString stringWithFormat:@"minConvexity = %f", brickCounter.det_minConvexity]];
	[maxConvexityLabel setText:[NSString stringWithFormat:@"maxConvexity = %f", brickCounter.det_maxConvexity]];
	
	[nowEditingLabel setText:[editingNames objectAtIndex:nowEditing]];
	
	[blobCountLabel setText:[NSString stringWithFormat:@"%lu",[brickCounter numberOfBricksDetected]]];
	
	// update the shading of the labels
	BOOL colorShaded = !brickCounter.det_filterByColor;
	BOOL areaShaded = !brickCounter.det_filterByArea;
	BOOL circularityShaded = !brickCounter.det_filterByCircularity;
	BOOL inertiaShaded = !brickCounter.det_filterByInertia;
	BOOL convexityShaded = !brickCounter.det_filterByConvexity;
	UIColor *shadedColor = [UIColor colorWithWhite:0 alpha:0.3];
	UIColor *unshadedColor = [UIColor colorWithWhite:1 alpha:0];
	if (colorShaded) {
		[filterByColorLabel setBackgroundColor:shadedColor];
		[blobColorLabel setBackgroundColor:shadedColor];
	} else {
		[filterByColorLabel setBackgroundColor:unshadedColor];
		[blobColorLabel setBackgroundColor:unshadedColor];
	}
	if (areaShaded) {
		[filterByAreaLabel setBackgroundColor:shadedColor];
		[minAreaLabel setBackgroundColor:shadedColor];
		[maxAreaLabel setBackgroundColor:shadedColor];
	} else {
		[filterByAreaLabel setBackgroundColor:unshadedColor];
		[minAreaLabel setBackgroundColor:unshadedColor];
		[maxAreaLabel setBackgroundColor:unshadedColor];
	}
	if (circularityShaded) {
		[filterByCircularityLabel setBackgroundColor:shadedColor];
		[minCircularityLabel setBackgroundColor:shadedColor];
		[maxCircularityLabel setBackgroundColor:shadedColor];
	} else {
		[filterByCircularityLabel setBackgroundColor:unshadedColor];
		[minCircularityLabel setBackgroundColor:unshadedColor];
		[maxCircularityLabel setBackgroundColor:unshadedColor];
	}
	if (inertiaShaded) {
		[filterByInertiaLabel setBackgroundColor:shadedColor];
		[minInertiaRatioLabel setBackgroundColor:shadedColor];
		[maxInertiaRatioLabel setBackgroundColor:shadedColor];
	} else {
		[filterByInertiaLabel setBackgroundColor:unshadedColor];
		[minInertiaRatioLabel setBackgroundColor:unshadedColor];
		[maxInertiaRatioLabel setBackgroundColor:unshadedColor];
	}
	if (convexityShaded) {
		[filterByConvexityLabel setBackgroundColor:shadedColor];
		[minConvexityLabel setBackgroundColor:shadedColor];
		[maxConvexityLabel setBackgroundColor:shadedColor];
	} else {
		[filterByConvexityLabel setBackgroundColor:unshadedColor];
		[minConvexityLabel setBackgroundColor:unshadedColor];
		[maxConvexityLabel setBackgroundColor:unshadedColor];
	}
	
}

#pragma mark - Tweaking buttons

- (IBAction)changeNowEditing:(UIButton *)sender {
	if ([[[sender titleLabel] text] isEqualToString:@"prev"])
		nowEditing--;
	else
		nowEditing++;
	
	if (nowEditing < 0)
		nowEditing = ((int)[editingNames count]) - 1;
	if (nowEditing > [editingNames count] - 1)
		nowEditing = 0;
	
	[self updateUI];
}

// hit the arrows, up or down, depending on type, etc.

- (IBAction)modifyBy1ButtonPressed:(UIButton *)sender {
	int sign;
	if ([[[sender titleLabel] text] isEqualToString:@"-"])
		sign = -1;
	else
		sign = 1;
	
	[self modifyParameterByIncrement:sign];
}

- (IBAction)modifyBy5ButtonPressed:(UIButton *)sender {
	int sign;
	if ([[[sender titleLabel] text] isEqualToString:@"-"])
		sign = -1;
	else
		sign = 1;
	
	[self modifyParameterByIncrement:sign * 5];
}

- (IBAction)modifyBy10ButtonPressed:(UIButton *)sender {
	int sign;
	if ([[[sender titleLabel] text] isEqualToString:@"-"])
		sign = -1;
	else
		sign = 1;
	
	[self modifyParameterByIncrement:sign * 10];
}

- (IBAction)modifyBy50ButtonPressed:(UIButton *)sender {
	int sign;
	if ([[[sender titleLabel] text] isEqualToString:@"-"])
		sign = -1;
	else
		sign = 1;
	
	[self modifyParameterByIncrement:sign * 50];
}

- (void)modifyParameterByIncrement:(int)increment {
	switch (nowEditing) {
		case 0:
			[brickCounter setDet_thresholdStep:brickCounter.det_thresholdStep + increment];
			break;
		case 1:
			[brickCounter setDet_minThreshold:brickCounter.det_minThreshold + increment];
			break;
		case 2:
			[brickCounter setDet_maxThreshold:brickCounter.det_maxThreshold + increment];
			break;
		case 3:
			[brickCounter setDet_minRepeatability:brickCounter.det_minRepeatability + increment];
			break;
		case 4:
			[brickCounter setDet_minDistBetweenBlobs:brickCounter.det_minDistBetweenBlobs + increment];
			break;
		case 5:
			[brickCounter setDet_filterByColor:!brickCounter.det_filterByColor];
			break;
		case 6:
			[brickCounter setDet_blobColor:brickCounter.det_blobColor + increment];
			break;
		case 7:
			[brickCounter setDet_filterByArea:!brickCounter.det_filterByArea];
			break;
		case 8:
			[brickCounter setDet_minArea:brickCounter.det_minArea + increment];
			break;
		case 9:
			[brickCounter setDet_maxArea:brickCounter.det_maxArea + increment];
			break;
		case 10:
			[brickCounter setDet_filterByCircularity:!brickCounter.det_filterByCircularity];
			break;
		case 11:
			[brickCounter setDet_minCircularity:brickCounter.det_minCircularity + increment];
			break;
		case 12:
			[brickCounter setDet_maxCircularity:brickCounter.det_maxCircularity + increment];
			break;
		case 13:
			[brickCounter setDet_filterByInertia:!brickCounter.det_filterByInertia];
			break;
		case 14:
			[brickCounter setDet_minInertiaRatio:brickCounter.det_minInertiaRatio + increment];
			break;
		case 15:
			[brickCounter setDet_maxInertiaRatio:brickCounter.det_maxInertiaRatio + increment];
			break;
		case 16:
			[brickCounter setDet_filterByConvexity:!brickCounter.det_filterByConvexity];
			break;
		case 17:
			[brickCounter setDet_minConvexity:brickCounter.det_minConvexity + increment];
			break;
		case 18:
			[brickCounter setDet_maxConvexity:brickCounter.det_maxConvexity + increment];
			break;
						
		default:
			break;
	}
	
	[self updateUI];
}


#pragma mark - View updating stuff

- (void)viewDidAppear:(BOOL)animated {
	[self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	NSLog(@"%@ got a memory warning...",self);
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showSummary"]) {
		BKPDoneViewController *summaryViewController = (BKPDoneViewController *)[segue destinationViewController];
		[summaryViewController setUpWithCountedBricks:[brickCounter countedSetOfBricks]];
	}
}

@end
