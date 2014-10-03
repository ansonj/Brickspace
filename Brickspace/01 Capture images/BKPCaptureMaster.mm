//
//  BKPCaptureMaster.m
//  Brickspace
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "AppleVideoPreviewView.h"
#import "BKPCaptureMaster.h"

typedef NS_ENUM(NSUInteger, BKPCMCameraStatus) {
	BKPCMCameraStatusUnknown,
	BKPCMCameraStatusStopped,
	BKPCMCameraStatusStarting,
	BKPCMCameraStatusPreviewing,
	BKPCMCameraStatusStopping
};

@interface BKPCaptureMaster () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic) BKPCMCameraStatus cameraStatus;
@end

@implementation BKPCaptureMaster {
	BOOL _delegateIsWaitingForCapture;
		
	AVCaptureSession *_avSession;
	AVCaptureStillImageOutput *_stillImageOutput;
}

@synthesize delegate;
@synthesize cameraPreviewView;
@synthesize cameraStatus = _cameraStatus;

#pragma mark - Public initialization

- (id)init {
	return [self initWithCameraPreviewView:nil];
}

- (id)initWithCameraPreviewView:(AppleVideoPreviewView *)view {
	self = [super init];
	
	if (self) {
		[self setCameraPreviewView:view];
		
		[self setCameraStatus:BKPCMCameraStatusUnknown];
		
		_delegateIsWaitingForCapture = NO;
	}
	
	return self;
}

- (void)dealloc {
	[self setDelegate:nil];
}

#pragma mark - Public interface

- (void)startPreviewing {
	[self setCameraStatus:BKPCMCameraStatusStarting];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self async_startPreviewing];
	});
}

- (void)stopPreviewing {
	[self setCameraStatus:BKPCMCameraStatusStopping];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self async_stopPreviewing];
	});
}

- (BOOL)isPreviewing {
	return (self.cameraStatus == BKPCMCameraStatusPreviewing);
}

- (NSString *)captureMasterStatusString {
	// Here, check my enum'd ivars.
	
	NSString *result = [NSString string];
	
	switch (self.cameraStatus) {
		case BKPCMCameraStatusUnknown:
		default:
			result = [result stringByAppendingString:@"The camera is missing or malfunctioning."];
			break;
		case BKPCMCameraStatusStopped:
			result = [result stringByAppendingString:@"The camera is not running."];
			break;
		case BKPCMCameraStatusStarting:
			result = [result stringByAppendingString:@"The camera is starting..."];
			break;
		case BKPCMCameraStatusStopping:
			result = [result stringByAppendingString:@"The camera is stopping."];
			break;
		case BKPCMCameraStatusPreviewing:
			result = [result stringByAppendingString:@"The camera is ready."];
			break;
	}
	
	return result;
}

- (void)performCapture {
	if (self.cameraStatus == BKPCMCameraStatusPreviewing) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self async_initiateColorImageCapture];
		});
	} else {
		NSLog(@"❌❌❌❌ You tried to %s on a %@ that wasn't previewing.", __PRETTY_FUNCTION__, [self class]);
	}
}

#pragma mark - Now we're getting serious.

- (void)setCameraStatus:(BKPCMCameraStatus)cameraStatus {
	_cameraStatus = cameraStatus;
	
	[delegate captureMasterStatusChanged];
}

#pragma mark - AVSession configuration

- (void)async_startPreviewing {
	_avSession = [[AVCaptureSession alloc] init];
	
	[(AVCaptureVideoPreviewLayer *)[cameraPreviewView layer] setSession:_avSession];
	
	[_avSession beginConfiguration];
	
	[_avSession setSessionPreset:AVCaptureSessionPreset640x480];

	
	// Video input.
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error;
	
	if ([videoDevice lockForConfiguration:&error]) {
		AVCaptureExposureMode desiredExposureMode = AVCaptureExposureModeContinuousAutoExposure;
		AVCaptureFlashMode desiredFlashMode = AVCaptureFlashModeAuto;
		
		if ([videoDevice isExposureModeSupported:desiredExposureMode]) {
			[videoDevice setExposureMode:desiredExposureMode];
		}
		
		if ([videoDevice isFlashModeSupported:desiredFlashMode])
			[videoDevice setFlashMode:desiredFlashMode];
		
		[videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
        [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
		
		[videoDevice unlockForConfiguration];
	} else {
		NSLog(@"Had error when trying to set autoexposure for iPad camera: %@", error);
	}
	
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	
	if (!videoInput) {
		NSLog(@"No video device found! Are you running in the simulator again?");
		if (error)
			NSLog(@"Video device error: %@", [error localizedDescription]);
		return;
	}
	
	[_avSession addInput:videoInput];
	
	[[(AVCaptureVideoPreviewLayer *)[[self cameraPreviewView] layer] connection] setVideoOrientation:[delegate getInterfaceOrientation]];
	
	// Still image output.
	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	if ([_avSession canAddOutput:_stillImageOutput]) {
		[_stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
		[_avSession addOutput:_stillImageOutput];
	}
	
	// Set self as the delegate to receive video frames.
	// These few lines are from Occipital's Viewer sample code, ViewController.mm:549.
	AVCaptureVideoDataOutput *frameOutput = [[AVCaptureVideoDataOutput alloc] init];
	[frameOutput setAlwaysDiscardsLateVideoFrames:YES];
	[frameOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
	[frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	[_avSession addOutput:frameOutput];
	
	[_avSession commitConfiguration];
	
	[_avSession startRunning];
	
	
	// Done.
	[self setCameraStatus:BKPCMCameraStatusPreviewing];
	
	[delegate previewingDidStart];
}

- (void)async_stopPreviewing {
	[self setCameraStatus:BKPCMCameraStatusStopped];
	
	[_avSession stopRunning];
	
	[delegate previewingDidStop];
	// We have to tell the delegate LAST, or else some calls to zombies might take place.
	// Let's really shut everything down before we say we have!
}

#pragma mark - Color image capturing

- (void)async_initiateColorImageCapture {
	AVCaptureVideoOrientation orientation = [[(AVCaptureVideoPreviewLayer *)[cameraPreviewView layer] connection] videoOrientation];
	[[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
	
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		[self async__finishedColorImageCapture:imageDataSampleBuffer withError:error];
	}];
}

- (void)async__finishedColorImageCapture:(CMSampleBufferRef)buffer withError:(NSError *)error {
	if (error)
		NSLog(@"Finished color image capture with error: %@", [error localizedDescription]);
	
	[delegate captureMasterDidOutputAVFColorBuffer:buffer];
}

- (void)debug_printValues {
	switch (self.cameraStatus) {
		case BKPCMCameraStatusPreviewing:
			NSLog(@"BKPCMCameraStatusPreviewing");
			break;
		case BKPCMCameraStatusStarting:
			NSLog(@"BKPCMCameraStatusStarting");
			break;
		case BKPCMCameraStatusStopped:
			NSLog(@"BKPCMCameraStatusStopped");
			break;
		case BKPCMCameraStatusStopping:
			NSLog(@"BKPCMCameraStatusStopping");
			break;
		case BKPCMCameraStatusUnknown:
			NSLog(@"BKPCMCameraStatusUnknown");
			break;
		default:
			NSLog(@"BKPCMCameraStatus ???");
			break;
	}
}

@end
