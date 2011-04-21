//
//  RootViewController.h
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CMMotionManager.h>
#import <CoreLocation/CoreLocation.h>

@interface RootViewController : UITableViewController
< UINavigationControllerDelegate
, UIImagePickerControllerDelegate
, CLLocationManagerDelegate
> {

    @private
    NSMutableArray* _images;
    NSMutableArray* _motionSamples;
    CMMotionManager* _motionManager;
    CLLocationManager* _locationManager;
    NSMutableArray* _locationSamples;
    NSMutableArray* _headingSamples;
    NSTimer* _sampleTimer;
}

- (IBAction)takePicture;

@end
