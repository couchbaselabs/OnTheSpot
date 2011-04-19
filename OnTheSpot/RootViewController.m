//
//  RootViewController.m
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController()
@property (nonatomic, retain) NSTimer* sampleTimer;
- (void)storeImage:(UIImage*)anImage withMetaData:(NSDictionary*)metaData;
- (void)takeMotionSample:(NSTimer*)aTimer;
- (void)startMotionSampling;
- (void)stopMotionSampling;
@end


@implementation RootViewController

@synthesize sampleTimer = _sampleTimer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _motionManager = [CMMotionManager new];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _motionManager = [CMMotionManager new];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style])) {
        _motionManager = [CMMotionManager new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
	*/
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [_motionManager release];
    [super dealloc];
}

- (IBAction)takePicture
{
    // start background motion sampling
    [self performSelector
     :@selector(startMotionSampling) withObject:nil];

    // present camera ui
    UIImagePickerController *vc = [[UIImagePickerController alloc] init];
    vc.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController presentModalViewController:vc animated:YES];
    [vc release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self stopMotionSampling];
    [self.navigationController dismissModalViewControllerAnimated:YES];

    NSDictionary* metaData = (NSDictionary*)[info valueForKey:UIImagePickerControllerMediaMetadata];
    UIImage* image = (UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage];
    [self storeImage:image withMetaData:metaData];
}

- (void)storeImage:(UIImage*)anImage withMetaData:(NSDictionary*)metaData
{
    NSDictionary* exifData = [metaData valueForKey:@"{Exif}"];
    NSAssert(exifData != nil, @"Missing exif data");

    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy:MM:dd HH:mm:ss";
    NSString *dateTimeString = [exifData valueForKey:@"DateTimeOriginal"];
    NSDate* dateTimeDigitized = [dateFormatter dateFromString:dateTimeString];
    NSAssert(dateTimeDigitized != nil, @"Missing dateTimeDigitized");

    NSDictionary* motionData = nil;
    for (NSDictionary* sample in _motionSamples) {
        // NOTE: for some odd reason using isEqualToDate: never equals true,
        //       even though the dates are the same
        //       also using compare: with NSOrderedSame does not work properly.
        //       The current code is more fault tolerant, since the motion samples
        //       may not have been taken at the exact same time as the picture.
        NSDate* sampleTimestamp = [sample valueForKey:@"timestamp"];
        if ([dateTimeDigitized timeIntervalSinceDate:sampleTimestamp] <= 0.0) {
            motionData = sample;
            break;
        }
    }
    NSAssert(motionData != nil, @"Missing motion sample for image take at %@", metaData);

    NSMutableDictionary* jsonData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     metaData, @"mediaMetaData"
                                     , motionData, @"motionData"
                                     , nil];
    NSLog(@"JSON\n%@", jsonData);

    [dateFormatter release];
    // store image in CouchDB
}

- (void)startMotionSampling
{
    if (nil == _motionSamples) {
        _motionSamples = [[NSMutableArray alloc] init];
    }
    else {
        [_motionSamples removeAllObjects];
    }

    // start motion sensor updates
    if (!_motionManager.gyroActive && _motionManager.gyroAvailable) {
        _motionManager.gyroUpdateInterval = 1.0;
        [_motionManager startGyroUpdates];
    }
    if (!_motionManager.deviceMotionActive && _motionManager.deviceMotionAvailable) {
        _motionManager.deviceMotionUpdateInterval = 1.0;
        [_motionManager startDeviceMotionUpdates];
    }
    if (!_motionManager.accelerometerActive && _motionManager.accelerometerAvailable) {
        _motionManager.accelerometerUpdateInterval = 1.0;
        [_motionManager startAccelerometerUpdates];
    }

    self.sampleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(takeMotionSample:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void)stopMotionSampling
{
    [_sampleTimer invalidate];
    self.sampleTimer = nil;

    if (_motionManager.gyroActive && _motionManager.gyroAvailable) {
        [_motionManager stopGyroUpdates];
    }
    if (_motionManager.deviceMotionActive && _motionManager.deviceMotionAvailable) {
        [_motionManager stopDeviceMotionUpdates];
    }
    if (_motionManager.accelerometerActive && _motionManager.accelerometerAvailable) {
        [_motionManager stopAccelerometerUpdates];
    }
}

- (void)takeMotionSample:(NSTimer*)aTimer
{
    NSMutableDictionary* sample = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSDate date], @"timestamp"
                                   , _motionManager.gyroData, @"gyroData"
                                   , _motionManager.deviceMotion, @"deviceMotion"
                                   , _motionManager.accelerometerData, @"accelerometerData"
                                   , nil];
    [_motionSamples addObject:sample];
}

@end
