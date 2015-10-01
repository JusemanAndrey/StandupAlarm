//
//  CountingEngine.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountingEngine.h"
#import "ActionsGroup.h"
#import "Config.h"
#import "ExerciseViewController.h"
#import <QuartzCore/CAAnimation.h>

extern BOOL isSetSound;
extern NSDate *startDate;
extern NSDate *endDate;

@implementation CountingEngine

@synthesize targetInterval;
@synthesize nextTargetInterval;
@synthesize targetTime;
@synthesize pausedTime;

@synthesize isMaxim;
@synthesize tMaximTime;
@synthesize pMaximTime;

@synthesize adCounter;
@synthesize restartFlag;

@synthesize firstLunch;
@synthesize networkStatus;
@synthesize caloriesHourly;
NSString *kNotificationTypeKey      = @"kNotificationTypeKey";
NSString *kNotificationGuidKey      = @"kNotificationGuidKey";
NSString *kNotificationWeekdaysKey  = @"kNotificationWeekdaysKey";
NSString *kNotificationExerciseKey  = @"kNotificationExerciseKey";

static id __strong instance = nil;

+ (CountingEngine*)getInstance
{
    if (instance == nil) {
        instance = [[CountingEngine alloc] init];
    }
    return instance;
}

+ (int) calculateCount{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    return (int)[oldNotifications count];
}

+ (int) getTimeDiff:(NSDate *)now withDate:(NSDate *)fireDate{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* nowHour1 = [cal components:NSHourCalendarUnit fromDate:now];
    NSDateComponents* nowMinute1 = [cal components:NSMinuteCalendarUnit fromDate:now];
    NSDateComponents* nowSec1 = [cal components:NSSecondCalendarUnit fromDate:now];
    NSDateComponents* nowHour2 = [cal components:NSHourCalendarUnit fromDate:fireDate];
    NSDateComponents* nowMinute2 = [cal components:NSMinuteCalendarUnit fromDate:fireDate];
    NSDateComponents* nowSec2 = [cal components:NSSecondCalendarUnit fromDate:fireDate];
    return (nowHour2.hour - nowHour1.hour)*3600 + (nowMinute2.minute - nowMinute1.minute)*60 + (nowSec2.second - nowSec1.second);
}

+ (NSString *)getDateKey:(NSDate *)date{//get index
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSIntegerMax fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    NSDateComponents *diff = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:midnight toDate:date options:0];
    NSInteger hoursPast = [diff hour];
    NSString *ret = [NSString stringWithFormat:@"%d", hoursPast];
    return ret;
}

+ (BOOL)date:(NSDate *)date isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate{
    if ([beginDate compare:endDate] == NSOrderedDescending || [beginDate compare:date] == NSOrderedDescending || [date compare:endDate] == NSOrderedDescending) {
        return NO;
    }
    else
        return YES;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
//    [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
//    int criteriaVal, beginVal, endVal;
//    
//    NSString *temp = [dateFormatter stringFromDate:date];//criteria date
//    temp = [temp stringByAppendingString:@" 12:00 AM"];
//    NSDate *criDate = [[NSDate alloc] init];
//    criDate = [timeAndFormatter dateFromString:temp];
//    criteriaVal = [date timeIntervalSinceDate:criDate];
//    
//    temp = [dateFormatter stringFromDate:beginDate];//begin date
//    temp = [temp stringByAppendingString:@" 12:00 AM"];
//    NSDate *date1 = [[NSDate alloc] init];
//    date1 = [timeAndFormatter dateFromString:temp];
//    beginVal = [beginDate timeIntervalSinceDate:date1];
//    
//    temp = [dateFormatter stringFromDate:endDate];//end date
//    temp = [temp stringByAppendingString:@" 12:00 AM"];
//    NSDate *date2 = [[NSDate alloc] init];
//    date2 = [timeAndFormatter dateFromString:temp];
//    endVal = [endDate timeIntervalSinceDate:date2];
//    
//    if (criteriaVal >= beginVal && criteriaVal <= endVal ) {
//        return YES;
//    }
//    else
//        return NO;
}

- (id)init
{
    self = [super init];
    NSString* cur_ver = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    NSString* app_ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    // if update, remove old data
    if (cur_ver == nil || app_ver == nil || [cur_ver compare:app_ver options:NSNumericSearch] == NSOrderedAscending) {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ActionList.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:plistPath])
            [fileManager removeItemAtPath:plistPath error:nil];
    }
    
    // save current version
    [[NSUserDefaults standardUserDefaults] setObject:app_ver forKey:@"version"];
    
    targetInterval = 5;
    nextTargetInterval = 5;
    targetTime = 0;
    pausedTime = 0;
    //maxim
    isMaxim = NO;
    tMaximTime = 0;
    pMaximTime = 0;
    
    adCounter = 0;
    restartFlag = NO;
    
    firstLunch = YES;
    networkStatus = 0;
    
    srand(time(0));
    [self loadActionList];
    [self loadCaloriesData];
    //Maxim
    [self loadCountsData];
    //[self loadHourlyData];

    return self;
}

- (void)startCounting
{
    [self startCountingWithInterval:nextTargetInterval scheduleType:0 resetInterval:YES];
}

- (void)startCountingWithInterval:(int)interval scheduleType:(int)scheduleType resetInterval:(bool)resetInterval
{
    targetInterval = interval;
    targetTime = GETCURRENTTIME + targetInterval + 1;
    pausedTime = 0;
    
    if (resetInterval) {
        nextTargetInterval = targetInterval;
        [self setCurrentActionRandomly];
    }

    [self scheduleAlarmForDate:[NSDate dateWithTimeIntervalSinceNow:targetInterval] scheduleType:scheduleType];
    
    NSDictionary *action = [self currentAction];
    [action setValue:[NSNumber numberWithBool:NO] forKey:@"actionQueue"];
    
    if ([self isEmeptyActionQueue]) {
        [self resetActionQueue];
        [action setValue:[NSNumber numberWithBool:NO] forKey:@"actionQueue"];
    }
    
    [[CountingEngine getInstance] saveActionList];
}

- (void)stopCounting
{
    targetTime = 0;
    pausedTime = 0;
    [self unscheduleAlarm];
}

- (void)pauseCounting
{
    pausedTime = GETCURRENTTIME;
    [self unscheduleAlarm];
}

- (void)resumeCounting
{
    //[self scheduleAlarmForDate:[NSDate dateWithTimeIntervalSinceNow:(targetTime - pausedTime)] scheduleType:0];
    targetTime += (GETCURRENTTIME - pausedTime);
    pausedTime = 0;
}

- (bool)isPaused
{
    return pausedTime != 0;
}

- (bool)isReachedTarget
{
    return (targetTime > 0) && (pausedTime == 0) && (GETCURRENTTIME >= targetTime);
}

- (int)getRemainingTimeValue
{
    int remainingTime = 0;
    if (![self isReachedTarget]) {        
        if (pausedTime == 0) {        // running state
            remainingTime = (targetTime - GETCURRENTTIME);
        } else {
            remainingTime = (targetTime - pausedTime);
        }
    }
    if (remainingTime < 0)
        remainingTime = 0;
    return remainingTime;
}
- (float)getPassRate
{
    return 1 - ((float)[self getRemainingTimeValue] / targetInterval);
}

- (NSString*)getRemainingTimeString
{
    int remainingTime = [self getRemainingTimeValue];
    return [NSString stringWithFormat:@"%02d:%02d", remainingTime / 60, remainingTime % 60];
}

- (void)scheduleAlarmForDate:(NSDate*)theDate scheduleType:(int)scheduleType
{
    [self unscheduleAlarm];
    BOOL flag = TRUE;
    //UIApplication* app = [UIApplication sharedApplication];
    
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        if (isSetSound) {
            alarm.soundName = UILocalNotificationDefaultSoundName;
        }
        alarm.timeZone = [NSTimeZone defaultTimeZone];

        if (scheduleType == 1) {            // exercise timer
            // schedule timer to get back to work
            alarm.alertBody = @"Get back to work :)";
            alarm.fireDate = theDate;
            alarm.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:kNotificationTypeKey];
            //[app scheduleLocalNotification:alarm];
            flag = [[self class] date:theDate isBetweenDate:startDate andDate:endDate];
            if (flag == YES){
                //[app scheduleLocalNotification:alarm];
            // starting time to schedule continued exercise timer
                theDate = [theDate dateByAddingTimeInterval:nextTargetInterval];
            }
        } else if (scheduleType == 2) {     // snooze timer
            // schedule snooze timer
            alarm.alertBody = @"Time for a snooze standing break!";
            alarm.fireDate = theDate;
            alarm.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:kNotificationTypeKey];
            //[app scheduleLocalNotification:alarm];
            flag = [[self class] date:theDate isBetweenDate:startDate andDate:endDate];
            if (flag == YES){
                //[app scheduleLocalNotification:alarm];
                // starting time to schedule continued exercise timer
                theDate = [theDate dateByAddingTimeInterval:nextTargetInterval];
            }
        }
        // schedule exercise timer
        else if (scheduleType == 0){
            alarm.alertBody = @"Time for a standing break!";
            alarm.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:kNotificationTypeKey];
            
//            if ([globalNotif0 count] > 0) {
//                [globalNotif0 removeAllObjects];
//            }
            
#if !USE_TEST_TIME
            
//            int minutes = nextTargetInterval/60;
//            NSDate *now = [NSDate date];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//            NSString *todayString = [dateFormatter stringFromDate:now];
//            
//            NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
//            [timeAndFormatter setDateFormat:@" hh:mm a"];
//            NSString *start = @" ";
//            NSString *end = @" ";
//            NSString *startDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];
//            NSString *endDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"endDate"];
//            if (startDay == nil) {
//                startDay = [timeAndFormatter stringFromDate:startDate];
//            }
//            else{
//                startDay = [start stringByAppendingString:startDay];
//            }
//            if (endDay == nil) {
//                endDay = [timeAndFormatter stringFromDate:endDate];
//            }
//            else{
//                endDay = [end stringByAppendingString:endDay];
//            }
//            NSDateFormatter *allTimeAndFormatter = [[NSDateFormatter alloc] init];
//            [allTimeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
//            NSDate *recStartDate = [[NSDate alloc] init];
//            NSDate *recEndDate = [[NSDate alloc] init];
//            recStartDate = [allTimeAndFormatter dateFromString:[todayString stringByAppendingString:startDay]];
//            recEndDate = [allTimeAndFormatter dateFromString:[todayString stringByAppendingString:endDay]];
//            int segments = (int)[recEndDate timeIntervalSinceDate:recStartDate]/60;
//            for ( int i = 0; i < segments/minutes ; i++) {
//                alarm.fireDate = [NSDate dateWithTimeInterval:i * 60 * minutes sinceDate:recStartDate];
//                alarm.repeatInterval = NSDayCalendarUnit;
//                [app scheduleLocalNotification:alarm];
//                [globalNotif0 addObject:alarm];
//            }

#else
            int cnt = 60 / nextTargetInterval;
            for (int i = 0; i < cnt; i++) {
                alarm.fireDate = [NSDate dateWithTimeInterval:i * 60 / cnt sinceDate:theDate];
                alarm.repeatInterval = NSMinuteCalendarUnit;
                //[app scheduleLocalNotification:alarm];
                flag = [[self class] date:theDate isBetweenDate:startDate andDate:endDate];
                if (flag){
                    [app scheduleLocalNotification:alarm];
                }
            }
#endif
        }
    }
}

- (void)unscheduleAlarm
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    for (UILocalNotification* notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType < 10 && notificationType != 0)
            [app cancelLocalNotification:notification];
    }
}

- (void)unscheduleAllAlarm
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* oldNotifications = [app scheduledLocalNotifications];
    for (UILocalNotification* notification in oldNotifications) {
        int notificationType = [[notification.userInfo objectForKey:kNotificationTypeKey] intValue];
        if (notificationType == 0)
            [app cancelLocalNotification:notification];
    }
}

- (void)loadActionList
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ActionList.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        plistPath = [[NSBundle mainBundle] pathForResource:@"ActionList" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    actionsGroupList = [NSPropertyListSerialization propertyListFromData:plistXML
                                                        mutabilityOption:NSPropertyListMutableContainers
                                                                  format:&format
                                                        errorDescription:&errorDesc];
    
    if (!actionsGroupList) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    BOOL flag = false;
    for (currentGroup = 0; currentGroup < [actionsGroupList count]; currentGroup++) {
        NSDictionary* group = [actionsGroupList objectAtIndex:currentGroup];
        NSArray* actionList = [group objectForKey:@"actionList"];
        for (currentIndex = 0; currentIndex < [actionList count]; currentIndex++) {
            if ([[[actionList objectAtIndex:currentIndex] objectForKey:@"actionEnabled"] boolValue]) {
                flag = true;
                break;
            }
        }        
        if (flag)
            break;
    }
}

- (void)saveActionList
{
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ActionList.plist"];

    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:actionsGroupList
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    } else {
        NSLog(@"%@", error);
    }
}

- (int)numberOfActionGroups
{
    return [actionsGroupList count];
}

- (NSString*)titleOfActionGroup:(int)group
{
    NSDictionary *actionGroup = [actionsGroupList objectAtIndex:group];
    return [actionGroup objectForKey:@"groupTitle"];
}

- (int)numberOfActionsForGroup:(int)group
{
    NSDictionary *actionGroup = [actionsGroupList objectAtIndex:group];
    NSArray *actionList = [actionGroup objectForKey:@"actionList"];
    return [actionList count];
}

- (NSDictionary*)actionAtIndex:(int)index group:(int)group
{
    NSDictionary *actionGroup = [actionsGroupList objectAtIndex:group];
    NSArray *actionList = [actionGroup objectForKey:@"actionList"];
    return [actionList objectAtIndex:index];
}

- (NSDictionary*)currentAction
{
    return [self actionAtIndex:currentIndex group:currentGroup];
}

- (int)getCurrentIndex{
    return currentIndex;
}

- (void)setCurrentActionAtIndex:(int)index group:(int)group
{
    currentGroup = group;
    currentIndex = index;
}

- (void)setCurrentActionRandomly
{
    NSMutableArray* temp = [[NSMutableArray alloc] init];

    for (int i = 0; i < [actionsGroupList count]; i++) {
        NSDictionary* group = [actionsGroupList objectAtIndex:i];
        NSArray* actionList = [group objectForKey:@"actionList"];
        for (int j = 0; j < [actionList count]; j++) {
            NSDictionary* action = [actionList objectAtIndex:j];
            if ([[action objectForKey:@"actionEnabled"] boolValue] && [[action objectForKey:@"actionQueue"] boolValue]) {
                [temp addObject:[NSNumber numberWithInt:(i * 100 + j)]];
            }
        }
    }
    
    if ([temp count] > 0) {
        int k = rand() % [temp count];
//        int k = arc4random() % [temp count];
        int group_index = [[temp objectAtIndex:k] intValue];

        currentGroup = group_index / 100;
        currentIndex = group_index % 100;
    } else {
        currentGroup = 0;
        currentIndex = 0;
    }
}

- (void)setCurrentActionEnabled:(BOOL)enable
{
    NSDictionary* action = [self currentAction];
    [action setValue:[NSNumber numberWithBool:enable] forKey:@"actionEnabled"];
    
    [self saveActionList];
}

- (BOOL)isEmeptyActionQueue
{
    for (int i = 0; i < [actionsGroupList count]; i++) {
        NSDictionary* group = [actionsGroupList objectAtIndex:i];
        NSArray* actionList = [group objectForKey:@"actionList"];
        for (int j = 0; j < [actionList count]; j++) {
            if ([[[actionList objectAtIndex:j] objectForKey:@"actionQueue"] boolValue]) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)resetActionQueue
{
    for (int i = 0; i < [actionsGroupList count]; i++) {
        NSDictionary* group = [actionsGroupList objectAtIndex:i];
        NSArray* actionList = [group objectForKey:@"actionList"];
        for (int j = 0; j < [actionList count]; j++) {
            [[actionList objectAtIndex:j] setValue:[NSNumber numberWithBool:YES] forKey:@"actionQueue"];
        }
    }
}

- (float)userWeight
{
    NSNumber* item = [caloriesData objectForKey:@"weight"];
    if (item)
        return [item floatValue];
    
    return 0;
}

- (void)setUserWeight:(float)weight
{
    [caloriesData setObject:[NSNumber numberWithFloat:weight] forKey:@"weight"];
}

- (void)applyWeight
{
    // get user weight;
    float weight = [self userWeight] / 2.2;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate* today = [NSDate date];
    NSString* day;
    NSNumber* item;
    
    for (int i = 0; i < 5; i++) {
        day = [formatter stringFromDate:[today dateByAddingTimeInterval:-secondsPerDay * i]];
        item = [caloriesData valueForKey:day];
        if (item != nil) {
            item = [NSNumber numberWithFloat:[item floatValue] * weight];
            [caloriesData setValue:item forKey:day];
        }

        day = [day stringByAppendingString:@"_sitting"];
        item = [caloriesData valueForKey:day];
        if (item != nil) {
            item = [NSNumber numberWithFloat:[item floatValue] * weight];
            [caloriesData setValue:item forKey:day];
        }
    }
}

- (void)loadCountsData{
    // create data variable
    breakCountsData = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate* today = [NSDate date];
    NSString* day;
    NSNumber* item;
    
    // load saved data
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *countsPath = [rootPath stringByAppendingPathComponent:@"breakcounts.data"];
    NSDictionary* data = [NSDictionary dictionaryWithContentsOfFile:countsPath];
    
    if (data) {
        // set break counts data for 5 days.
        for (int i = 0; i < 5; i++) {
            day = [formatter stringFromDate:[today dateByAddingTimeInterval:-secondsPerDay * i]];
            item = [data valueForKey:day];
            if (item != nil)
                [breakCountsData setValue:item forKey:day];
        }
    }
}

- (void)saveCountsData{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *countsPath = [rootPath stringByAppendingPathComponent:@"breakcounts.data"];
    [breakCountsData writeToFile:countsPath atomically:YES];
}

- (int)countsOfDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [formatter stringFromDate:date];
    NSNumber* item = [breakCountsData valueForKey:day];
    if (item)
        return [item intValue];
    return 0;
}

- (void)addCountsData:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [formatter stringFromDate:date];
    NSNumber *item = [breakCountsData valueForKey:day];
    int ret = [item intValue] + 1;
    item = [NSNumber numberWithInt:ret];
    [breakCountsData setValue:item forKey:day];
}

- (void)loadHourlyData{
    caloriesHourly = [[NSMutableDictionary alloc] initWithCapacity:24];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    NSString *startOfToday = [today stringByAppendingString:@" 12:00 AM"];
    NSDateFormatter *timeAndFormatter = [[NSDateFormatter alloc] init];
    [timeAndFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSDate* midnight = [[NSDate alloc] init];
    midnight = [timeAndFormatter dateFromString:startOfToday];
    NSString* hour;
    NSNumber* item;
    NSTimeInterval secondsPerHour = 60 * 60;
    NSDateFormatter *indexFormatter = [[NSDateFormatter alloc] init];
    [indexFormatter setDateFormat:@"yyyy-MM-dd HH"];
    // load saved data
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *countsPath = [rootPath stringByAppendingPathComponent:@"hourlycalories.data"];
    NSDictionary* data = [NSDictionary dictionaryWithContentsOfFile:countsPath];
    
    if (data) {
        // set break counts data for 5 days.
        for (int i = 0; i < 24; i++) {
            hour = [indexFormatter stringFromDate:[midnight dateByAddingTimeInterval:secondsPerHour * i]];//2015-04-18 2
            item = [data valueForKey:hour];
            if (item != nil)
                [caloriesHourly setValue:item forKey:hour];
        }
    }
}
- (void)saveHourlyData{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *countsPath = [rootPath stringByAppendingPathComponent:@"hourlycalories.data"];
    [caloriesHourly writeToFile:countsPath atomically:YES];
}

- (int)getHourlyCalories:(NSDate*)date index:(NSString *)index{
    if ([index intValue] < 0) {
        return 0;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dayAndIndex = [formatter stringFromDate:date];
    dayAndIndex = [dayAndIndex stringByAppendingString:@" "];
    dayAndIndex = [dayAndIndex stringByAppendingString:index];
    NSNumber* item = [caloriesHourly valueForKey:dayAndIndex];
    if (item)
        return [item intValue];
    return 0;
}

- (void)calcHourlyCalories{
    NSDate *date = [NSDate date];
    NSString *index = [[self class] getDateKey:date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dayAndIndex = [formatter stringFromDate:date];
    dayAndIndex = [dayAndIndex stringByAppendingString:@" "];
    dayAndIndex = [dayAndIndex stringByAppendingString:index];
    int ret = [self caloriesOfDate:date] + [self caloriesBySittingOfDate:date];
    NSNumber *item = [NSNumber numberWithInt:ret];
    [caloriesHourly setValue:item forKey:dayAndIndex];
}

- (void)loadCaloriesData
{
    // create data variable
    caloriesData = [[NSMutableDictionary alloc] initWithCapacity:11];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate* today = [NSDate date];
    NSString* day;
    NSNumber* item;
    // load saved data
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *caloriesPath = [rootPath stringByAppendingPathComponent:@"calories.data"];
    NSDictionary* data = [NSDictionary dictionaryWithContentsOfFile:caloriesPath];
    
    if (data) {
        // set calories data for 5 days.
        for (int i = 0; i < 5; i++) {
            day = [formatter stringFromDate:[today dateByAddingTimeInterval:-secondsPerDay * i]];
            item = [data valueForKey:day];
            if (item != nil)
                [caloriesData setValue:item forKey:day];

            day = [day stringByAppendingString:@"_sitting"];
            item = [data valueForKey:day];
            if (item != nil)
                [caloriesData setValue:item forKey:day];
        }
        
        [caloriesData setObject:[data objectForKey:@"weight"] forKey:@"weight"];
    } else {
        [caloriesData setObject:[NSNumber numberWithFloat:0] forKey:@"weight"];
    }
}

- (void)saveCaloriesData
{
    // load saved data
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *caloriesPath = [rootPath stringByAppendingPathComponent:@"calories.data"];
    [caloriesData writeToFile:caloriesPath atomically:YES];
}

- (int)caloriesOfDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [formatter stringFromDate:date];
    NSNumber* item = [caloriesData valueForKey:day];
    if (item)
        return (int)([item floatValue] + 0.5);
    return 0;
}

- (int)caloriesBySittingOfDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [[formatter stringFromDate:date] stringByAppendingString:@"_sitting"];
    NSNumber* item = [caloriesData valueForKey:day];
    if (item)
        return (int)([item floatValue] + 0.5);
    return 0;
}

- (void)calcCaloriesSitting{
    // calc this exercise
    float currentCaloriesSittingDown = 0;
    float weight = [self userWeight] / 2.2;
    NSDictionary* action = [self currentAction];
    int time = [[action objectForKey:@"actionTime"] intValue];
    if (weight > 0) {
        currentCaloriesSittingDown = weight * MET_FOR_SITTING * time * 3.5 / 200;
    } else {
        currentCaloriesSittingDown = MET_FOR_SITTING * time * 3.5 / 200;
    }
    // get today calories
    float caloriesSittingDown = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [formatter stringFromDate:[NSDate date]];
    day = [day stringByAppendingString:@"_sitting"];
    NSNumber *item = [caloriesData valueForKey:day];
    if (item)
        caloriesSittingDown = [item floatValue];
    // update
    caloriesSittingDown += currentCaloriesSittingDown;
    [caloriesData setValue:[NSNumber numberWithFloat:caloriesSittingDown] forKey:day];
}

- (void)calcCalories
{
    float currentCaloriesStandApp = 0;
    float weight = [self userWeight] / 2.2;
    NSDictionary* action = [self currentAction];
    int time = [[action objectForKey:@"actionTime"] intValue];
    float met = [[action objectForKey:@"caloriesMET"] floatValue];
    if (weight > 0) {
        currentCaloriesStandApp = weight * met * time * 3.5 / 200;
    } else {
        currentCaloriesStandApp = met * time * 3.5 / 200;
    }

    float caloriesStandApp = 0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* day = [formatter stringFromDate:[NSDate date]];
    NSNumber* item = [caloriesData valueForKey:day];
    if (item)
        caloriesStandApp = [item floatValue];
    
    // update
    caloriesStandApp += currentCaloriesStandApp;
    [caloriesData setValue:[NSNumber numberWithFloat:caloriesStandApp] forKey:day];
}

@end
