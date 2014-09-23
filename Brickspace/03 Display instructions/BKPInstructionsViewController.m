//
//  BKPInstructionsViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPBrickSetSummarizer.h"
#import "BKPGenericDesign.h"
#import "BKPInstructionSet.h"
#import "BKPInstructionsViewController.h"
#import "BKPLegoView.h"
#import "BKP_GDManager.h"

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		
		[legoView setDrawAxes:NO];
		[legoView setDrawBaseplate:NO];
	}
	return self;
}

- (void)setUpWithCountedBricks:(NSSet *)newSet {
	countedBrickSet = newSet;
	
	summaryText = [NSMutableString string];
	
	[summaryText appendFormat:@"Here are the %lu bricks that you have:\n%@\n\n", (unsigned long)[newSet count], [BKPBrickSetSummarizer niceDescriptionOfBricksInSet:newSet withTotalLine:NO]];
	
	NSArray *availableDesigns = [BKP_GDManager availableDesigns];
	
	[summaryText appendFormat:@"Brickspace can currently build %lu different models:\n", (unsigned long)[availableDesigns count]];
	
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
	
	[summaryText appendString:@"Use the slider and arrow buttons to step through the building instructions.\n\n\nThank you for trying out Brickspace!"];
	
	[self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateUI];
}

- (void)updateUI {
	dispatch_async(dispatch_get_main_queue(), ^{
		// Update summary text.
		[summaryTextView setText:summaryText];
		
		// Update slider.
		[stepSlider setMinimumValue:1];
		[stepSlider setMaximumValue:[instructions stepCount]];
		[stepSlider setValue:currentStepNumber animated:YES];
		
		// Update label text.
		[stepLabel setText:[NSString stringWithFormat:@"%d of %d", currentStepNumber, [instructions stepCount]]];
		
		// Tell legoview the right bricks to draw.
		[legoView displayBricks:[instructions bricksForStepsOneThrough:currentStepNumber]];
	});
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
		// Walk backwards to grab the splash screen.
		id vc_instructions = self;
		id vc_reviewing = [vc_instructions presentingViewController];
		id vc_capturing = [vc_reviewing presentingViewController];
		id vc_splash = [vc_capturing presentingViewController];
		
		[vc_splash dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
