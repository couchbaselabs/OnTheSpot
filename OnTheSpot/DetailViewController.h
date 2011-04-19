//
//  DetailViewController.h
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController {
    @private
    UIImageView* _imageView;
    UITextView* _textView;
}
@property(nonatomic,retain) IBOutlet UIImageView* imageView;
@property(nonatomic,retain) IBOutlet UITextView* textView;

@end
