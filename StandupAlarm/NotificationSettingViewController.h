//
//  NotificationSettingViewController.h
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import <UIKit/UIKit.h>

@interface NotificationSettingViewController : UIViewController {

}
@property (strong, nonatomic) IBOutlet UILabel *startTime;
@property (strong, nonatomic) IBOutlet UILabel *endTime;
@property (strong, nonatomic) IBOutlet UIDatePicker *dateTimePicker;
@property (strong, nonatomic) IBOutlet UISwitch * whetherSwitch;

- (IBAction)cancelClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
- (IBAction)valueChanged:(id)sender;
- (IBAction)switchChanged:(id)sender;


@end
