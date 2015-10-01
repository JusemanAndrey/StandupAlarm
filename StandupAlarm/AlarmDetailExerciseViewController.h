//
//  AlarmDetailExerciseViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "AlarmDetailViewController.h"

@interface AlarmDetailExerciseViewController : UIViewController
{
    GADBannerView *bannerView_;
    NSIndexPath* currentExercise;
}

@property (weak, nonatomic) IBOutlet UITableView *alarmExerciseTableView;
@property (strong, nonatomic) AlarmDetailViewController* alarmDetailViewController;

@end
