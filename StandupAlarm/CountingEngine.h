//
//  CountingEngine.h
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountingEngine : NSObject
{
    NSArray *actionsGroupList;
    int currentGroup;
    int currentIndex;
    NSMutableDictionary *caloriesData;
    NSMutableDictionary *breakCountsData;
    NSMutableDictionary *caloriesHourly;
}

@property (atomic, assign) int targetInterval;
@property (atomic, assign) int nextTargetInterval;
@property (atomic, assign) double targetTime;
@property (atomic, assign) double pausedTime;

@property (atomic, assign) BOOL isMaxim;
@property (atomic, assign) double tMaximTime;
@property (atomic, assign) double pMaximTime;

@property (atomic, assign) int adCounter;
@property (atomic, assign) BOOL restartFlag;

@property (atomic, assign) BOOL firstLunch;
@property (strong, nonatomic) NSMutableDictionary *caloriesHourly;
// 0: not yet determined, 1: disconnect, 2: ok
@property (atomic, assign) Byte networkStatus;

+ (CountingEngine*) getInstance;
+ (BOOL)date:(NSDate *)date isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;
+ (NSString *)getDateKey:(NSDate *)date;
+ (int) getTimeDiff:(NSDate *)now withDate:(NSDate *)fireDate;

- (int) getCurrentIndex;

// repeat counting with previous interval
- (void)startCounting;

// param targetInterval : by minutes
- (void)startCountingWithInterval:(int)interval scheduleType:(int)scheduleType resetInterval:(bool)resetInterval;

- (void)stopCounting;

- (void)pauseCounting;

- (void)resumeCounting;

- (bool)isPaused;

- (bool)isReachedTarget;

- (int)getRemainingTimeValue;

- (float)getPassRate;

- (NSString*)getRemainingTimeString;

// Clear out the old notification and Create a new notification
- (void)scheduleAlarmForDate:(NSDate*)theDate scheduleType:(int)scheduleType;

// Clear out the old notification
- (void)unscheduleAlarm;

// load action list from document's saved file or bundle xml file.
- (void)loadActionList;

// save action list to document
- (void)saveActionList;

// return number of actions groups
- (int)numberOfActionGroups;

- (NSString*)titleOfActionGroup:(int)group;

- (int)numberOfActionsForGroup:(int)group;

- (NSDictionary*)actionAtIndex:(int)index group:(int)group;

- (NSDictionary*)currentAction;

- (void)setCurrentActionAtIndex:(int)index group:(int)group;

- (void)setCurrentActionRandomly;

- (void)setCurrentActionEnabled:(BOOL)enable;

- (BOOL)isEmeptyActionQueue;

- (void)resetActionQueue;

- (float)userWeight;

- (void)setUserWeight:(float)weight;

- (void)applyWeight;

- (void)loadCaloriesData;

- (void)saveCaloriesData;

- (int)caloriesOfDate:(NSDate*)date;

- (int)caloriesBySittingOfDate:(NSDate*)date;

//Maxim

- (void)calcCalories;
- (void)calcCaloriesSitting;

- (void)loadHourlyData;
- (void)saveHourlyData;
- (int)getHourlyCalories:(NSDate*)date index:(NSString *)index;
- (void)calcHourlyCalories;

- (void)loadCountsData;
- (void)saveCountsData;
- (int)countsOfDate:(NSDate*)date;
- (void)addCountsData:(NSDate *)date;

- (void)unscheduleAllAlarm;
+ (int) calculateCount;

//#define GETCURRENTTIME                  CACurrentMediaTime()
#define GETCURRENTTIME                  [[NSDate date] timeIntervalSince1970]

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define iPhoneImageNamed(image) (isPhone568 ? [NSString stringWithFormat:@"%@-568h.%@", [image stringByDeletingPathExtension], [image pathExtension]] : image)
#define iPhoneImage(image) ([UIImage imageNamed:iPhoneImageNamed(image)])

extern NSString *kNotificationTypeKey;
extern NSString *kNotificationGuidKey;
extern NSString *kNotificationWeekdaysKey;
extern NSString *kNotificationExerciseKey;

@end
