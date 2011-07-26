//
//  ColorTrackingCamera.m
//  ColorTracking
//
//
//  The source code for this application is available under a BSD license.  See License.txt for details.
//
//  Created by Brad Larson on 10/9/2010.
//

#import "ColorTrackingCamera.h"
#import "ColorTrackingAppDelegate.h"
#import "ColorTrackingViewController.h"


@implementation ColorTrackingCamera

#pragma mark -
#pragma mark Initialization and teardown

- (id)init; 
{
	if (!(self = [super init]))
		return nil;
	
	// Grab the back-facing camera
//	AVCaptureDevice *backFacingCamera = nil;
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) 
	{
		if ([device position] == AVCaptureDevicePositionBack) 
		{
			backFacingCamera = device;
		}
	}
	
	NSError *error = nil;
	
    if ([backFacingCamera lockForConfiguration:&error]) {
		// location should be CGPoint
		// [backFacingCamera setFocusPointOfInterest:location];
		[backFacingCamera setFocusMode:AVCaptureFocusModeAutoFocus];

//		[backFacingCamera	addObserver:self
//							forKeyPath:@"adjustingWhiteBalance"
//							options:NSKeyValueObservingOptionNew
//							context:nil];

		ColorTrackingAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		ColorTrackingViewController *viewController = [appDelegate colorTrackingViewController];
		UIView *overlay = [viewController overlay];
		[overlay setHidden:NO];
		
		[backFacingCamera	addObserver:self
						    forKeyPath:@"adjustingExposure"
							options:NSKeyValueObservingOptionNew
							context:nil];
		
		
		//[backFacingCamera setExposurePointOfInterest:location];
		[backFacingCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
		[backFacingCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure]; 
		//[backFacingCamera setExposureMode:AVCaptureExposureModeLocked];
		if ([backFacingCamera isTorchModeSupported:AVCaptureTorchModeOn]){
			[backFacingCamera setTorchMode:AVCaptureTorchModeOn];
		}
		[backFacingCamera unlockForConfiguration];
    }
    else {
        // Respond to the failure as appropriate.
	}
	NSLog(@"SET AVCaptureExposureModeContinuousAutoExposure!!!!");

	
	// Create the capture session
	captureSession = [[AVCaptureSession alloc] init];
	
	// Add the video input	
	videoInput = [[[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error] autorelease];
	if ([captureSession canAddInput:videoInput]) 
	{
		[captureSession addInput:videoInput];
	}
	
	[self videoPreviewLayer];
	// Add the video frame output	
	videoOutput = [[AVCaptureVideoDataOutput alloc] init];
	[videoOutput setAlwaysDiscardsLateVideoFrames:YES];
	// Use RGB frames instead of YUV to ease color processing
	[videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//	dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracking.videoqueue", NULL);
//	[videoOutput setSampleBufferDelegate:self queue:videoQueue];

//	dispatch_queue_t videoQueue = dispatch_queue_create("com.sunsetlakesoftware.colortracking.videoqueue", NULL);
	[videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

	if ([captureSession canAddOutput:videoOutput])
	{
		[captureSession addOutput:videoOutput];
	}
	else
	{
		NSLog(@"Couldn't add video output");
	}

	// Start capturing
//	[captureSession setSessionPreset:AVCaptureSessionPresetHigh];
	[captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	if (![captureSession isRunning])
	{
		[captureSession startRunning];
	};
	
	return self;
}

- (void)dealloc 
{
	[captureSession stopRunning];

	[captureSession release];
	[videoPreviewLayer release];
	[videoOutput release];
	[videoInput release];
	[backFacingCamera release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	[self.delegate processNewCameraFrame:pixelBuffer];
}

#pragma mark -
#pragma mark Accessors

@synthesize delegate;
@synthesize videoPreviewLayer;

- (AVCaptureVideoPreviewLayer *)videoPreviewLayer;
{
	if (videoPreviewLayer == nil)
	{
		videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
        
        if ([videoPreviewLayer isOrientationSupported]) 
		{
            [videoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	}
	
	return videoPreviewLayer;
}

-(void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*) change context:(void*)context{
//	if ([change objectForKey:NSKeyValueChangeNewKey] == NO) {
//		[backFacingCamera removeObserver:self forKeyPath:@"adjustingExposure"];
//	}
	if ([keyPath isEqual:@"adjustingExposure"]){
		if ([object isAdjustingExposure] == NO) {
			NSLog(@"EXPOSURE ADJUSTMENT STOPPED!!!!");
				
			[object removeObserver:self forKeyPath:@"adjustingExposure"];
		
			ColorTrackingAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
			ColorTrackingViewController *viewController = [appDelegate colorTrackingViewController];
			UIView *overlay = [viewController overlay];
			[overlay setHidden:YES];
			
			[self performSelector:@selector(lockCameraSettings) withObject:nil afterDelay:0.001];
		
			NSLog(@"Trying to play sound!!");
			AudioServicesPlayAlertSound ([viewController soundFileObject]);
		}
	}
	
//    [super observeValueForKeyPath:keyPath
//						 ofObject:object
//						   change:change
//						  context:context];
}

-(void)lockCameraSettings{
	NSError *error = nil;
	if ([backFacingCamera lockForConfiguration:&error]) { 
		[backFacingCamera setExposureMode:AVCaptureExposureModeLocked];
		[backFacingCamera setExposureMode:AVCaptureWhiteBalanceModeLocked];
		[backFacingCamera unlockForConfiguration];
	}
}

- (void)startObserver{
	
	NSError *error = nil;
	if ([backFacingCamera lockForConfiguration:&error]) {
		[backFacingCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
		[backFacingCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure]; 
		[backFacingCamera unlockForConfiguration];
	}
	
	[backFacingCamera	addObserver:self
					    forKeyPath:@"adjustingExposure"
						options:NSKeyValueObservingOptionNew
						context:nil];
}


@end
