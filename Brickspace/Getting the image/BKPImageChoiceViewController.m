//
//  BKPImageChoiceViewController.m
//  Brickspace Stage I
//
//  Created by Anson Jablinski on 6/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPImageChoiceViewController.h"
#import "BKPProcessingViewController.h"

@interface BKPImageChoiceViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)activateCamera;

@end

@implementation BKPImageChoiceViewController {
	BOOL imageHasBeenTaken;
	BKPTempImageHolder *temporaryImageHolder;
}

@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	imageHasBeenTaken = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	if (imageHasBeenTaken)
		return;
	
	[self activateCamera];
}

- (void)activateCamera {
	// From BNR book p 245
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
	
	// rotation fix?
//	newImage = [UIImage imageWithCGImage:[newImage CGImage] scale:1 orientation:[newImage imageOrientation]];
	
	temporaryImageHolder = [[BKPTempImageHolder alloc] initWithImage:newImage];
	[imageView setImage:[temporaryImageHolder image]];
	imageHasBeenTaken = YES;
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)redoButtonPressed:(id)sender {
	[self activateCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	NSLog(@"Instance of %@ got a memory warning...",[self class]);
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	UIViewController *newController = [segue destinationViewController];
	
	if ([newController isMemberOfClass:[BKPProcessingViewController class]]) {
		UIImage *imageToSend = [temporaryImageHolder image];
		BKPProcessingViewController *controllerThatWillUseIt = (BKPProcessingViewController *)newController;
		[controllerThatWillUseIt setUpModelWithImage:imageToSend];
	}
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
