//
//  CountingViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>
#import "CountingViewController.h"
#import "CountingEngine.h"
#import "Config.h"
#import "MoreViewController.h"
#import "ExerciseViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"

BOOL isActive = NO;
UIAlertView *alert = nil;
extern int choseInterval;
extern NSDate *startDate;
extern NSDate *endDate;
extern NSMutableArray *globalNotif0;


@implementation CountingViewController

static id __strong instance = nil;
static NSDate *recorDate = nil;

+ (CountingViewController*)getInstance
{
    if (instance == nil) {
        instance = [[CountingEngine alloc] init];
    }
    return instance;
}


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
    //[self.navigationController popViewControllerAnimated:YES];
    [ledIndicatorTimer invalidate];
    ledIndicatorTimer = nil;
    CountingEngine* engine = [CountingEngine getInstance];
    NSString *remainString = [engine getRemainingTimeString];
    //[engine pauseCounting];
    int remain = [[[remainString componentsSeparatedByString:@":"] objectAtIndex:0] intValue] *60 + [[[remainString componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    if (remain >= 1) {
        isActive = YES;
    }
    else{
        isActive = NO;
    }
    //[self performSegueWithIdentifier:@"StopCounting" sender:self];
    
    [self performSegueWithIdentifier:@"next2Home" sender:self];
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
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navigationItem.title];
    titleLabel.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1.0);
    [self.view addSubview:titleLabel];
    
    //alert = [[UIAlertView alloc] initWithTitle:@"StandApp!" message:@"Time for a standing break..." delegate:self cancelButtonTitle:@"" otherButtonTitles:@"I'm Standing!", @"Busy, Can't stand right now!", @"Leave me alone for 1 hour.", nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [backButton setFrame:CGRectMake(20, 18, 119, 72)];
        [titleLabel setFrame:CGRectMake(0, 0, 768, 107)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:72]];
    } else {
        [backButton setFrame:CGRectMake(5, 12, 26, 20)];
        [titleLabel setFrame:CGRectMake(0, 0, 320, 45)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:30]];
    }
     
    [self.ledIndicator setFont:[UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 96.0 : 60.0]];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0 : 15.0]];
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,self.view.frame.size.height - adSize.height, adSize.width,adSize.height)];
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

- (void)viewDidUnload
{
    [self setStopButton:nil];
    [self setDescriptionLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    CountingEngine* engine = [CountingEngine getInstance];
    if (self.resumeFlag && [self.resumeFlag boolValue]) {
        [engine resumeCounting];
        self.resumeFlag = nil;
    }
    [self.ledIndicator setText:[engine getRemainingTimeString]];
    ledIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(updateLedIndicator) userInfo:nil repeats:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    CountingEngine* engine = [CountingEngine getInstance];
    if ([engine isReachedTarget]) {
        [self performSegueWithIdentifier:@"StopCounting" sender:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (ledIndicatorTimer != nil) {
        // stop timer
        [ledIndicatorTimer invalidate];
        ledIndicatorTimer = nil;
    }
}

- (void)viewControllerWillEnterForeground
{
    CountingEngine* engine = [CountingEngine getInstance];
    [self.ledIndicator setText:[engine getRemainingTimeString]];
    [self.countingClock setProgressValue:[engine getPassRate]];
    [self.countingClock setNeedsDisplay];
}

- (BOOL)shouldAutorotate
{
    return NO;}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pauseResumeButtonClicked:(id)sender
{
    CountingEngine* engine = [CountingEngine getInstance];
    if ([engine isPaused]) {
        [engine resumeCounting];
        UIImage *btnImage = [UIImage imageNamed:@"pause.png"];
        [self.pauseResumeButton setImage:btnImage forState:UIControlStateNormal];
    } else {
        [engine pauseCounting];
        UIImage *btnImage = [UIImage imageNamed:@"start.png"];
        [self.pauseResumeButton setImage:btnImage forState:UIControlStateNormal];
    }
}

- (IBAction) stopButtonClicked:(id)sender
{
    [ledIndicatorTimer invalidate];
    ledIndicatorTimer = nil;
    [[CountingEngine getInstance] stopCounting];
    isActive = FALSE;
    [self performSegueWithIdentifier:@"StopCounting" sender:self];
}

- (void)setSchedule{
    CountingEngine *engine = [CountingEngine getInstance];
    [engine unscheduleAllAlarm];
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    for (UILocalNotification *notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType == 0) {
            [app cancelLocalNotification:notification];
        }
    }
    if ([globalNotif0 count] > 0) {
        [globalNotif0 removeAllObjects];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:choseInterval forKey:@"choseInterval"];
    NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *start = [dateFormatter stringFromDate:startDate];
    NSString *end = [dateFormatter stringFromDate:endDate];
    [saves setObject:start forKey:@"startDate"];
    [saves setObject:end forKey:@"endDate"];
    [saves synchronize];
    
    int minutes = [endDate timeIntervalSinceDate:startDate]/60;
    int segments = minutes/choseInterval;
    for (int i = 1; i < segments; i++) {
        UILocalNotification *alarm = [[UILocalNotification alloc] init];
        if ( alarm ) {
            alarm.timeZone = [NSTimeZone defaultTimeZone];
            alarm.soundName = UILocalNotificationDefaultSoundName;
            alarm.fireDate = [NSDate dateWithTimeInterval:i*choseInterval*60 sinceDate:startDate];
            alarm.alertBody = @"Time for a standing break!";
            alarm.repeatInterval = NSDayCalendarUnit;
            alarm.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:kNotificationTypeKey];
            [app scheduleLocalNotification:alarm];
        }
    }
    
//    isScheduledInterval = YES;
//    BOOL flag = [CountingEngine date:today isBetweenDate:startDate andDate:endDate];
//    if (flag == YES) {
//        tempDate = [[NSDate alloc] initWithTimeInterval:11 sinceDate:today];
//    }
//    else if([today compare:endDate] == NSOrderedDescending){
//        isScheduledInterval = NO;
//        tempDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:endDate];
//    }
//    else{
//        tempDate = [[NSDate alloc] initWithTimeInterval:11 sinceDate:startDate];
//    }
//    [saves setBool:isScheduledInterval forKey:@"isScheduledInterval"];
//    [saves synchronize];
//    NSDateFormatter *allDateFormatter = [[NSDateFormatter alloc] init];
//    [allDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
//    nextIntervalStr = [allDateFormatter stringFromDate:tempDate];
    
    //NSLog(@"\n ------ c v ------ %@ -------\n", nextIntervalStr);
/*
#if !USE_TEST_TIME
    [engine startCountingWithInterval:interval * 60 scheduleType:0 resetInterval:YES];
#else
    [engine startCountingWithInterval:interval / 3 scheduleType:0 resetInterval:YES];
#endif
 */
}

- (void)updateLedIndicator
{
    CountingEngine* engine = [CountingEngine getInstance];    
    // check if is reached the target
    if ([engine isReachedTarget]) {
        // stop timer
        isActive = FALSE;
        [ledIndicatorTimer invalidate];
        ledIndicatorTimer = nil;
        [engine stopCounting];
        [self setSchedule];
        [self performSegueWithIdentifier:@"StopCounting" sender:self];

    } else {
        // update watch
        //isActive = TRUE;
        [self.ledIndicator setText:[engine getRemainingTimeString]];
        [self.countingClock setProgressValue:[engine getPassRate]];
        [self.countingClock setNeedsDisplay];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"startingExercise"]) {
        ExerciseViewController * exerciseViewController = segue.destinationViewController;
        [exerciseViewController setScheduledExercise:NO];
//        [self.navigationController popViewControllerAnimated:YES];
    } else if ([[segue identifier] isEqualToString:@"showMore"]) {
        CountingEngine* engine = [CountingEngine getInstance];
        if (![engine isPaused]) {
            [engine pauseCounting];
            self.resumeFlag = [NSNumber numberWithBool:YES];
        } else {
            self.resumeFlag = [NSNumber numberWithBool:NO];
        }
    }
}

@end
