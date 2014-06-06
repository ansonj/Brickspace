//
//  BKPDoneViewController.m
//  Brickspace Stage I
//
//  Created by Anson Jablinski on 6/4/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPDoneViewController.h"

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
	NSString *summary = [NSString stringWithFormat:@"A BKPBrickSet was created with %lu bricks in it:\n",[completedBrickSet brickCount]];
	
	for (BKPBrick *brick in [completedBrickSet setOfBricks]) {
		summary = [summary stringByAppendingFormat:@"\t%@\n",brick];
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
