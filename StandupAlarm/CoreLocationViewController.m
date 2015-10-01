//
//  CoreLocationViewController.m
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import "CoreLocationViewController.h"
#import "MapAnnotation.h"
#import "SettingsViewController.h"

extern NSString *locationInfo;
extern NSString *placeName;
#define METERS_PER_MILE 1609.344

@interface CoreLocationViewController ()

@end
NSString *latitude;
NSString *longitude;
CLLocationCoordinate2D setMyCoordinate;

@implementation CoreLocationViewController

@synthesize mapView;

CLLocationCoordinate2D currUserCoordinate;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!placeName) {
        placeName = [[NSString alloc] init];
    }
   
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    [self.mapView addGestureRecognizer:tapRecognizer];
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview:mapView];
    //mapView.hidden = YES;
}

- (IBAction) foundTap:(UITapGestureRecognizer *)recognizer
{
    if ([[mapView annotations] objectAtIndex:0]) {
        [mapView removeAnnotations:[mapView annotations]];
    }
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    setMyCoordinate.latitude = tapPoint.latitude;
    setMyCoordinate.longitude = tapPoint.longitude;
    MapAnnotation *newAnnotation = [[MapAnnotation alloc] initWithTitle:@"My Location to Set" andCoordinate:setMyCoordinate];
    [self.mapView addAnnotation:newAnnotation];
    [self getAddressFromLocation:[[CLLocation alloc] initWithCoordinate:setMyCoordinate altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil]];
}

- (void) getAddressFromLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if(placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark= [placemarks objectAtIndex:0];
            NSString *address = [NSString stringWithFormat:@"%@ %@,%@ %@", [placemark subThoroughfare],[placemark thoroughfare],[placemark locality], [placemark administrativeArea]];
            NSLog(@"%@u",address);
            placeName = address;
        }
    }];
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    if([views count] > 0){
        MKAnnotationView *annotationView = [views objectAtIndex:0];
        id <MKAnnotation> mp = [annotationView annotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance ([mp coordinate], METERS_PER_MILE*3, METERS_PER_MILE*3);
        [mv setRegion:region animated:YES];
        [mv selectAnnotation:mp animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Dispose of any resources that can be recreated.
}

- (IBAction)cancelClicked:(id)sender {
    setMyCoordinate.latitude = 500;//out of range
    setMyCoordinate.longitude = 500;//out of range
    placeName = @"";
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveClicked:(id)sender {
    if ([[mapView annotations] count] < 2 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert Location Setting" message:@"Please Set Location to Notify!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    locationInfo = [NSString stringWithFormat:@"%.3fx%.3f", setMyCoordinate.latitude, setMyCoordinate.longitude];
    [self dismissViewControllerAnimated:true completion:nil];
}
//- (void)requestAlwaysAuthorization
//{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//
//    // If the status is denied or only granted for when in use, display an alert
//    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
//        NSString *title;
//        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
//        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
//        [alertView show];
//    }
//    // The user has not enabled any location services. Request background authorization.
//    else if (status == kCLAuthorizationStatusNotDetermined) {
//        [locationManager requestAlwaysAuthorization];
//    }
//}
@end
