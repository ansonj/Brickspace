//
//  BKPDoneViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPInstructionsViewController.h"

#import "BKPLegoView.h"
#import "BKP_GDManager.h"
#import "BKPGenericDesign.h"
#import "BKPInstructionSet.h"
#import "BKPBrickSetSummarizer.h"

// For resetting the app back to the beginning
#import "BKPSplashViewController.h"

@interface BKPInstructionsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (nonatomic) NSMutableString *summaryText;
@property (weak, nonatomic) IBOutlet BKPLegoView *legoView;
@property (weak, nonatomic) IBOutlet UISlider *stepSlider;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

@property (nonatomic) NSSet *countedBrickSet;
@property (nonatomic) id<BKPGenericDesign> selectedDesign;
@property (nonatomic) BKPInstructionSet *instructions;
@property (nonatomic) int currentStepNumber;
@end

@implementation BKPInstructionsViewController {
	UIAlertView *_resetAlertView;
}

@synthesize summaryTextView, summaryText;
@synthesize legoView;
@synthesize stepSlider, stepLabel;

@synthesize countedBrickSet;
@synthesize selectedDesign;
@synthesize instructions;
@synthesize currentStepNumber;

- (void)setUpWithCountedBricks:(NSSet *)newSet {
	countedBrickSet = newSet;
	
	summaryText = [NSMutableString string];
	
	[summaryText appendFormat:@"Here are the %lu bricks you have:\n%@\n\n", [newSet count], [BKPBrickSetSummarizer niceDescriptionOfBricksInSet:newSet withTotalLine:NO]];
	
	NSArray *availableDesigns = [BKP_GDManager availableDesigns];
	
	[summaryText appendFormat:@"Brickspace can currently build %lu different models:\n", [availableDesigns count]];
	
	for (id<BKPGenericDesign> design in availableDesigns) {
		if ([design canBeBuiltFromBricks:countedBrickSet]) {
			selectedDesign = design;
			NSString *designName = [design designName];
			float percentage = [design percentUtilizedIfBuiltWithSet:countedBrickSet];
			[summaryText appendFormat:@"- You can build a %@ with %.1f%% of your bricks.\n", designName, percentage];
		} else {
			[summaryText appendFormat:@"- You don't have enough bricks to build a %@ today.\n", [design designName]];
		}
	}
	
	[summaryText appendFormat:@"\nThe most interesting model you can build today is the %@, which is %@.\n\n\n", [selectedDesign designName], [selectedDesign designDescription]];
	
	BKPRealizedModel *model = [selectedDesign createRealizedModelUsingBricks:countedBrickSet];
	instructions = [BKPInstructionGenerator instructionsForRealizedModel:model withStyle:BKPInstructionGeneratorStyleBottomUp];
	
	currentStepNumber = 1;
	
	[legoView setDrawAxes:NO];
	[legoView setDrawBaseplate:YES];
	[legoView setBaseplateColor:BKPBrickColorBlue andSize:8];
	
	[summaryText appendString:@"Use the slider and arrow buttons to step through the building instructions.\n\n\nThank you for trying out Brickspace!"];
}

- (void)viewDidAppear:(BOOL)animated {
	[self initializeUI];
}

- (void)initializeUI {
	[summaryTextView setText:summaryText];
	
	[stepSlider setMinimumValue:1];
	[stepSlider setMaximumValue:[instructions stepCount]];
	[stepSlider setValue:1 animated:NO];
	
	[self updateUI];
}

- (void)updateUI {
	// update slider position
	[stepSlider setValue:currentStepNumber animated:YES];
	// update label text
	[stepLabel setText:[NSString stringWithFormat:@"%d of %d", currentStepNumber, [instructions stepCount]]];
	// tell legoview the right bricks to draw
	[legoView displayBricks:[instructions bricksForStepsOneThrough:currentStepNumber]];
}

- (IBAction)sliderMoved:(UISlider *)sender {
	currentStepNumber = (int)[sender value];
	[self updateUI];
}

- (IBAction)backStepPressed:(UIButton *)sender {
	currentStepNumber--;
	if (currentStepNumber <= 0)
		currentStepNumber = 1;
	[self updateUI];
}

- (IBAction)forwardStepPressed:(UIButton *)sender {
	currentStepNumber++;
	if (currentStepNumber > [instructions stepCount])
		currentStepNumber = [instructions stepCount];
	[self updateUI];
}

- (IBAction)resetButtonPressed:(id)sender {
	_resetAlertView = [[UIAlertView alloc] initWithTitle:@"Restart Brickspace?" message:@"Are you sure you want to stop building this model and go back to the beginning?" delegate:self cancelButtonTitle:@"No, keep building" otherButtonTitles:@"Yes, go back", nil];
	[_resetAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == _resetAlertView && buttonIndex == 1) {
		[_resetAlertView dismissWithClickedButtonIndex:buttonIndex animated:NO];
		
		BKPSplashViewController *splashVC = [[BKPSplashViewController alloc] init];
		[[[UIApplication sharedApplication] keyWindow] setRootViewController:splashVC];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
