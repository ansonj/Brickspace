//
//  BKPSplashViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/6/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPSplashViewController.h"
#import "BKPLegoView.h"
#import "BKPPlacedBrick.h"
#import "BKPCapturingViewController.h"

@interface BKPSplashViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *leftScrollView;

@property (weak, nonatomic) IBOutlet BKPLegoView *basicBricksLegoView;
@property (weak, nonatomic) IBOutlet BKPLegoView *structureBricksLegoView;
@end

@implementation BKPSplashViewController

@synthesize leftScrollView;
@synthesize basicBricksLegoView, structureBricksLegoView;

- (void)viewDidAppear:(BOOL)animated {
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
		float spacing = 1;

		// Calculate where to start placing the bricks so that they're centered.
		float xPosition = -(6 + spacing);
		float yPosition = 2 + spacing / 2.0;
		// Center it a bit better.
		xPosition /= 1.5;
		yPosition /= 1.5;
		
		for (int brickIndex = 0; brickIndex < numberOfColors; brickIndex++) {
			[brickSet[brickIndex] setX:xPosition Y:yPosition andZ:0];
			
			if (brickIndex % 2 == 0) {
				// Move down.
				yPosition -= 2 + spacing;
			} else {
				// Move up and to the right.
				yPosition += 2 + spacing;
				xPosition += 4 + spacing;
			}
		}
		
		[basicBricksLegoView displayBricks:[NSSet setWithArray:brickSet]];
	}
	
	// Set up bricks for structureBricksLegoView.
	{
		BKPPlacedBrick *b2x1 = [[BKPPlacedBrick alloc] init];
		BKPPlacedBrick *b2x2 = [[BKPPlacedBrick alloc] init];
		BKPPlacedBrick *b2x3 = [[BKPPlacedBrick alloc] init];
		
		[b2x1 setBrick:[BKPBrick brickWithColor:BKPBrickColorRed shortSide:1 longSide:2 andHeight:3]];
		[b2x2 setBrick:[BKPBrick brickWithColor:BKPBrickColorRed shortSide:2 longSide:2 andHeight:3]];
		[b2x3 setBrick:[BKPBrick brickWithColor:BKPBrickColorRed shortSide:2 longSide:3 andHeight:3]];
		
		float spacing = 2;
		[b2x1 setX:-(2 + spacing) Y:-0.5 andZ:0];
		[b2x2 setX:0 Y:0 andZ:0];
		[b2x3 setX:(2 + spacing) Y:0 andZ:0];
		
		[structureBricksLegoView displayBricks:[NSSet setWithArray:@[b2x1, b2x2, b2x3]]];
	}
	
	// Set up scrollView with introductory text.
	UIView *introTextView = [[[NSBundle mainBundle] loadNibNamed:@"BKPIntroTextView" owner:self options:nil] objectAtIndex:0];
	[leftScrollView addSubview:introTextView];
	[leftScrollView setContentSize:[introTextView frame].size];
	[leftScrollView flashScrollIndicators];
}

- (IBAction)startButtonPressed:(id)sender {
	BKPCapturingViewController *capturingVC = [[BKPCapturingViewController alloc] init];
	[self presentViewController:capturingVC animated:YES completion:nil];
}

@end
