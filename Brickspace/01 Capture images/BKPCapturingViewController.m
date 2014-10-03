//
//  BKPCapturingViewController.m
//  Brickspace
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "AppleVideoPreviewView.h"
#import "BKPCaptureMaster.h"
#import "BKPCapturingViewController.h"
#import "BKPReviewBricksViewController.h"
#import "BKPScannedImageAndBricks.h"

@interface BKPCapturingViewController () <CaptureMasterResultsDelegate>
@property (weak, nonatomic) IBOutlet AppleVideoPreviewView *cameraPreviewView;

@property (weak, nonatomic) IBOutlet UILabel *imagePreviewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@end

@implementation BKPCapturingViewController {
	BKPCaptureMaster *_captureMaster;
	
	NSMutableArray *_capturedImages;
}

#pragma mark - View synthesizers

@synthesize cameraPreviewView;
@synthesize imagePreviewLabel, imagePreviewView;
@synthesize statusLabel;
@synthesize captureButton, forwardButton;

#pragma mark - Inits and viewDidThings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		_capturedImages = [NSMutableArray array];
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self updateUI];
	
	_captureMaster = [[BKPCaptureMaster alloc] initWithCameraPreviewView:cameraPreviewView];
	[_captureMaster setDelegate:self];
	[_captureMaster startPreviewing];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIFromNotification:) name:@"ProcessedImageUpdated" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	NSLog(@"⚠️ %@ got a memory warning.", self);
}

#pragma mark - Button and switch handlers

- (IBAction)captureButtonPressed:(id)sender {
	if (![captureButton isEnabled])
		return;
	
	[_captureMaster performCapture];
	[self updateUI];
}

- (IBAction)forwardButtonPressed:(id)sender {
	[_captureMaster stopPreviewing];

	unsigned long busyWaitIterations = 0;
	while ([_captureMaster isPreviewing]) {
		// Perform h4x.
		busyWaitIterations++;
	}
	if (busyWaitIterations > 0)
		NSLog(@"⚠️ Busy wait for capturing to finish took %lu iterations.", busyWaitIterations);
		
	BKPReviewBricksViewController *reviewVC = [[BKPReviewBricksViewController alloc] init];
	
	[reviewVC loadCapturedImages:_capturedImages];
	
	[self presentViewController:reviewVC animated:YES completion:nil];
}

#pragma mark - Update that UI!

- (void)updateUI {
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([_capturedImages count] > 0) {
			[imagePreviewLabel setHidden:NO];
			[imagePreviewView setImage:[[_capturedImages lastObject] processedImage]];
			[forwardButton setHidden:NO];
		} else {
			[imagePreviewLabel setHidden:YES];
			[imagePreviewView setImage:nil];
			[forwardButton setHidden:YES];
		}
		
		if ([_captureMaster isPreviewing]) {
			[captureButton setHidden:NO];
		} else {
			[captureButton setHidden:YES];
		}
		
		[statusLabel setText:[_captureMaster captureMasterStatusString]];
	});
}

- (void)updateUIFromNotification:(NSNotification *)notification {
	[self updateUI];
}

#pragma mark - CaptureMaster delegate methods

- (void)previewingDidStart {
	[self updateUI];
}

- (void)previewingDidStop {
	[self updateUI];
}

- (void)captureMasterStatusChanged {
	[self updateUI];
}

- (AVCaptureVideoOrientation)getInterfaceOrientation {
	return (AVCaptureVideoOrientation)UIDeviceOrientationLandscapeLeft;
}

- (void)captureMasterDidOutputAVFColorBuffer:(CMSampleBufferRef)buffer {
	BKPScannedImageAndBricks *newImage = [[BKPScannedImageAndBricks alloc] initWithAVFColorBuffer:buffer];
	[self addAndDisplayCapturedImage:newImage];
}

- (void)addAndDisplayCapturedImage:(BKPScannedImageAndBricks *)image {
	// Custom override point when you are capturing multiple images.
//	if (image)
//		[_capturedImages addObject:image];
	
	// For now, we are just going to hold on to the last image captured.
	if (image) {
		[_capturedImages removeAllObjects];
		[_capturedImages addObject:image];
	}
	
	[self updateUI];
}

@end
