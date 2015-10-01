//
//  SettingsViewController.h
//  StandupAlarm
//
//  Created by maxim on 3/22/15.
//
//
//#import "CoreLocationViewController.h"
#import "GADBannerView.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SettingsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {//global
    GADBannerView *bannerView_;
}

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logDataSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (strong, nonatomic) IBOutlet UILabel *userPlaceLabel;

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *breakDurationLabel;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)locationSwitchChange:(id)sender;
- (IBAction)breakClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;

@end
