//
//  AlarmViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface AlarmViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    GADBannerView *bannerView_;
}

@property (weak, nonatomic) IBOutlet UITableView *alarmTableView;
- (IBAction)showAlarmDetain:(id)sender;

@end
