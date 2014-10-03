//
//  BKPSplashViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPCapturingViewController.h"
#import "BKPLegoView.h"
#import "BKPPlacedBrick.h"
#import "BKPSplashViewController.h"

@interface BKPSplashViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *leftScrollView;

@property (weak, nonatomic) IBOutlet BKPLegoView *basicBricksLegoView;
@end

@implementation BKPSplashViewController

@synthesize leftScrollView;
@synthesize basicBricksLegoView;

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Set up bricks for basicBricksLegoView.
	{
		NSMutableArray *brickSet = [NSMutableArray array];
		
		int numberOfColors = [BKPBrickColorOptions colorCount];
		for (int colorIndex = 0; colorIndex < numberOfColors; colorIndex++) {
			BKPBrickColor color = (BKPBrickColor)colorIndex;
			
			BKPPlacedBrick *placedBrick = [[BKPPlacedBrick alloc] init];
			[placedBrick setBrick:[BKPBrick brickWithColor:color shortSide:2 longSide:4 andHeight:3]];
			
			[brickSet addObject:placedBrick];
		}
		
		// What follows is more complex (and hacky) than it probably needs to be,
		// but it scales to however many brick colors we have.
		
		// How far apart should we space the bricks?
		float spacing = 2;

		// Calculate where to start placing the bricks so that they're centered.
		float xPosition = -(2 + spacing);
		float yPosition = (3 * numberOfColors / 4. - 3. / 2) + spacing / 2.0;
		
		for (int brickIndex = 0; brickIndex < numberOfColors; brickIndex++) {
			[brickSet[brickIndex] setX:xPosition Y:yPosition andZ:0];
			
			if (brickIndex % 2 == 0) {
				// Move to the right.
				xPosition += 4 + spacing;
			} else {
				// Move down and to the left.
				yPosition -= 2 + spacing;
				xPosition -= 4 + spacing;
			}
		}
		
		[basicBricksLegoView displayBricks:[NSSet setWithArray:brickSet]];
	}
	
	// Set up scrollView with introductory text.
	UIView *introTextView = [[[NSBundle mainBundle] loadNibNamed:@"BKPIntroTextView" owner:self options:nil] objectAtIndex:0];
	[leftScrollView addSubview:introTextView];
	[leftScrollView setContentSize:[introTextView frame].size];
	[leftScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
	[leftScrollView flashScrollIndicators];
}

- (IBAction)startButtonPressed:(id)sender {
	BKPCapturingViewController *capturingVC = [[BKPCapturingViewController alloc] init];
	[self presentViewController:capturingVC animated:YES completion:nil];
}

@end
