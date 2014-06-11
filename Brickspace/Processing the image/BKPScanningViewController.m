//
//  BKPScanningViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 6/11/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPScanningViewController.h"

#import "BKPTempImageHolder.h"
#import "BKPBrickCounter.h"
#import "BKPDoneViewController.h"

@interface BKPScanningViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) BKPBrickCounter *brickCounter;

- (void)activateCamera;

@end


@implementation BKPScanningViewController {
	BOOL imageHasBeenTaken;
	BKPTempImageHolder *temporaryImageHolder;
}

@synthesize imageView;
@synthesize brickCounter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	imageHasBeenTaken = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	if (imageHasBeenTaken) {
		brickCounter = [[BKPBrickCounter alloc] initWithSourceImage:[temporaryImageHolder image]];
		[imageView setImage:[brickCounter processedImage]];
	} else {
		[self activateCamera];
	}
}

- (void)activateCamera {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
	else
		[imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[imagePicker setDelegate:self];
	[self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *newImage = [info valueForKey:UIImagePickerControllerOriginalImage];
	
	temporaryImageHolder = [[BKPTempImageHolder alloc] initWithImage:newImage];

	imageHasBeenTaken = YES;

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"showInstructions"]) {
		BKPDoneViewController *instructionsViewController = (BKPDoneViewController *)[segue destinationViewController];
		[instructionsViewController setUpWithCountedBricks:[brickCounter countedSetOfBricks]];
	}
}

@end
