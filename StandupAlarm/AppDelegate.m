//
//  AppDelegate.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "CountingEngine.h"
#import "ExerciseViewController.h"
#import "IntroViewController.h"
#import "CountingViewController.h"
#import "Appirater.h"
#import "HomeViewController.h"
#import "MainMenuViewController.h"

#define METERS_PER_MILE 1609.344
#define TIMERINTERVAL 10.0

NSString *const SCSessionStateChangedNotification = @"standapp:SCSessionStateChangedNotification";
BOOL isSetLocation, isSetSound, isSetHealth, bTracker;
NSString *locationInfo;
NSDate *startDate, *endDate, *oneHourDate;
NSString *breakDuration;
UILocalNotification *alertNotification;
BOOL isTimeToCheck, checkEnableApp, isSetOneHour;
double userWeight;
NSMutableArray *globalNotif10, *globalNotif0;
CLLocation *currentLocation, *fixedLocation;

@implementation AppDelegate

BOOL isRecordable, isInitWeight, isRepeat;
CLLocationManager *locationManager;
int records;
UIAlertView *alert1;
NSDate *expireDate, *didEnterBackdate;

@synthesize window = _window;
@synthesize locationUpdateTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self checkDevice];
    //[[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"System" size:18.0]}];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL appirate = [userDefault boolForKey:@"isRegisteredAppirater"];
    if (appirate == NO) {
        [Appirater setAppId:@""];
        [Appirater setDaysUntilPrompt:1];
        [Appirater setUsesUntilPrompt:3];
        [Appirater setTimeBeforeReminding:2];
        [Appirater setDebug:NO];
        [Appirater setCustomAlertTitle:@"Please write a review"];
        [Appirater setCustomAlertMessage:@"Help us out and leave us a nice review"];
        [Appirater setCustomAlertCancelButtonTitle:@"No, Thanks"];
        [Appirater setCustomAlertRateButtonTitle:@"Write Review"];
        [Appirater setCustomAlertRateLaterButtonTitle:@"Remind Me later"];
        [userDefault setBool:YES forKey:@"isRegisteredAppirater"];
    }
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
       
        //NSLog(@"\n\n current notifications : %@ \n\n", [[UIApplication sharedApplication] currentUserNotificationSettings]);
    }

    globalNotif10 = [NSMutableArray new];
    globalNotif0 = [NSMutableArray new];

    CountingEngine* engine = [CountingEngine getInstance];
    
#if USE_SPLASH
#if !USE_TEST_SPLASH
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"firstlunch.inf"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [engine setFirstLunch: YES];
        NSArray* intervalArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:DEFAULT_INTERVAL], nil];
        [intervalArray writeToFile:plistPath atomically:YES];
    } else {
        [engine setFirstLunch: NO];
    }
#else
    [engine setFirstLunch:YES];
#endif
#else
    [engine setFirstLunch:NO];
#endif
    
    if (![engine firstLunch]) {
        UINavigationController *navc = (UINavigationController *)self.window.rootViewController;
        UIViewController *topvc = [navc topViewController];
        
        if ([topvc respondsToSelector:@selector(showMainMenuWithDelay)]) {
            [topvc performSelector:@selector(showMainMenuWithDelay)];
        }
    }
    // Maxim
    
    if ( [userDefault stringForKey:@"locationInfo"] != nil ) {
        locationInfo = [userDefault stringForKey:@"locationInfo"];
        NSString *lati = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:0];
        NSString *longi = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:1];
        fixedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([lati floatValue], [longi floatValue]) altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    }
    else{
        locationInfo = nil;
        fixedLocation = nil;
    }
    isSetLocation = [userDefault boolForKey:@"isSetLocation"];
    isSetSound = [userDefault boolForKey:@"isSetSound"];
    isSetHealth = [userDefault boolForKey:@"isSetHealth"];
    bTracker = [userDefault boolForKey:@"bTracker"];
    //isRecordable = [userDefault boolForKey:@"isRecordable"];
    
    if ([userDefault stringForKey:@"breakDuration"] != nil ) {
        breakDuration = [userDefault stringForKey:@"breakDuration"];
    }
    else{
        breakDuration = @"5";
    }
    //isSetOneHour = NO;
    records = 0;
    
    isInitWeight = NO;
    userWeight = 0;
    isRepeat = NO;
    if ( [userDefault doubleForKey:@"userWeight"] != 0) {
        userWeight = [userDefault doubleForKey:@"userWeight"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
    [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    startDate = [[NSDate alloc] init];
    endDate = [[NSDate alloc] init];
    if ([userDefault stringForKey:@"startDate"] != nil ) {
        NSString *start = @" ";
        NSString *end = @" ";
        start = [start stringByAppendingString:[userDefault stringForKey:@"startDate"]];
        end = [end stringByAppendingString:[userDefault stringForKey:@"endDate"]];
        NSString *startOfToday = [today stringByAppendingString:start];
        NSString *endOfToday = [today stringByAppendingString:end];
        startDate = [timeAndFormatter dateFromString:startOfToday];
        endDate = [timeAndFormatter dateFromString:endOfToday];
    }
    else{
        NSString *startOfToday = [today stringByAppendingString:@" 9:00 AM"];
        NSString *endOfToday = [today stringByAppendingString:@" 5:30 PM"];
        //NSString *startOfToday = [today stringByAppendingString:@" 12:00 AM"];
        //NSString *endOfToday = [today stringByAppendingString:@" 11:59 PM"];
        startDate = [timeAndFormatter dateFromString:startOfToday];
        endDate = [timeAndFormatter dateFromString:endOfToday];
    }
    
    isTimeToCheck = NO;
    checkEnableApp = [userDefault boolForKey:@"enableApp"];
    if (!checkEnableApp) {
        NSString *recExpireDate = [userDefault stringForKey:@"expireDate"];
        if (recExpireDate == nil) {
            expireDate = [NSDate date];
            [userDefault setObject:[timeAndFormatter stringFromDate:expireDate] forKey:@"expireDate"];
            [userDefault synchronize];
        }
        else{
            expireDate = [[NSDate alloc] init];
            expireDate = [timeAndFormatter dateFromString:recExpireDate];
        }
    }
    
    currentLocation = [[CLLocation alloc] init];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    //Authorize location service
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ) {
        [locationManager requestAlwaysAuthorization];
    }
   
    [locationManager startUpdatingLocation];
    
    if ([locationUpdateTimer isValid]) {
        [locationUpdateTimer invalidate];
        locationUpdateTimer = nil;
    }
    locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL target:self selector:@selector(cycleFunc) userInfo:nil repeats:YES];
    
    if ([HKHealthStore isHealthDataAvailable]) {
        healthStore = [[HKHealthStore alloc] init];
        activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        //NSSet *writeDataTypes = [NSSet setWithObjects:activeEnergyBurnType, weightType, nil];
        NSSet *writeDataTypes = [NSSet setWithObject:activeEnergyBurnType];
        //NSSet *readDataTypes = [NSSet setWithObject:weightType];
        
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:nil completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                isRecordable = NO;
            }
            else
                isRecordable = YES;
        }];
    }
//    if (isRecordable) {
//        [self fetchWeight];
//    }
   
    self.localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];

    alert1 = [[UIAlertView alloc] initWithTitle:@"StandApp!" message:@"Time for a standing break..." delegate:self cancelButtonTitle:@"" otherButtonTitles:@"I'm Standing!", @"Busy, Can't stand right now!", @"Leave me alone for 1 hour.", nil];

    [Appirater appLaunched:YES];
    return YES;
}

- (void) fetchWeight{
    NSDate *startWeightDate, *endWeightDate;
    startWeightDate = [[NSDate alloc] init];
    endWeightDate = [NSDate date];
    startWeightDate = [endWeightDate dateByAddingTimeInterval:-24*60*60];
    //HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Create a predicate to set start/end date bounds of the query
    //NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    // Create a sort descriptor for sorting by start date
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:YES];
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:weightType
                                                                 predicate:nil
                                                                     limit:HKObjectQueryNoLimit
                                                           sortDescriptors:@[sortDescriptor]
                                                            resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                                if(!error && results)
                                                                {
                                                                    for(HKQuantitySample *sample in results)
                                                                    {
                                                                        //sample = results.firstObject;
                                                                        // pull out the quantity from the sample
                                                                        HKQuantity *quantity = sample.quantity;
                                                                        
                                                                        HKUnit *weightUnit = [HKUnit poundUnit];
                                                                        double ret = [quantity doubleValueForUnit:weightUnit];
                                                                        if (ret > 1) {
                                                                            userWeight = ret;
                                                                            break;
                                                                        }
                                                                    }
                                                                    NSLog(@" \n weight %fl     \n", userWeight);
                                                                }
                                                                
                                                            }];
    
    // Execute the query
    [healthStore executeQuery:sampleQuery];
}

- (void)application:application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (isRepeat == NO) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType == 10 || notificationType == 0) {
            alertNotification = [[UILocalNotification alloc] init];
            alertNotification = notification;
            [alert1 show];
            //isRepeat = YES;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == alert1) {
        if (buttonIndex == 1) {//i am standing
            UINavigationController *navc = (UINavigationController *)self.window.rootViewController;
            int notificationType = [[alertNotification.userInfo objectForKey:kNotificationTypeKey] intValue];            
            if (notificationType == 10 && ![[navc topViewController] isKindOfClass:[ExerciseViewController class]]) {
                
                if ([[navc topViewController] isKindOfClass:[CountingViewController class]]) {
                    if (![[CountingEngine getInstance] isReachedTarget]) {
                        [[CountingEngine getInstance] stopCounting];
                    }
                }
                int alarmExercise = [[alertNotification.userInfo objectForKey:kNotificationExerciseKey] intValue];
                if (alarmExercise == 0)
                    [[CountingEngine getInstance] setCurrentActionRandomly];
                else
                    [[CountingEngine getInstance] setCurrentActionAtIndex:alarmExercise % 1000 group:alarmExercise / 1000 - 1];
#ifdef FREEVERSION
                NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
                NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
                if (isPhone568)
                    storyboardName = [storyboardName stringByAppendingString:@"_568h"];
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                ExerciseViewController* exerciseViewController = (ExerciseViewController*)[storyboard instantiateViewControllerWithIdentifier:@"exerciseViewController"];
                [exerciseViewController setScheduledExercise:YES];
                [navc pushViewController:exerciseViewController animated:YES];
                
            }
            else if (notificationType == 0 && ![[navc topViewController] isKindOfClass:[ExerciseViewController class]]) {
                
                if ([[navc topViewController] isKindOfClass:[CountingViewController class]]) {
                    if (![[CountingEngine getInstance] isReachedTarget]) {
                        [[CountingEngine getInstance] stopCounting];
                    }
                }
                
#ifdef FREEVERSION
                NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
                NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
                if (isPhone568)
                    storyboardName = [storyboardName stringByAppendingString:@"_568h"];
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                ExerciseViewController* exerciseViewController = (ExerciseViewController*)[storyboard instantiateViewControllerWithIdentifier:@"exerciseViewController"];
                [exerciseViewController setScheduledExercise:YES];
                [navc pushViewController:exerciseViewController animated:YES];
            }
        }
        else if(buttonIndex == 3){//Leave me for the next 1 hour.
            UIApplication* app = [UIApplication sharedApplication];
            NSArray* oldNotifications = [app scheduledLocalNotifications];
            for (UILocalNotification *notification in oldNotifications) {
                int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
                if (notificationType == 10) {
                    int diffminutes = [notification.fireDate timeIntervalSinceDate:[NSDate date]]/60;
                    if (diffminutes <= 60 && ![globalNotif10 containsObject:notification]) {
                        [globalNotif10 addObject:notification];
                    }
                }
                else if (notificationType == 0) {
                    int diffminutes = [notification.fireDate timeIntervalSinceDate:[NSDate date]]/60;
                    if (diffminutes <= 60 && ![globalNotif0 containsObject:notification]) {
                        [globalNotif0 addObject:notification];
                    }
                }
                [app cancelLocalNotification:notification];
            }
           
            oneHourDate = [NSDate date];
            isSetOneHour = YES;
        }
        else{
            UINavigationController *navc = (UINavigationController *)self.window.rootViewController;
            if ([[navc topViewController] isKindOfClass:[CountingViewController class]]) {
                if ([[CountingEngine getInstance] isReachedTarget] || [[CountingEngine getInstance] isPaused]) {
                    [[CountingViewController getInstance] performSegueWithIdentifier:@"StopCounting" sender:[CountingViewController getInstance]];
                }
            }
        }
        isRepeat = NO;
    }
}

- (void)recordHealth{
    records += TIMERINTERVAL;
    if (records >= 10*60) {
        NSDate *now = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSIntegerMax fromDate:now];
        //[components setHour:0];
        [components setMinute:0];
        [components setSecond:0];
        NSDate *next = [[NSCalendar currentCalendar] dateFromComponents:components];
        NSDate *prev = [[NSDate alloc] init];
        prev = [next dateByAddingTimeInterval:-60*60];
        CountingEngine *engine = [CountingEngine getInstance];
        //weight
//        if(!isInitWeight){
//            [self fetchWeight];
//            if (userWeight > 1) {
//                [engine setUserWeight:userWeight];
//                isInitWeight = YES;
//            }
//            else if ([engine userWeight] > 0){
//                HKUnit *poundUnit = [HKUnit poundUnit];
//                HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:[engine userWeight]];
//                NSDate *now = [NSDate date];
//                HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
//                
//                [healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
//                    if (success) {
//                        NSLog(@"Weight updated");
//                    }
//                    else
//                        NSLog(@"Error %@", error.localizedDescription);
//                }];
//                isInitWeight = YES;
//            }
//        }
        //
        double totalCalories = [engine caloriesOfDate:prev] + [engine caloriesBySittingOfDate:prev];
//        if (totalCalories == 0) {
//            records = 0;
//            return;
//        }
        HKQuantity *hkQuatity = [HKQuantity quantityWithUnit:[HKUnit calorieUnit] doubleValue:totalCalories];
        HKQuantitySample *caloriesSample = [HKQuantitySample quantitySampleWithType:activeEnergyBurnType quantity:hkQuatity startDate:prev endDate:next];
        [healthStore saveObject:caloriesSample withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                NSLog(@"Calories updated");
            }
            else
                NSLog(@"Error %@", error.localizedDescription);
        }];
        records = 0;
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    if ( lastLocation != nil ) {
        currentLocation = lastLocation;
    }
    [locationManager stopUpdatingLocation];
}

- (void)checkDates{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *prev = [dateFormatter stringFromDate:startDate];
    NSString *curr = [dateFormatter stringFromDate:[NSDate date]];
    if (![prev isEqualToString:curr]) {
        NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
        [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSString *onlyDateToday = [dateFormatter stringFromDate:[NSDate date]];
        startDate = [[NSDate alloc] init];
        endDate = [[NSDate alloc] init];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"startDate"] != nil ) {
            NSString *start = @" ";
            NSString *end = @" ";
            start = [start stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"startDate"]];
            end = [end stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"endDate"]];
            NSString *startOfToday = [onlyDateToday stringByAppendingString:start];
            NSString *endOfToday = [onlyDateToday stringByAppendingString:end];
            startDate = [timeAndFormatter dateFromString:startOfToday];
            endDate = [timeAndFormatter dateFromString:endOfToday];
        }
        else{
            NSString *startOfToday = [onlyDateToday stringByAppendingString:@" 9:00 AM"];
            NSString *endOfToday = [onlyDateToday stringByAppendingString:@" 5:30 PM"];
            startDate = [timeAndFormatter dateFromString:startOfToday];
            endDate = [timeAndFormatter dateFromString:endOfToday];
        }
        
//        NSDateFormatter *allDateFormatter = [[NSDateFormatter alloc] init];
//        [allDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
        
        // again add local scedules
        UIApplication* app = [UIApplication sharedApplication];
        if ([globalNotif10 count] > 0) {
            for (UILocalNotification *each in globalNotif10) {
                [app scheduleLocalNotification:each];
            }
        }
        [globalNotif10 removeAllObjects];
        
        if ([globalNotif0 count] > 0) {
            for (UILocalNotification *each in globalNotif0) {
                [app scheduleLocalNotification:each];
            }
        }
        [globalNotif0 removeAllObjects];
    }
    // expire date check
    if (checkEnableApp == NO) {
        int period = [[NSDate date] timeIntervalSinceDate:expireDate];
        if( period > 3*24*60*60 )//3 days check
            isTimeToCheck = YES;
    }
}

-(void)cycleFunc{//Main timer function
    
    [self checkDates];
    
    if (isSetHealth && isRecordable) {
        [self recordHealth];
    }
    if (isSetLocation) {
//        NSString *lati = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:0];
//        NSString *longi = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:1];
//        CLLocation *fixed = [[CLLocation alloc] initWithLatitude:[lati floatValue] longitude:[longi floatValue]];
//        if ( [lati intValue] != 500 && [longi intValue] != 500 ) {

        if ( fixedLocation != nil ) {
            CLLocationDistance distance = [currentLocation distanceFromLocation:fixedLocation];
            if ( distance > METERS_PER_MILE){
                UIApplication* application = [UIApplication sharedApplication];
                NSArray* oldNotifications = [application scheduledLocalNotifications];
                NSDate *current = [NSDate date];
                int span = 0;
                for (UILocalNotification* notification in oldNotifications) {
                    span = [notification.fireDate timeIntervalSinceDate:current];
                    int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
                    if (span > 0 && span < 15) {
                        if (notificationType == 10) {
                            [globalNotif10 addObject:notification];
                        }
                        if (notificationType == 0) {
                            [globalNotif0 addObject:notification];
                        }
                        [application cancelLocalNotification:notification];
                    }
                }
            }
        }
    }
    [locationManager startUpdatingLocation];
}

//- (void) goOffNotification{
//    //shcedule immediately
//    UIApplication *app = [UIApplication sharedApplication];
//    NSDate * today = [NSDate date];
//    if (isScheduledInterval == YES) {
//        // 1 hour counting
//        int span = 0;
//        NSDateFormatter *allDateFormatter = [[NSDateFormatter alloc] init];
//        [allDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
//        if (isSetOneHour == YES && oneHourDate != nil) {
//            span = (int)[today timeIntervalSinceDate:oneHourDate];
//            if (span >= 60*60) { //after 1 hour restore
//                for (UILocalNotification* notification in globalNotif10) {
//                    [app scheduleLocalNotification:notification];
//                }
//                nextIntervalStr = [allDateFormatter stringFromDate:today];
//                nextIntervalDate = [allDateFormatter dateFromString:nextIntervalStr];
//                isSetOneHour = NO;
//            }
//            else{
//                return;
//            }
//        }
//        nextIntervalDate = [allDateFormatter dateFromString:nextIntervalStr];
//        span = (int)[nextIntervalDate timeIntervalSinceDate:today];
//        int interval = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"choseInterval"];
//        if (span > 0 && span < 11 && interval != 0) {
//            
//            UILocalNotification *alarm = [[UILocalNotification alloc] init];
//            if ( alarm ) {
//                alarm.timeZone = [NSTimeZone defaultTimeZone];
//                if (isSetSound) {
//                    alarm.soundName = UILocalNotificationDefaultSoundName;
//                }
//                alarm.fireDate = [NSDate dateWithTimeInterval:1 sinceDate:nextIntervalDate];
//                alarm.alertBody = @"Time for a standing break!";
//                alarm.repeatInterval = NSDayCalendarUnit;
//                alarm.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:kNotificationTypeKey];
//                //[app presentLocalNotificationNow:alarm];
//                [app scheduleLocalNotification:alarm];
//                if ([nextIntervalDate compare:endDate] == NSOrderedSame || [nextIntervalDate compare:endDate] == NSOrderedDescending) {
//                    isScheduledInterval = NO;
//                    nextIntervalStr = @"";
//                }
//                else{
//                    nextIntervalStr = [allDateFormatter stringFromDate:[today dateByAddingTimeInterval:interval*60 + span]];
//                    nextIntervalDate = [allDateFormatter dateFromString:nextIntervalStr];
//                }
//            }
//        }
//    }
//}

- (int)getNotifCount{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *arr = [app scheduledLocalNotifications];
    return (int) [arr count];
}

-(void)cycleBackFunc{//Main timer function
    [self cycleFunc];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
//    [saves setObject:breakDuration forKey:@"breakDuration"];
//    [saves setBool:isSetSound forKey:@"isSetSound"];
//    [saves setBool:isSetLocation forKey:@"isSetLocation"];
//    [saves setBool:isSetHealth forKey:@"isSetHealth"];
//    [saves setObject:locationInfo forKey:@"locationInfo"];
//    [saves setDouble:userWeight forKey:@"userWeight"];
//    [saves setBool:bTracker forKey:@"bTracker"];
//    [saves setBool:isRecordable forKey:@"isRecordable"];
//    [saves synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [locationManager startUpdatingLocation];
    didEnterBackdate = [NSDate date];
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:TIMERINTERVAL target:self selector:@selector(cycleBackFunc) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];

    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSUserDefaults *saves = [NSUserDefaults standardUserDefaults];
    if ([saves stringForKey:@"breakDuration"] != nil) {
        breakDuration = [saves stringForKey:@"breakDuration"];
    }
    if ([saves boolForKey:@"isSetSound"]) {
        isSetSound = [saves boolForKey:@"isSetSound"];
    }
    if ([saves boolForKey:@"isSetHealth"]) {
        isSetHealth = [saves boolForKey:@"isSetHealth"];
    }
    if ([saves doubleForKey:@"userWeight"]) {
        userWeight = [saves doubleForKey:@"userWeight"];
    }
    if ([saves boolForKey:@"bTracker"]) {
        bTracker = [saves boolForKey:@"bTracker"];
    }
    if ([saves boolForKey:@"isRecordable"]) {
        isRecordable = [saves boolForKey:@"isRecordable"];
    }
    if ([saves boolForKey:@"isSetLocation"]) {
        isSetLocation = [saves boolForKey:@"isSetLocation"];
    }

    //locationInfo = [saves stringForKey:@"locationInfo"];
    if ( [saves stringForKey:@"locationInfo"] != nil) {
        locationInfo = [saves stringForKey:@"locationInfo"];
        NSString *lati = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:0];
        NSString *longi = [[locationInfo componentsSeparatedByString:@"x"] objectAtIndex:1];
        fixedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake([lati floatValue], [longi floatValue]) altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    }
    else{
        locationInfo = nil;
        fixedLocation = nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *prev = [dateFormatter stringFromDate:startDate];
    NSString *curr = [dateFormatter stringFromDate:[NSDate date]];
    if (![prev isEqualToString:curr]) {
        NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
        [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSString *onlyDateToday = [dateFormatter stringFromDate:[NSDate date]];
        startDate = [[NSDate alloc] init];
        endDate = [[NSDate alloc] init];
        if ([[NSUserDefaults standardUserDefaults] stringForKey:@"startDate"] != nil ) {
            NSString *start = @" ";
            NSString *end = @" ";
            start = [start stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"startDate"]];
            end = [end stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:@"endDate"]];
            NSString *startOfToday = [onlyDateToday stringByAppendingString:start];
            NSString *endOfToday = [onlyDateToday stringByAppendingString:end];
            startDate = [timeAndFormatter dateFromString:startOfToday];
            endDate = [timeAndFormatter dateFromString:endOfToday];
        }
        else{
            NSString *startOfToday = [onlyDateToday stringByAppendingString:@" 9:00 AM"];
            NSString *endOfToday = [onlyDateToday stringByAppendingString:@" 5:30 PM"];
            startDate = [timeAndFormatter dateFromString:startOfToday];
            endDate = [timeAndFormatter dateFromString:endOfToday];
        }
    }
    
    UINavigationController *navc = (UINavigationController *)self.window.rootViewController;
    UIViewController *topvc = [navc topViewController];
    
    NSLog(@"applicationWillEnterForeground: %@", topvc);
    
    if ([topvc respondsToSelector:@selector(viewControllerWillEnterForeground)])
    {
        [topvc performSelector:@selector(viewControllerWillEnterForeground)];
    }
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
//        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
//    }
    
    if (!checkEnableApp) {
        if (isTimeToCheck) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Your In - App Purchase" message:@"To continue use, please purchase in the App Store for $0.99." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            exit(0);
        }
    }
    // Juseman add
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    NSDate *now = [NSDate date];
    BOOL flag = NO;
    for (UILocalNotification* notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if ( notificationType == 10 || notificationType == 0 ) {
            if ( [didEnterBackdate compare:notification.fireDate] == NSOrderedAscending && [notification.fireDate compare:now] == NSOrderedAscending ) {
                alertNotification = notification;
                flag = YES;
                break;
            }
        }        
    }
    if (flag && isRepeat == NO) {
        [alert1 show];
        isRepeat = YES;
    }

    UINavigationController *navc = (UINavigationController *)self.window.rootViewController;
    UIViewController *topvc = [navc topViewController];
    if ([topvc respondsToSelector:@selector(viewControllerDidBecomeActive)])
    {
        [topvc performSelector:@selector(viewControllerDidBecomeActive)];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // FBSample logic
    // if the app is going away, we close the session object; this is a good idea because
    // things may be hanging off the session, that need releasing (completion block, etc.) and
    // other components in the app may be awaiting close notification in order to do cleanup
    [FBSession.activeSession close];
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSArray* oldNotifications = [application scheduledLocalNotifications];    
    for (UILocalNotification* notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType != 10 && notificationType != 0)
            [application cancelLocalNotification:notification];
    }
    
    for (UILocalNotification* notification in globalNotif10) {
        [application scheduleLocalNotification:notification];
    }
    [globalNotif10 removeAllObjects];
    
    for (UILocalNotification* notification in globalNotif0) {
        [application scheduleLocalNotification:notification];
    }
    [globalNotif0 removeAllObjects];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    [locationUpdateTimer invalidate];
    locationUpdateTimer = nil;
}

#pragma mark -

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - Facebook related methods

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification
                                                                object:session];
            
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithPermissions:@[@"publish_stream"]
                                          allowLoginUI:allowLoginUI
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         [self sessionStateChanged:session state:state error:error];
                                     }];
}

- (void)checkDevice
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5 and iPod Touch 5th generation: 4 inch screen
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone4
#ifdef FREEVERSION
            UIStoryboard *iPhone4Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_Free_iPhone_568h" bundle:nil];
#else
            UIStoryboard *iPhone4Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone_568h" bundle:nil];
#endif
            
            UIViewController *initialViewController = [iPhone4Storyboard instantiateInitialViewController];
            NSLog(@"%@", initialViewController);
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController  = initialViewController;
            //            [self.window makeKeyAndVisible];
        }
    }
}

@end
