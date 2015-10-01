//
//  IntroViewController.h
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@interface IntroViewController : UIViewController

- (void)showMainMenuWithDelay;

- (void)showMainMenuWithDelayOnMainThread;

- (void)showMainMenu;

@end
