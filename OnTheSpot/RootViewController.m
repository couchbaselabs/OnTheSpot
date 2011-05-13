//
//  RootViewController.m
//  OnTheSpot
//
//  Created by afh on 19/04/11.
//  Copyright 2011 Alexis Hildebrandt. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "CJSONSerializer.h"

@interface RootViewController()
@property (nonatomic, retain) NSMutableArray* images;
@property (nonatomic, retain) NSTimer* sampleTimer;
- (void)storeImage:(UIImage*)anImage withMetaData:(NSDictionary*)metaData;
- (void)takeMotionSample:(NSTimer*)aTimer;
- (void)startMotionSampling;
- (void)stopMotionSampling;
@end


@implementation RootViewController

@synthesize sampleTimer = _sampleTimer;
@synthesize images = _images;
@synthesize couchURL=_couchURL;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _motionManager = [CMMotionManager new];
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.purpose = NSLocalizedString(@"Location services are used to attach the location of where a photo was taken.", nil);
    }
    return self;
}

- (void)couchbaseDidStart:(NSURL *)serverURL {
    self.couchURL = serverURL;
    //    self.navigationController.couchURL = serverURL;
    NSLog(@"Couch is woo ha!");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"On The Spot";
    if (_images == nil) {
        self.images = [NSMutableArray array];
    }
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
    return [_images count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSDictionary* jsonData = [_images objectAtIndex:indexPath.row];
    cell.textLabel.text = [[[jsonData valueForKey:@"mediaMetaData"] valueForKey:@"{Exif}"] valueForKey:@"DateTimeOriginal"];
    cell.imageView.image = [jsonData valueForKey:@"imageData"];

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

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    NSDictionary* jsonData = [_images objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    detailViewController.imageView.image = [jsonData valueForKey:@"imageData"];
    NSError* error = NULL;
    NSData* theJSON = [[CJSONSerializer serializer] serializeDictionary:jsonData error:&error];
    if (error != NULL) {
        NSLog(@"Error while serializing for view %@", jsonData);
        detailViewController.textView.text = [jsonData description];
    }
    else {
        detailViewController.textView.text = [[NSString alloc] initWithData:theJSON encoding:NSUTF8StringEncoding];
    }
    [detailViewController release];
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
    [_locationManager release];
    [super dealloc];
}

- (IBAction)takePicture
{
    // start background motion sampling
    [self startMotionSampling];

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

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"CLLocationManager:didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSMutableDictionary* sample = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSDate date], @"timestamp"
         , [NSNumber numberWithDouble:newLocation.coordinate.latitude], @"lat"
         , [NSNumber numberWithDouble:newLocation.coordinate.longitude], @"lon"
         , [NSNumber numberWithDouble:newLocation.altitude], @"altitude"
         , [NSNumber numberWithDouble:newLocation.course], @"course"
         , [NSNumber numberWithDouble:newLocation.speed], @"speed"
         , [NSNumber numberWithDouble:newLocation.horizontalAccuracy], @"horizontalAccuracy"
         , [NSNumber numberWithDouble:newLocation.verticalAccuracy], @"verticalAccuracy`"
                                   , nil];
    [_locationSamples addObject:sample];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    NSMutableDictionary* sample = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
           [NSDate date], @"timestamp"
           , [NSNumber numberWithDouble:newHeading.magneticHeading], @"magneticHeading"
           , [NSNumber numberWithDouble:newHeading.trueHeading], @"trueHeading"
           , [NSNumber numberWithDouble:newHeading.headingAccuracy], @"headingAccuracy"
           , nil];
    [_headingSamples addObject:sample];
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
            [sample removeObjectForKey:@"timestamp"];
            motionData = sample;
            break;
        }
    }
    NSAssert(motionData != nil, @"Missing motion sample for image take at %@", metaData);

    NSDictionary* locationData = nil;
    for (NSDictionary* sample in _locationSamples) {
        NSDate* sampleTimestamp = [sample valueForKey:@"timestamp"];
        if ([dateTimeDigitized timeIntervalSinceDate:sampleTimestamp] <= 0.0) {
            [sample removeObjectForKey:@"timestamp"];
            locationData = sample;
            break;
        }
    }

    NSMutableDictionary* headingData = nil;
    for (NSMutableDictionary* sample in _headingSamples) {
        NSDate* sampleTimestamp = [sample valueForKey:@"timestamp"];
        if ([dateTimeDigitized timeIntervalSinceDate:sampleTimestamp] <= 0.0) {
            [sample removeObjectForKey:@"timestamp"];
            headingData = sample;
            break;
        }
    }
//    NSString* dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter ]
    
    NSMutableDictionary* jsonData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                     anImage, @"imageData" // will be stored as an attachment to the document in CouchDB
                                     metaData, @"mediaMetaData"
                                     , motionData, @"motionData"
                                     , locationData, @"locationData"
                                     , headingData, @"headingData"
//                                     , [NSDate date], @"timestamp"
                                     , nil];
    [_images addObject:jsonData];
    [self.tableView reloadData];

    [dateFormatter release];
    // store image in CouchDB
    //    Test the various JSON transforms
    NSError* error = NULL;
    NSData* theJSON = [[CJSONSerializer serializer] serializeDictionary:jsonData error:&error];
    if (error != NULL) {
        NSLog(@"Error while serializing %@", jsonData);
    }
    else {
        NSString *jsonString = [[NSString alloc] initWithData:theJSON encoding:NSUTF8StringEncoding];
        NSLog(@"Saving JSON %@", jsonString);
        
//                requestWithURL
        
        
//        
//        CouchDBSuccessHandler inSuccessHandler = ^(id inParameter) {
//            NSLog(@"Wooohooo! %@", inParameter);
////            [delegate performSelector:@selector(newItemAdded)];
//        };
//        
//        CouchDBFailureHandler inFailureHandler = ^(NSError *error) {
//            NSLog(@"D'OH! %@", error);
//        };
//        CFUUIDRef uuid = CFUUIDCreate(nil);
//        NSString *guid = (NSString*)CFUUIDCreateString(nil, uuid);
//        CFRelease(uuid);
//        NSString *docId = [NSString stringWithFormat:@"%f-%@", CFAbsoluteTimeGetCurrent(), guid];
//
//        DatabaseManager *sharedManager = [DatabaseManager sharedManager:[delegate getCouchbaseURL]];
//        CURLOperation *op = [sharedManager.database operationToCreateDocument:inDocument 
//                                                                   identifier:docId
//                                                               successHandler:inSuccessHandler 
//                                                               failureHandler:inFailureHandler];
//        [op start];
//    }
    }
}

- (void)startMotionSampling
{
    if (nil == _motionSamples) {
        _motionSamples = [[NSMutableArray alloc] init];
    }
    else {
        [_motionSamples removeAllObjects];
    }
    if (nil == _locationSamples) {
        _locationSamples = [[NSMutableArray alloc] init];
    }
    else {
        [_locationSamples removeAllObjects];
    }
    if (nil == _headingSamples) {
        _headingSamples = [[NSMutableArray alloc] init];
    }
    else {
        [_headingSamples removeAllObjects];
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

    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager startUpdatingLocation];
    }
    if ([CLLocationManager headingAvailable]) {
        [_locationManager startUpdatingHeading];
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
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)takeMotionSample:(NSTimer*)aTimer
{
    NSMutableDictionary* sample = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     [NSDate date], @"timestamp"
     , [NSNumber numberWithDouble:_motionManager.gyroData.rotationRate.x], @"gyro-x"
     , [NSNumber numberWithDouble:_motionManager.gyroData.rotationRate.y], @"gyro-y"
     , [NSNumber numberWithDouble:_motionManager.gyroData.rotationRate.z], @"gyro-z"
     , [NSNumber numberWithDouble:_motionManager.deviceMotion.attitude.roll], @"attitude-roll"
     , [NSNumber numberWithDouble:_motionManager.deviceMotion.attitude.pitch], @"attitude-pitch"
     , [NSNumber numberWithDouble:_motionManager.deviceMotion.attitude.yaw], @"attitude-yaw"
     , [NSNumber numberWithDouble:_motionManager.accelerometerData.acceleration.x], @"accel-x"
     , [NSNumber numberWithDouble:_motionManager.accelerometerData.acceleration.y], @"accel-y"
     , [NSNumber numberWithDouble:_motionManager.accelerometerData.acceleration.z], @"accel-z"
     , nil];
    [_motionSamples addObject:sample];
}

@end
