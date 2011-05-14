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
#import "Couchbase.h"


@interface RootViewController : UITableViewController
< UINavigationControllerDelegate
, UIImagePickerControllerDelegate
, CLLocationManagerDelegate
, CouchbaseDelegate
> {

    @private
    NSMutableArray* _images;
    NSMutableArray* _motionSamples;
    CMMotionManager* _motionManager;
    CLLocationManager* _locationManager;
    NSMutableArray* _locationSamples;
    NSMutableArray* _headingSamples;
    NSTimer* _sampleTimer;
    NSURL *_dbURL;
}
@property (nonatomic, retain) NSURL *dbURL;

- (IBAction)takePicture;

@end
