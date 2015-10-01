//
//  AlarmCell.h
//  StandupAlarm
//
//  Created by Albert Li on 5/3/13.
//
//

#import <UIKit/UIKit.h>
#import "KSLabel.h"

@interface AlarmCell : UITableViewCell

@property (weak, nonatomic) IBOutlet KSLabel *lblAlarmTime;
@property (weak, nonatomic) IBOutlet KSLabel *lblAlarmRepeat;
@property (weak, nonatomic) IBOutlet KSLabel *lblAlarmExercise;

- (void)setAlarmTime:(NSDate*)time;

- (void)setAlarmRepeat:(int)repeat;

- (void)setAlarmExercise:(int)exercise;

+ (NSString*)formatAlarmTime:(NSDate*)time;

+ (NSString*)formatAlarmRepeat:(int)repeat;

+ (NSString*)formatAlarmExercise:(int)exercise;

@end
