//
//  RootViewController.h
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController
< UINavigationControllerDelegate
, UIImagePickerControllerDelegate
> {

}

- (IBAction)takePicture;

@end
