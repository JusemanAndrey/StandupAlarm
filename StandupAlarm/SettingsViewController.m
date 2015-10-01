//
//  SettingsViewController.m
//  StandupAlarm
//
//  Created by maxim on 3/22/15.
//
//
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "Config.h"
#import "CountingEngine.h"
//#import "CoreLocationViewController.h"
#import "GADBannerView.h"
#import "NotificationSettingViewController.h"
#import "MBProgressHUD.h"

extern BOOL isSetLocation;
extern BOOL isSetSound;
extern NSString *breakDuration;
extern NSString *locationInfo;
extern CLLocation *fixedLocation;
extern CLLocation *currentLocation;
extern BOOL isSetHealth;
NSString *placeName = @"";

@interface SettingsViewController () <MBProgressHUDDelegate>{
    NSArray *_pickerData;
    MBProgressHUD *HUD;
}

@end

@implementation SettingsViewController

@synthesize soundSwitch;
@synthesize logDataSwitch;
@synthesize locationSwitch;
@synthesize userPlaceLabel;

- (void)popViewController:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [_picker setHidden:YES];
    _picker.hidden = TRUE;
    _doneButton.hidden = TRUE;
    _breakDurationLabel.text = breakDuration;
    userPlaceLabel.text = placeName;
    [locationSwitch setOn:isSetLocation];
    [soundSwitch setOn:isSetSound];
    if ( isSetLocation && fixedLocation != nil) {
        [self getAddressFromLocation:fixedLocation];
    }
    [logDataSwitch setOn:isSetHealth];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray* durations = [[NSMutableArray alloc] init];
    for (int i = 1; i < 16; i++) {
        [durations addObject:[NSString stringWithFormat:@"%d", i]];
    }
    _pickerData = @[@"1", @"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15"];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"commonbg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navigationItem.title];
    titleLabel.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1.0);
    [self.view addSubview:titleLabel];
   
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [backButton setFrame:CGRectMake(20, 18, 119, 72)];
        [titleLabel setFrame:CGRectMake(0, 0, 768, 107)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:72]];
    } else {
        [backButton setFrame:CGRectMake(5, 12, 26, 20)];
        [titleLabel setFrame:CGRectMake(0, 0, 320, 45)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:30]];
    }
    
#if USE_ADMOB
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,self.view.frame.size.height - adSize.height,adSize.width,adSize.height)];
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)saveButtonClicked:(id)sender {
    NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
    breakDuration = _breakDurationLabel.text;
    isSetSound = self.soundSwitch.on;
    isSetLocation = self.locationSwitch.on;
    if (!isSetLocation) {
        locationInfo = nil;
        fixedLocation = nil;
    }
    else{
        locationInfo = [NSString stringWithFormat:@"%.3fx%.3f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        fixedLocation = currentLocation;
    }
    isSetHealth = logDataSwitch.on;
    
    if (locationInfo != nil) {
        [saves setObject:locationInfo forKey:@"locationInfo"];
    }
    [saves setBool:isSetSound forKey:@"isSetSound"];
    [saves setBool:isSetLocation forKey:@"isSetLocation"];
    [saves setObject:breakDuration forKey:@"breakDuration"];
    [saves setBool:isSetHealth forKey:@"isSetHealth"];
    
    [saves synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) getAddressFromLocation:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    NSString *prefix = @" ";
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if(placemarks && placemarks.count > 0)
        {
            for (CLPlacemark *placemark in placemarks) {
                if ([placemark.addressDictionary valueForKey:@"FormattedAddressLines"]) {
                    userPlaceLabel.text = [prefix stringByAppendingString:[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
                    break;
                }
                else {
                    if ([placemark subLocality] ) {
                        userPlaceLabel.text = [NSString stringWithFormat:@" %@, %@", [placemark subLocality],[placemark locality]];
                        break;
                    }
                    else{
                        userPlaceLabel.text = [NSString stringWithFormat:@" %@",[placemark locality]];
                        continue;
                    }
                }
            }
        }
    }];
}

- (void)findLocation {
    sleep(10);
    [self getAddressFromLocation:fixedLocation];
    [self hudWasHidden:HUD];
}

- (IBAction)locationSwitchChange:(id)sender {
    if ( locationSwitch.on ) {
        if(currentLocation == nil){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Information" message:@"Please try after 10 seconds." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [locationSwitch setOn:NO];
            placeName = @" ";
            userPlaceLabel.text = @" ";
            return;
        }
        fixedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude) altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
        //NSLog(@"---------%f ---------%f ----\n", fixedLocation.coordinate.latitude, fixedLocation.coordinate.longitude);
        HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        HUD.color = [UIColor colorWithRed:58.0/255.0 green:134.0/255.0 blue:1.0 alpha:0.80];
        [self.view.window addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Fixing Location...";
        
        [HUD showWhileExecuting:@selector(findLocation) onTarget:self withObject:nil animated:YES];
        
        placeName = userPlaceLabel.text;
//        locationInfo = [NSString stringWithFormat:@"%.3fx%.3f", fixedLocation.coordinate.latitude, fixedLocation.coordinate.longitude];
//        NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
//        [saves setObject:locationInfo forKey:@"locationInfo"];
//        [saves synchronize];
    }
    else {
        placeName = @" ";
        userPlaceLabel.text = @" ";
//        locationInfo = @"500x500";
//        fixedLocation = nil;
//        NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
//        [saves setObject:nil forKey:@"locationInfo"];
//        [saves synchronize];
    }
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _breakDurationLabel.text = [_pickerData objectAtIndex:row];
}

- (IBAction)breakClicked:(id)sender {
    [_picker setHidden:NO];
    _picker.hidden = FALSE;
    _doneButton.hidden = FALSE;
    [_picker selectRow:[_breakDurationLabel.text integerValue]-1 inComponent:0 animated:YES];
}

- (IBAction)doneClicked:(id)sender {
    [_picker setHidden:YES];
    _picker.hidden = TRUE;
    _doneButton.hidden = TRUE;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

@end
