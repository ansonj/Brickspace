//
//  BKPDoneViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPDoneViewController.h"

#import "BKP_GDManager.h"
#import "BKPGenericDesign.h"

@interface BKPDoneViewController ()
@property (weak, nonatomic) IBOutlet UITextView *summaryTextView;
@end

@implementation BKPDoneViewController {
	BKPBrickSet *completedBrickSet;
}

@synthesize summaryTextView;

- (void)setUpWithBrickSet:(BKPBrickSet *)newSet {
	completedBrickSet = newSet;
	
	[self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateUI];
}

- (void)updateUI {
	NSString *summary = [NSString stringWithFormat:@"A BKPBrickSet was created with %lu bricks in it.\n\n",[completedBrickSet brickCount]];
	
	NSArray *availableDesigns = [BKP_GDManager availableDesigns];
	for (id<BKPGenericDesign> design in availableDesigns) {
		if ([design canBeBuiltFromBrickSet:completedBrickSet]) {
			NSString *designName = [design designName];
			float percentage = [design percentUtilizedIfBuiltWithSet:completedBrickSet];
			summary = [summary stringByAppendingFormat:@"You can build a %@ with %.1f%% brick utilization!\n", designName, percentage];
		}
	}
	
	
	
	
	[summaryTextView setText:summary];
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
