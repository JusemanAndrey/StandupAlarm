//
//  AlarmDetailViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 4/29/13.
//
//

#import "AlarmDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Config.h"
#import "AlarmCell.h"
#import "CountingEngine.h"
#import "AlarmDetailRepeatViewController.h"
#import "AlarmDetailExerciseViewController.h"

extern NSString *locationInfo;
extern NSDate *startDate;
extern NSDate *endDate;
extern BOOL isSetSound;

@interface AlarmDetailViewController ()

@end

@implementation AlarmDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)popViewController:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)awakeFromNib
{
    self.alarmGuid = nil;
    self.alarmRepeat = 0;
    self.alarmExercise = 0;
    self.alarmTime = [NSDate date];
}

-(void) viewWillAppear:(BOOL)animated{
    [self.alarmDetailTableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    //[titleLabel setFont:[UIFont systemFontOfSize:18]];
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
    
    [self.alarmTimePicker setDate:self.alarmTime];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveAlarm:(id)sender {
    //BOOL flag = TRUE;
    UIApplication* app = [UIApplication sharedApplication];

    if (self.alarmGuid != nil) {
        NSArray* oldNotifications = [app scheduledLocalNotifications];        
        for (UILocalNotification* notification in oldNotifications) {
            int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
            if (notificationType == 10) {
                NSString* guid = [notification.userInfo objectForKey:kNotificationGuidKey];
                if ([self.alarmGuid isEqualToString:guid]) {
                    [app cancelLocalNotification:notification];
                }
            }
        }
    } else {
        [self setAlarmGuid:[NSString stringWithFormat:@"%f", GETCURRENTTIME]];
    }
    
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (isSetSound) {
        alarm.soundName = UILocalNotificationDefaultSoundName;
    }
    alarm.timeZone = [NSTimeZone defaultTimeZone];
    alarm.alertBody = @"Scheduled time for a standing break!";
    NSDate* today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* todayComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:today];

    NSDateComponents* fireDateComponents = [calendar components:(NSMinuteCalendarUnit | NSHourCalendarUnit) fromDate:[self.alarmTimePicker date]];
    fireDateComponents.day      = todayComponents.day;
    fireDateComponents.month    = todayComponents.month;
    fireDateComponents.year     = todayComponents.year;
    
    NSDate* fireDate = [calendar dateFromComponents:fireDateComponents];
    
    if (self.alarmRepeat == 0) {
        if ([fireDate compare:today] == NSOrderedAscending)
            alarm.fireDate = [fireDate dateByAddingTimeInterval:3600 * 24];
        else
            alarm.fireDate = fireDate;
        alarm.repeatInterval = 0;
        alarm.userInfo = @{ kNotificationTypeKey: [NSNumber numberWithInt:10],
                            kNotificationGuidKey: self.alarmGuid,
                            kNotificationWeekdaysKey: [NSNumber numberWithInt:self.alarmRepeat],
                            kNotificationExerciseKey: [NSNumber numberWithInt:self.alarmExercise] };
        [app scheduleLocalNotification:alarm];
    } else if (self.alarmRepeat == ((1 << 7) - 1)) {
        
        if ([fireDate compare:today] == NSOrderedAscending)
            alarm.fireDate = [fireDate dateByAddingTimeInterval:3600 * 24];
        else
            alarm.fireDate = fireDate;
        alarm.repeatInterval = NSDayCalendarUnit;
        alarm.userInfo = @{ kNotificationTypeKey: [NSNumber numberWithInt:10],
                            kNotificationGuidKey: self.alarmGuid,
                            kNotificationWeekdaysKey: [NSNumber numberWithInt:self.alarmRepeat],
                            kNotificationExerciseKey: [NSNumber numberWithInt:self.alarmExercise] };
        [app scheduleLocalNotification:alarm];
    } else if (log2(self.alarmRepeat) == (int)log2(self.alarmRepeat)) {

        int repeatWeekday = ((int)log2(self.alarmRepeat) + 1) % 7 + 1;
        int todayWeekday = todayComponents.weekday;
        fireDate = [fireDate dateByAddingTimeInterval:3600 * 24 * ((repeatWeekday - todayWeekday + 7) % 7)];
        
        if ([fireDate compare:today] == NSOrderedAscending)
            alarm.fireDate = [fireDate dateByAddingTimeInterval:3600 * 24 * 7];
        else
            alarm.fireDate = fireDate;
        alarm.repeatInterval = NSWeekCalendarUnit;
        alarm.userInfo = @{ kNotificationTypeKey: [NSNumber numberWithInt:10],
                            kNotificationGuidKey: self.alarmGuid,
                            kNotificationWeekdaysKey: [NSNumber numberWithInt:self.alarmRepeat],
                            kNotificationExerciseKey: [NSNumber numberWithInt:self.alarmExercise] };
        [app scheduleLocalNotification:alarm];
    } else {
        int todayWeekday = todayComponents.weekday;
        for (int i = 0; i < 7; i++) {
            if ((self.alarmRepeat & (1 << i)) > 0) {
                int repeatWeekday = (i + 1) % 7 + 1;
                alarm.fireDate = [fireDate dateByAddingTimeInterval:3600 * 24 * ((repeatWeekday - todayWeekday + 7) % 7)];
                if ([alarm.fireDate compare:today] == NSOrderedAscending)
                    alarm.fireDate = [alarm.fireDate dateByAddingTimeInterval:3600 * 24 * 7];
                alarm.repeatInterval = NSWeekCalendarUnit;
                alarm.userInfo = @{ kNotificationTypeKey: [NSNumber numberWithInt:10],
                                    kNotificationGuidKey: self.alarmGuid,
                                    kNotificationWeekdaysKey: [NSNumber numberWithInt:self.alarmRepeat],
                                    kNotificationExerciseKey: [NSNumber numberWithInt:self.alarmExercise] };
                [app scheduleLocalNotification:alarm];
            }
        }
    }
   
    [self popViewController:sender];
}

- (void)viewDidUnload {
    [self setAlarmTimePicker:nil];
    [self setAlarmDetailTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"Repeat"];
        [cell.detailTextLabel setText:[AlarmCell formatAlarmRepeat:self.alarmRepeat]];
    } else {
        [cell.textLabel setText:@"Exercise"];
        [cell.detailTextLabel setText:[AlarmCell formatAlarmExercise:self.alarmExercise]];
    }

    cell.textLabel.font             = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 53.0 : 22.0];
    cell.textLabel.textColor        = [UIColor colorWithRed:33.0 / 255 green:99.0 / 255 blue:198.0 / 255 alpha:1];
    cell.detailTextLabel.font       = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 43.0 : 18.0];
    cell.detailTextLabel.textColor  = [UIColor colorWithRed:123.0 / 255 green:123.0 / 255 blue:123.0 / 255 alpha:1];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
#ifdef FREEVERSION
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
    if (isPhone568)
        storyboardName = [storyboardName stringByAppendingString:@"_568h"];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];

    if (indexPath.row == 0) {

        AlarmDetailRepeatViewController* nextViewController = (AlarmDetailRepeatViewController*)[storyboard instantiateViewControllerWithIdentifier:@"alarmDetailRepeatViewController"];
        [nextViewController setAlarmDetailViewController:self];
        [self.navigationController pushViewController:nextViewController animated:YES];

    } else {
        
        AlarmDetailExerciseViewController* nextViewController = (AlarmDetailExerciseViewController*)[storyboard instantiateViewControllerWithIdentifier:@"alarmDetailExerciseViewController"];
        [nextViewController setAlarmDetailViewController:self];
        [self.navigationController pushViewController:nextViewController animated:YES];

    }
}

@end
