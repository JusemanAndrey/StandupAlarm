//
//  AppDelegate.h
//  StandupAlarm
//
//  Created by Apple Fan on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <HealthKit/HealthKit.h>
#import "Config.h"

extern NSString *const SCSessionStateChangedNotification;
extern BOOL isTimeToCheck, checkEnableApp;
extern double userWeight;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> {
    HKHealthStore *healthStore;
    HKQuantityType *activeEnergyBurnType;
    HKQuantityType *weightType;
    NSTimer *locationUpdateTimer;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UILocalNotification *localNotification;
@property (strong, nonatomic) NSTimer *locationUpdateTimer;
// The app delegate is responsible for maintaining the current FBSession. The application requires
// the user to be logged in to Facebook in order to do anything interesting -- if there is no valid
// FBSession, a login screen is displayed.
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
