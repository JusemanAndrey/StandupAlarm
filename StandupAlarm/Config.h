//
//  Config.h
//  StandupAlarm
//
//  Created by Apple Fan on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef StandupAlarm_Config_h
#define StandupAlarm_Config_h

//================== constant for test =====================

// test flag
#define USE_TEST_TIME       false
#define USE_TEST_SPLASH     false

// exercise time
#define TEST_EXERCISE_TIME              60      // 60s
#define TEST_SNOOZE_TIME                30      // 30s

//================== constant for application =====================

#define USE_SPLASH          true

#ifdef FREEVERSION
#define USE_ADMOB           true
#else
#define USE_ADMOB           false
#endif

#define SNOOZE_TIME                     60      // 60s == 1min

// time while show intro screen
#define INTRO_TIMEOUT                   2       // 1s

#define DEFAULT_INTERVAL                1       // 0 = 15mins, 1 = 30mins, 2 = 60mins, 3 = 90mins, 4 = 120mins

#define DOMORE_URL                      @"http://standapp.biz/shop/"

#define FACEBOOK_URL                    @"https://www.facebook.com/standappforhealth"
#define FACEBOOK_PICTURE                @"https://s3.amazonaws.com/standapp/logo.png"
#define FACEBOOK_NAME                   @"Stand App"
#define FACEBOOK_CAPTION                @"Stand App site"
#define FACEBOOK_DESCRIPTION            @"This site provides you various types of information and goods that will maximize your health."
#define FACEBOOK_MESSAGE_BURNED         @"I burned %d extra calories today at work using StandApp!"
#define FACEBOOK_MESSAGE_NOBURNED       @"I am burning calories taking Standing breaks while I'm at work using StandApp!"

#define USE_ACTIONLIST_GROUP            false

#define MET_FOR_SITTING                 1.8

#endif
