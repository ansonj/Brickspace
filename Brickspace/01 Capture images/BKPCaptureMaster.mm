//
//  BKPCaptureMaster.m
//  Scanning Final
//
//  Created by Anson Jablinski on 7/2/14.
//  Copyright (c) 2014 Anson Jablinski. All rights reserved.
//

#import "BKPCaptureMaster.h"
#import "AppleVideoPreviewView.h"

typedef NS_ENUM(NSUInteger, BKPCMCameraStatus) {
	BKPCMCameraStatusUnknown,
	BKPCMCameraStatusStopped,
	BKPCMCameraStatusStarting,
	BKPCMCameraStatusPreviewing,
	BKPCMCameraStatusStopping
};

typedef NS_ENUM(NSUInteger, BKPCMStructureStatus) {
	BKPCMStructureStatusUnknown,
	BKPCMStructureStatusLookingForSensor,
	BKPCMStructureStatusSensorNeedsCharging,
	BKPCMStructureStatusStreaming
};

@interface BKPCaptureMaster () <AVCaptureVideoDataOutputSampleBufferDelegate, STSensorControllerDelegate>
@property (nonatomic) BKPCMCameraStatus cameraStatus;
@property (nonatomic) BKPCMStructureStatus structureStatus;
@end

@implementation BKPCaptureMaster {
	NSTimer *_structureConnectionTimer;
	
	STSensorController *_sensorController;
	BOOL _delegateIsWaitingForCapture;
		
	AVCaptureSession *_avSession;
	AVCaptureStillImageOutput *_stillImageOutput;
}

@synthesize delegate;
@synthesize cameraPreviewView;
@synthesize structureSensorEnabled = _structureSensorEnabled;
@synthesize cameraStatus = _cameraStatus;
@synthesize structureStatus = _structureStatus;

#pragma mark - Public initialization

- (id)init {
	return [self initWithCameraPreviewView:nil];
}

- (id)initWithCameraPreviewView:(AppleVideoPreviewView *)view {
	self = [super init];
	
	if (self) {
		[self setCameraPreviewView:view];
		
		[self setCameraStatus:BKPCMCameraStatusUnknown];
		[self setStructureStatus:BKPCMStructureStatusUnknown];
		
		_structureConnectionTimer = nil;
		
		[self setStructureSensorEnabled:NO];
		
		_delegateIsWaitingForCapture = NO;

		_sensorController = [STSensorController sharedController];
		[_sensorController setDelegate:self];
	}
	
	return self;
}

- (void)dealloc {
	if (_structureConnectionTimer)
		[_structureConnectionTimer invalidate];
	
	[_sensorController setDelegate:nil];
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

- (void)setStructureSensorEnabled:(BOOL)structureSensorEnabled {
	if (_structureSensorEnabled == structureSensorEnabled)
		return;
	
	assert(_structureSensorEnabled != structureSensorEnabled);
	_structureSensorEnabled = structureSensorEnabled;
	assert(_structureSensorEnabled == structureSensorEnabled);
	
	[self debug_printValues];
	
	if (_structureSensorEnabled && self.structureStatus == BKPCMStructureStatusUnknown) {
		[self setStructureStatus:BKPCMStructureStatusLookingForSensor];
		
		if (!_structureConnectionTimer)
			_structureConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(structureConnectionTimerFired:) userInfo:nil repeats:YES];
	} else if (!_structureSensorEnabled) {
		[_sensorController stopStreaming];
		[self setStructureStatus:BKPCMStructureStatusUnknown];
		
		if (_structureConnectionTimer)
			[_structureConnectionTimer invalidate];
		
		_structureConnectionTimer = nil;
	}
	
	[self debug_printValues];
}

- (NSString *)structureStatusString {
	if (!_sensorController)
		return @"❌❌";
	// here, just check STSensorController methods

	NSString *result = [NSString string];
	
	if ([_sensorController isConnected]) {
		// connected symbol
		result = [result stringByAppendingString:@"✅\n"];
		
		// name and serial
		{
			NSString *name = [_sensorController getName];
			NSString *serial = [_sensorController getSerialNumber];
			if (name && serial)
				result = [result stringByAppendingFormat:@"%@\n(serial %@)\n", name, serial];
		}
		
		// battery info
		{
			int batteryPercentage = [_sensorController getBatteryChargePercentage];
			if ([_sensorController isLowPower])
				result = [result stringByAppendingFormat:@"%d%% 🔋❗️", batteryPercentage];
			else if (batteryPercentage < 20)
				result = [result stringByAppendingFormat:@"%d%% 🔋⚠️", batteryPercentage];
			else
				result = [result stringByAppendingFormat:@"%d%% 🔋", batteryPercentage];
		}
	} else {
		result = [result stringByAppendingString:@"❌\n"];
	}
	
	
//	❔❗️‼️
	
	return result;
}

- (NSString *)captureMasterStatusString {
	// here, check my enum'd ivars
	
	NSString *result = [NSString string];
	
	switch (self.cameraStatus) {
		case BKPCMCameraStatusUnknown:
		default:
			result = [result stringByAppendingString:@"The camera is missing or malfunctioning.\n"];
			break;
		case BKPCMCameraStatusStopped:
			result = [result stringByAppendingString:@"The camera is not running.\n"];
			break;
		case BKPCMCameraStatusStarting:
			result = [result stringByAppendingString:@"The camera is starting...\n"];
			break;
		case BKPCMCameraStatusStopping:
			result = [result stringByAppendingString:@"The camera is stopping.\n"];
			break;
		case BKPCMCameraStatusPreviewing:
			result = [result stringByAppendingString:@"The camera is ready.\n"];
			break;
	}
	
	if (self.structureSensorEnabled) {
		switch (self.structureStatus) {
			case BKPCMStructureStatusUnknown:
			default:
				result = [result stringByAppendingString:@"The Structure Sensor is missing or malfunctioning."];
				break;
			case BKPCMStructureStatusLookingForSensor:
				result = [result stringByAppendingString:@"Searching for the Structure Sensor..."];
				break;
			case BKPCMStructureStatusSensorNeedsCharging:
				result = [result stringByAppendingString:@"[❗️] The Structure Sensor needs charging."];
				break;
			case BKPCMStructureStatusStreaming:
				result = [result stringByAppendingString:@"The Structure Sensor is ready."];
		}
	}
	
	return result;
}

- (void)performCapture {
	if (self.cameraStatus == BKPCMCameraStatusPreviewing && self.structureStatus == BKPCMStructureStatusStreaming) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self async_initiateDepthAndColorImageCapture];
		});
	} else if (self.cameraStatus == BKPCMCameraStatusPreviewing) {
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

- (void)setStructureStatus:(BKPCMStructureStatus)structureStatus {
	_structureStatus = structureStatus;
	
	[delegate captureMasterStatusChanged];
}

#pragma mark - AVSession configuration

- (void)async_startPreviewing {
	_avSession = [[AVCaptureSession alloc] init];
	
	[(AVCaptureVideoPreviewLayer *)[cameraPreviewView layer] setSession:_avSession];
	
	[_avSession beginConfiguration];
	
	[_avSession setSessionPreset:AVCaptureSessionPreset640x480];
	
	
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
		
		[videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
        [videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
		
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
	
	[_avSession addInput:videoInput];
	
	[[(AVCaptureVideoPreviewLayer *)[[self cameraPreviewView] layer] connection] setVideoOrientation:[delegate getInterfaceOrientation]];
	
	////////// STILL IMAGE OUTPUT
	_stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	if ([_avSession canAddOutput:_stillImageOutput]) {
		[_stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
		[_avSession addOutput:_stillImageOutput];
	}
	
	////////// SET SELF AS DELEGATE TO RECEIVE VIDEO FRAMES
	// from Viewer, vc, 365
	AVCaptureVideoDataOutput *frameOutput = [[AVCaptureVideoDataOutput alloc] init];
	[frameOutput setAlwaysDiscardsLateVideoFrames:YES];
	[frameOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
	[frameOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	[_avSession addOutput:frameOutput];
	
	[_avSession commitConfiguration];
	
	[_avSession startRunning];
	
	
	NSLog(@"The camera is running by now.");
	////////// DONE
	[self setCameraStatus:BKPCMCameraStatusPreviewing];
	
	[delegate previewingDidStart];
}

- (void)async_stopPreviewing {
	[self setCameraStatus:BKPCMCameraStatusStopped];
	[self setStructureStatus:BKPCMStructureStatusUnknown];
	
	[_avSession stopRunning];
	[_sensorController stopStreaming];
	
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

#pragma mark - Structure Sensor - Starting streaming and capturing delegate methods

- (void)async_initiateDepthAndColorImageCapture {
	_delegateIsWaitingForCapture = YES;
}

- (void)structureConnectionTimerFired:(NSTimer *)timer {
	NSLog(@"Timer fired (%@).", timer);
	// if looking, spawn connection attempt
	[self debug_printValues];
	if (self.structureSensorEnabled) {
		if (self.structureStatus == BKPCMStructureStatusLookingForSensor ||
			self.structureStatus == BKPCMStructureStatusUnknown) {
			[self tryToConnectToStructure];
		}
	}
}

- (void)debug_printValues {
	NSString *summary = @"structureSensorEnabled ";
	
	if (self.structureSensorEnabled)
		summary = [summary stringByAppendingString:@"true, "];
	else
		summary = [summary stringByAppendingString:@"FALSE, "];
	
	NSString *camera;
	switch (self.cameraStatus) {
		case BKPCMCameraStatusPreviewing:
			camera = @"BKPCMCameraStatusPreviewing";
			break;
		case BKPCMCameraStatusStarting:
			camera = @"BKPCMCameraStatusStarting";
			break;
		case BKPCMCameraStatusStopped:
			camera = @"BKPCMCameraStatusStopped";
			break;
		case BKPCMCameraStatusStopping:
			camera = @"BKPCMCameraStatusStopping";
			break;
		case BKPCMCameraStatusUnknown:
			camera = @"BKPCMCameraStatusUnknown";
			break;
		default:
			camera = @"BKPCMCameraStatus ???";
			break;
	}
		
	NSString *structure;
	switch (self.structureStatus) {
		case BKPCMStructureStatusLookingForSensor:
			structure = @"BKPCMStructureStatusLookingForSensor";
			break;
		case BKPCMStructureStatusSensorNeedsCharging:
			structure = @"BKPCMStructureStatusSensorNeedsCharging";
			break;
		case BKPCMStructureStatusStreaming:
			structure = @"BKPCMStructureStatusStreaming";
			break;
		case BKPCMStructureStatusUnknown:
			structure = @"BKPCMStructureStatusUnknown";
			break;
		default:
			structure = @"BKPCMStructureStatus ???";
			break;
	}
		
	summary = [summary stringByAppendingFormat:@"%@, %@, timer %@", camera, structure, _structureConnectionTimer];
	
	NSLog(@"%@", summary);
}

- (void)tryToConnectToStructure {
	NSLog(@"Can I try to connect to Structure?");
	[self debug_printValues];
	
	if (!self.structureSensorEnabled || self.structureStatus == BKPCMStructureStatusStreaming)
		return;
	
	NSLog(@"Yes. Attempting to connect to sensor.");
	
	STSensorControllerInitStatus result = [_sensorController initializeSensorConnection];
	BOOL connectionEstablished = (result == STSensorControllerInitStatusSuccess || result == STSensorControllerInitStatusAlreadyInitialized);
	
	[_sensorController setFrameSyncConfig:FRAME_SYNC_DEPTH_AND_RGB];
	
	if (connectionEstablished) {
		NSLog(@"✅ Stream says it was a success.");
		[_sensorController startStreamingWithConfig:CONFIG_VGA_DEPTH];
		[self setStructureStatus:BKPCMStructureStatusStreaming];
	} else {
		NSLog(@"❌❌ Stream appears to have failed.");
		switch (result) {
			case STSensorControllerInitStatusSensorNotFound:
				NSLog(@"\t❌ Sensor not found.");
				break;
			case STSensorControllerInitStatusOpenFailed:
				NSLog(@"\t❌ Sensor open failed.");
				break;
			case STSensorControllerInitStatusSensorIsWakingUp:
				NSLog(@"\t❌ Sensor is slowly awakening.");
				break;
				
			default:
				NSLog(@"\t❌ Unknown err-or (%d).", (int)result);
				break;
		}
	}
	
	NSLog(@"I just tried to connect to the sensor.");
	[self debug_printValues];
}

- (void)structureBadThingHappened {
	[_sensorController stopStreaming];
	[self setStructureStatus:BKPCMStructureStatusUnknown];
}

- (void)sensorDidOutputSynchronizedDepthFrame:(STDepthFrame *)depthFrame
								andColorFrame:(CMSampleBufferRef)sampleBuffer
{
	if (_delegateIsWaitingForCapture) {
		[delegate captureMasterDidOutputSTColorBuffer:sampleBuffer andDepthFrame:depthFrame];
		_delegateIsWaitingForCapture = NO;
	}
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
	if ([_sensorController isConnected])
		[_sensorController frameSyncNewColorImage:sampleBuffer];
}

#pragma mark - Structure Sensor - Six required delegate methods

- (void)sensorDidConnect {
	NSLog(@"🌐 Sensor connected.");
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
	[self setStructureStatus:BKPCMStructureStatusSensorNeedsCharging];
}

- (void)sensorDidLeaveLowPowerMode {
	NSLog(@"🌐 Sensor has left low power mode.");
	[self setStructureStatus:BKPCMStructureStatusUnknown];
}

- (void)sensorBatteryNeedsCharging {
	NSLog(@"🌐 Sensor battery needs charging.");
	[self setStructureStatus:BKPCMStructureStatusSensorNeedsCharging];
}


@end
