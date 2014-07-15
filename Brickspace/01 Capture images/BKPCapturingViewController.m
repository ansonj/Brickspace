//
//  BKPCapturingViewController.m
//  Scanning Final
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPCapturingViewController.h"

#import "AppleVideoPreviewView.h"
#import "BKPCaptureMaster.h"
#import "BKPScannedImageAndBricks.h"

#import "BKPReviewBricksViewController.h"

@interface BKPCapturingViewController () <CaptureMasterResultsDelegate>
@property (weak, nonatomic) IBOutlet AppleVideoPreviewView *cameraPreviewView;
@property (weak, nonatomic) IBOutlet UIView *pleaseWaitView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cameraLoadingSpinner;

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@end

@implementation BKPCapturingViewController {
	BKPCaptureMaster *captureMaster;
	
	NSMutableArray *capturedImages;
	
	BOOL capturingVCisWaitingToMoveToReviewVC;
}

#pragma mark - View synthesizers

@synthesize cameraPreviewView, pleaseWaitView, imagePreviewView;
@synthesize cameraLoadingSpinner;
@synthesize captureButton, forwardButton;

#pragma mark - Inits and viewDidThings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		capturedImages = [NSMutableArray array];
		
		capturingVCisWaitingToMoveToReviewVC = NO;
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	captureMaster = [[BKPCaptureMaster alloc] initWithCameraPreviewView:cameraPreviewView];
	[captureMaster setDelegate:self];
	
	[captureButton setTitle:@"Capturing..." forState:UIControlStateDisabled];
}

- (void)viewDidAppear:(BOOL)animated {
	[cameraLoadingSpinner startAnimating];
	
	[captureMaster startPreviewing];
	
	//TODO: maybe rm notification for proc image update?
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayLastCapturedImage) name:@"ProcessedImageUpdated" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	NSLog(@"%@ got a memory warning.", self);
}

#pragma mark - Button handlers

- (IBAction)captureButtonPressed:(id)sender {
	if (cameraLoadingSpinner.isAnimating || captureButton.hidden || !captureButton.enabled || !captureMaster.isPreviewing)
		return;
	
	[captureButton setEnabled:NO];
	[pleaseWaitView setHidden:NO];
	[imagePreviewView setHidden:YES];
	[captureMaster performCapture];
}

- (IBAction)forwardButtonPressed:(id)sender {
//	NSLog(@"Capture View says: 🎶 So long; farewell. 🎶");
	
	while ([captureMaster isPreviewing]) {
		
	}
		
	BKPReviewBricksViewController *newVC = [[BKPReviewBricksViewController alloc] init];
	
	[newVC loadCapturedImages:capturedImages];
		
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	
	[window setRootViewController:newVC];
	
	
}

#pragma mark - CaptureMaster delegate methods

- (void)previewingDidStart {
	[cameraLoadingSpinner stopAnimating];
	[captureButton setHidden:NO];
	[captureButton setEnabled:YES];
}

- (void)previewingDidStop {
	[captureButton setHidden:YES];
}

- (AVCaptureVideoOrientation)getInterfaceOrientation {
	return (AVCaptureVideoOrientation)[self interfaceOrientation];
}

- (void)captureMasterDidOutputAVFColorBuffer:(CMSampleBufferRef)buffer {
	BKPScannedImageAndBricks *newImage = [[BKPScannedImageAndBricks alloc] initWithAVFColorBuffer:buffer];
	[self addAndDisplayCapturedImage:newImage];
}

- (void)captureMasterDidOutputSTColorBuffer:(CMSampleBufferRef)buffer
							  andDepthFrame:(STDepthFrame *)depthFrame
{
	BKPScannedImageAndBricks *newImage = [[BKPScannedImageAndBricks alloc] initWithSTColorBuffer:buffer andDepthFrame:depthFrame];
	[self addAndDisplayCapturedImage:newImage];
}

- (void)addAndDisplayCapturedImage:(BKPScannedImageAndBricks *)image {
	[pleaseWaitView setHidden:YES];
	
	[captureMaster stopPreviewing];

	assert(image);
	[capturedImages addObject:image];
	
	[self displayLastCapturedImage];
	
//	[captureButton setEnabled:YES];
	
	[forwardButton setEnabled:YES];
}

- (void)displayLastCapturedImage {
	[imagePreviewView setImage:[[capturedImages lastObject] processedImage]];
	[imagePreviewView setHidden:NO];
}

@end
