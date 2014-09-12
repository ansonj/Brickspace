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

@property (weak, nonatomic) IBOutlet UILabel *imagePreviewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreviewView;

@property (strong, nonatomic) IBOutletCollection(id) NSArray *structureConnectCollection;
@property (weak, nonatomic) IBOutlet UISwitch *structureSwitch;
@property (weak, nonatomic) IBOutlet UILabel *structureStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *structureAlignmentView;

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
@synthesize structureConnectCollection, structureSwitch, structureStatusLabel, structureAlignmentView;
@synthesize statusLabel;
@synthesize captureButton, forwardButton;

#pragma mark - Inits and viewDidThings

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_capturedImages = [NSMutableArray array];
    }
	
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[self updateUI];
	
	_captureMaster = [[BKPCaptureMaster alloc] initWithCameraPreviewView:cameraPreviewView];
	[_captureMaster setDelegate:self];
	[_captureMaster startPreviewing];
	
	//TODO: maybe rm notification for proc image update?
		// I don't get this comment -- remove it from where? What did I mean?
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIFromNotification:) name:@"ProcessedImageUpdated" object:nil];
	
	// For resuming the stream
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotificationReceived) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	NSLog(@"%@ got a memory warning.", self);
}

- (void)appDidEnterBackgroundNotificationReceived {
	[structureSwitch setOn:NO];
	[self structureSwitchChanged:nil];
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
		// perform h4x
		busyWaitIterations++;
	}
	if (busyWaitIterations > 0)
		NSLog(@"⚠️ Busy wait for capturing to finish took %lu iterations.", busyWaitIterations);
		
	BKPReviewBricksViewController *newVC = [[BKPReviewBricksViewController alloc] init];
	
	[newVC loadCapturedImages:_capturedImages];
		
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	[window setRootViewController:newVC];
}

- (IBAction)structureSwitchChanged:(id)sender {
	[_captureMaster setStructureSensorEnabled:[structureSwitch isOn]];
}

#pragma mark - Update that UI!

- (void)updateUI {
	dispatch_async(dispatch_get_main_queue(), ^{
		/// gotta do it on the main thread
		if ([_capturedImages count] > 0) {
			[imagePreviewLabel setHidden:NO];
			[imagePreviewView setImage:[[_capturedImages lastObject] processedImage]];
			[forwardButton setEnabled:YES];
		} else {
			[imagePreviewLabel setHidden:YES];
			[imagePreviewView setImage:nil];
			[forwardButton setEnabled:NO];
		}
		
		if ([_captureMaster isPreviewing]) {
			[captureButton setEnabled:YES];
			
			for (id view in structureConnectCollection) {
				[view setHidden:NO];
			}
			[structureSwitch setEnabled:YES];
		} else {
			[captureButton setEnabled:NO];
			
			
			for (id view in structureConnectCollection) {
				[view setHidden:YES];
			}
			[structureSwitch setEnabled:NO];
			// Turn off connecting to the Structure if the view is not previewing.
			[structureSwitch setOn:NO];
			[self structureSwitchChanged:structureSwitch];
		}
		
		if ([structureSwitch isOn]) {
			[structureStatusLabel setHidden:NO];
			[structureStatusLabel setText:[_captureMaster structureStatusString]];
			[structureAlignmentView setHidden:NO];
		} else {
			[structureStatusLabel setHidden:YES];
			[structureStatusLabel setText:@""];
			[structureAlignmentView setHidden:YES];
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
	// Custom override point when you are capturing multiple images. This is the end of the line.
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
