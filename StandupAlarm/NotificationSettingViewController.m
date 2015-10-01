//
//  NotificationSettingViewController.m
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import "NotificationSettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CountingEngine.h"

extern NSDate *startDate, *endDate;

@interface NotificationSettingViewController ()

@end

@implementation NotificationSettingViewController

@synthesize startTime;
@synthesize endTime;
@synthesize dateTimePicker;
@synthesize whetherSwitch;

NSDate* checkStartDate;
NSDate* checkEndDate;

- (void)viewWillAppear:(BOOL)animated
{
//    if ([endDate timeIntervalSinceDate:startDate] > 0 ) {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"hh:mm a"];
//        startTime.text = [dateFormatter stringFromDate:startDate];
//        endTime.text = [dateFormatter stringFromDate:endDate];
//        checkStartDate = startDate;
//        checkEndDate = endDate;
//    }
    checkEndDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:endDate];
    checkStartDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:startDate];
    
    [dateTimePicker setDate:startDate];
    [dateTimePicker setDatePickerMode:UIDatePickerModeTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    startTime.text = [dateFormatter stringFromDate:startDate];
    endTime.text = [dateFormatter stringFromDate:endDate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //checkStartDate = [NSDate date];
    //checkEndDate = [NSDate date];
    [whetherSwitch setOn:FALSE];
    [whetherSwitch setThumbTintColor:[UIColor colorWithRed:58.0/255.0 green:134.0/255.0 blue:1.0 alpha:1.0]];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"commonbg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,
                                                                  self.view.frame.size.height - adSize.height,
                                                                  adSize.width,
                                                                  adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelClicked:(id)sender {
//    startDate = nil;
//    endDate = nil;
    //startDate = [NSDate date];
    //endDate = startDate;
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveClicked:(id)sender {
    if ([startTime.text isEqualToString:@""] || [endTime.text isEqualToString:@""] || [checkStartDate compare:checkEndDate] == NSOrderedDescending || [endTime.text isEqualToString:startTime.text] ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Interval Settings" message:@"Please Set Correct Start/End Times!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        endTime.text = @"";
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *startDay = [dateFormatter stringFromDate:[NSDate date]];
    NSString *endDay = [dateFormatter stringFromDate:[NSDate date]];
    NSString *start = @" ";
    NSString *end = @" ";
    start = [start stringByAppendingString:startTime.text];
    end = [end stringByAppendingString:endTime.text];
    NSString *startOfToday = [startDay stringByAppendingString:start];
    NSString *endOfToday = [endDay stringByAppendingString:end];
    NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
    [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    startDate = [timeAndFormatter dateFromString:startOfToday];
    endDate = [timeAndFormatter dateFromString:endOfToday];
    
    [[NSUserDefaults standardUserDefaults] setObject:startTime.text forKey:@"startDate"];
    [[NSUserDefaults standardUserDefaults] setObject:endTime.text forKey:@"endDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)valueChanged:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    BOOL sw = [whetherSwitch isOn];
    if (sw) {//end time
        endTime.text = [dateFormatter stringFromDate:dateTimePicker.date];
        checkEndDate = dateTimePicker.date;
    }
    else {//start time
        startTime.text = [dateFormatter stringFromDate:dateTimePicker.date];
        checkStartDate = dateTimePicker.date;
    }
}

- (IBAction)switchChanged:(id)sender {
    BOOL sw = [whetherSwitch isOn];
    if (sw) {//end time
        [whetherSwitch setThumbTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    else {//start time
        [whetherSwitch setThumbTintColor:[UIColor colorWithRed:58.0/255.0 green:134.0/255.0 blue:1.0 alpha:1.0]];
    }
}

@end
