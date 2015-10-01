//
//  CoreLocationViewController.h
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CoreLocationViewController : UIViewController <MKMapViewDelegate> {
    MKMapView *mapView;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;

@end
