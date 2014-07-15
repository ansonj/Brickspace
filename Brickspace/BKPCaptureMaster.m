//
//  BKPCaptureMaster.m
//  Scanning Final
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPCaptureMaster.h"
#import "AppleVideoPreviewView.h"

@interface BKPCaptureMaster () <AVCaptureVideoDataOutputSampleBufferDelegate, STSensorControllerDelegate>

@end

@implementation BKPCaptureMaster {
	BOOL _isPreviewing;
	
	STSensorController *sensorController;
	BOOL delegateIsWaitingForCapture;
	
	AVCaptureSession *avSession;
	AVCaptureStillImageOutput *stillImageOutput;
}

@synthesize delegate;
@synthesize cameraPreviewView;

#pragma mark - Public initialization

- (id)init {
	return [self initWithCameraPreviewView:nil];
}

- (id)initWithCameraPreviewView:(AppleVideoPreviewView *)view {
	self = [super init];
	
	if (self) {
		[self setCameraPreviewView:view];
		
		delegateIsWaitingForCapture = NO;
		
		sensorController = [STSensorController sharedController];
		[sensorController setDelegate:self];
		[sensorController setFrameSyncConfig:FRAME_SYNC_DEPTH_AND_RGB]; //???: where should this be?
	}
	
	return self;
}

#pragma mark - Public interface

- (void)startPreviewing {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self async_startPreviewing];
	});
}

- (void)stopPreviewing {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self async_stopPreviewing];
	});
}

- (BOOL)isPreviewing {
	return _isPreviewing;
}

- (void)performCapture {
	assert(_isPreviewing);
	
	if ([sensorController isConnected]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self async_initiateDepthAndColorImageCapture];
		});
	} else {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self async_initiateColorImageCapture];
		});
	}
}

#pragma mark - Now we're getting serious.

#pragma mark - AVSession configuration

- (void)async_startPreviewing {
	avSession = [[AVCaptureSession alloc] init];
	
	[(AVCaptureVideoPreviewLayer *)[cameraPreviewView layer] setSession:avSession];
	
	[avSession beginConfiguration];
	
	[avSession setSessionPreset:AVCaptureSessionPresetMedium];
	
	
	////////// VIDEO INPUT
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error;
	
	if ([videoDevice lockForConfiguration:&error]) {
		AVCaptureExposureMode desiredExposureMode = AVCaptureExposureModeContinuousAutoExposure;
		AVCaptureFlashMode desiredFlashMode = AVCaptureFlashModeAuto;
		
		if ([videoDevice isExposureModeSupported:desiredExposureMode]) {
			[videoDevice setExposureMode:desiredExposureMode];
//			NSLog(@"Yes, I've set the exposure to %d", desiredExposureMode);
		}
		
		if ([videoDevice isFlashModeSupported:desiredFlashMode])
			[videoDevice setFlashMode:desiredFlashMode];
		
		[videoDevice unlockForConfiguration];
	} else {
		NSLog(@"Had error when trying to set autoexposure for iPad camera: %@", error);
	}
//	NSLog(@"The exposure is now %d", videoDevice.exposureMode);
	
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
	
	if (!videoInput) {
		NSLog(@"No video device found! Are you running in the simulator again?");
		if (error)
			NSLog(@"Video device error: %@", [error localizedDescription]);
		return;
	}
	
	[avSession addInput:videoInput];
	
	[[(AVCaptureVideoPreviewLayer *)[[self cameraPreviewView] layer] connection] setVideoOrientation:[delegate getInterfaceOrientation]];
	
	////////// STILL IMAGE OUTPUT
	stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	if ([avSession canAddOutput:stillImageOutput]) {
		[stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
		[avSession addOutput:stillImageOutput];
	}
	
	////////// SET SELF AS DELEGATE TO RECEIVE VIDEO FRAMES
	// from Viewer, vc, 365
	AVCaptureVideoDataOutput *frameOutput = [[AVCaptureVideoDataOutput alloc] init];
	[frameOutput setAlwaysDiscardsLateVideoFrames:YES];
	[frameOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
	[frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	[avSession addOutput:frameOutput];
	
	[avSession commitConfiguration];
	
	[avSession startRunning];
	
	
	// just in case...
	if ([sensorController isConnected])
		[self structureGoodThingHappened];
	
	
	_isPreviewing = YES;
	[delegate previewingDidStart];
}

- (void)async_stopPreviewing {
	_isPreviewing = NO;

	[avSession stopRunning];
	
	[delegate previewingDidStop];
	// We have to tell the delegate LAST, or else some calls to zombies might take place.
	// Let's really shut everything down before we say we have!
}

#pragma mark - Color image capturing

- (void)async_initiateColorImageCapture {
	AVCaptureVideoOrientation orientation = [[(AVCaptureVideoPreviewLayer *)[cameraPreviewView layer] connection] videoOrientation];
	[[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
	
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		[self async__finishedColorImageCapture:imageDataSampleBuffer withError:error];
	}];
}

- (void)async__finishedColorImageCapture:(CMSampleBufferRef)buffer withError:(NSError *)error {
	if (error)
		NSLog(@"Finished color image capture with error: %@", [error localizedDescription]);
	
	[delegate captureMasterDidOutputAVFColorBuffer:buffer];
}

#pragma mark - Structure Sensor - Starting streaming and capturing delegate methods

- (void)async_initiateDepthAndColorImageCapture {
	delegateIsWaitingForCapture = YES;
}

- (void)structureGoodThingHappened {
	STSensorControllerInitStatus result = [sensorController initializeSensorConnection];
	BOOL connectionEstablished = (result == STSensorControllerInitStatusSuccess || result == STSensorControllerInitStatusAlreadyInitialized);
	
	[sensorController setFrameSyncConfig:FRAME_SYNC_DEPTH_AND_RGB];
	
	if (connectionEstablished) {
		NSLog(@"✅ Stream says it was a success.");
		[sensorController startStreamingWithConfig:CONFIG_VGA_DEPTH];
	} else {
		NSLog(@"❌❌ Stream appears to have failed.");
		switch (result) {
			case STSensorControllerInitStatusSensorNotFound:
				NSLog(@"❌ Sensor not found.");
				break;
			case STSensorControllerInitStatusOpenFailed:
				NSLog(@"❌ Sensor open failed.");
				break;
			case STSensorControllerInitStatusSensorIsWakingUp:
				NSLog(@"❌ Sensor is slowly awakening.");
				break;
				
			default:
				NSLog(@"❌ Unknown err-or (%d).", (int)result);
				break;
		}
	}
}

- (void)structureBadThingHappened {
	[sensorController stopStreaming];
}

- (void)sensorDidOutputSynchronizedDepthFrame:(STDepthFrame *)depthFrame
								andColorFrame:(CMSampleBufferRef)sampleBuffer
{
	if (delegateIsWaitingForCapture) {
		[delegate captureMasterDidOutputSTColorBuffer:sampleBuffer andDepthFrame:depthFrame];
		delegateIsWaitingForCapture = NO;
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
	if ([sensorController isConnected])
		[sensorController frameSyncNewColorImage:sampleBuffer];
}

#pragma mark - Structure Sensor - Six required delegate methods

- (void)sensorDidConnect {
	NSLog(@"🌐 Sensor connected.");
	[self structureGoodThingHappened];
}

- (void)sensorDidDisconnect {
	NSLog(@"🌐 Sensor disconnected.");
	[self structureBadThingHappened];
}

- (void)sensorDidStopStreaming:(STSensorControllerDidStopStreamingReason)reason {
	NSLog(@"🌐 Sensor stopped streaming.");
	[self structureBadThingHappened];
}

- (void)sensorDidEnterLowPowerMode {
	NSLog(@"🌐 Sensor has entered low power mode. Please charge.");
	[self structureBadThingHappened];
}

- (void)sensorDidLeaveLowPowerMode {
	NSLog(@"🌐 Sensor has left low power mode.");
	[self structureGoodThingHappened];
}

- (void)sensorBatteryNeedsCharging {
	NSLog(@"🌐 Sensor battery needs charging.");
	[self structureBadThingHappened];
}


@end
