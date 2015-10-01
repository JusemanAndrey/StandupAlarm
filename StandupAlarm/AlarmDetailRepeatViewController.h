//
//  AlarmDetailRepeatViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "AlarmDetailViewController.h"

@interface AlarmDetailRepeatViewController : UIViewController
{
    GADBannerView *bannerView_;
}

@property (strong, nonatomic) AlarmDetailViewController* alarmDetailViewController;

@end
