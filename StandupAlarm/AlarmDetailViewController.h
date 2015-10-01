//
//  AlarmDetailViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface AlarmDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate >
{
    GADBannerView *bannerView_;
}

@property (weak, nonatomic) IBOutlet UITableView *alarmDetailTableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *alarmTimePicker;

@property (strong, nonatomic) NSString* alarmGuid;
@property (strong, nonatomic) NSDate* alarmTime;
@property (assign, nonatomic) int alarmRepeat;
@property (assign, nonatomic) int alarmExercise;

- (IBAction)saveAlarm:(id)sender;

@end
