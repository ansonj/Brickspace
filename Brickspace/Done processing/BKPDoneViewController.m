//
//  BKPDoneViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPDoneViewController.h"

#import "BKPLegoView.h"
#import "BKP_GDManager.h"
#import "BKPGenericDesign.h"
#import "BKPInstructionSet.h"

@interface BKPDoneViewController ()
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@property (nonatomic) NSString *summaryText;
@property (weak, nonatomic) IBOutlet BKPLegoView *legoView;
@property (weak, nonatomic) IBOutlet UISlider *stepSlider;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

@property (nonatomic) NSSet *countedBrickSet;
@property (nonatomic) id<BKPGenericDesign> selectedDesign;
@property (nonatomic) BKPInstructionSet *instructions;
@property (nonatomic) int currentStepNumber;
@end

@implementation BKPDoneViewController

@synthesize summaryTextView, summaryText;
@synthesize legoView;
@synthesize stepSlider, stepLabel;

@synthesize countedBrickSet;
@synthesize selectedDesign;
@synthesize instructions;
@synthesize currentStepNumber;

- (void)setUpWithCountedBricks:(NSSet *)newSet {
	countedBrickSet = newSet;
	
	// figure out which is the best
	summaryText = [NSString stringWithFormat:@"An NSSet was created with %lu bricks in it.\n\n",(unsigned long)[countedBrickSet count]];
	
	NSArray *availableDesigns = [BKP_GDManager availableDesigns];
	for (id<BKPGenericDesign> design in availableDesigns) {
		if ([design canBeBuiltFromBricks:countedBrickSet]) {
			selectedDesign = design;
			NSString *designName = [design designName];
			float percentage = [design percentUtilizedIfBuiltWithSet:countedBrickSet];
			summaryText = [summaryText stringByAppendingFormat:@"You can build a %@ with %.1f%% brick utilization!\n", designName, percentage];
		}
	}
	
	summaryText = [summaryText stringByAppendingFormat:@"\n\nToday, you'll be building a %@, which is a %@.", [selectedDesign designName], [selectedDesign designDescription]];
	
	BKPRealizedModel *model = [selectedDesign createRealizedModelUsingBricks:countedBrickSet];
	instructions = [BKPInstructionGenerator instructionsForRealizedModel:model withStyle:BKPInstructionGeneratorStyleBottomUp];
	
	currentStepNumber = 1;
	
	[legoView setDrawAxes:NO];
	[legoView setDrawBaseplate:YES];
	[legoView setBaseplateColor:BKPBrickColorBlue andSize:8];
	
	// setup should be called first, before it appears, so it should be okay to comment this out
//	[self initializeUI];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
