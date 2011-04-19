//
//  RootViewController.h
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CMMotionManager.h>

@interface RootViewController : UITableViewController
< UINavigationControllerDelegate
, UIImagePickerControllerDelegate
> {

    @private
    NSMutableArray* _motionSamples;
    CMMotionManager* _motionManager;
    NSTimer* _sampleTimer;
}

- (IBAction)takePicture;

@end
