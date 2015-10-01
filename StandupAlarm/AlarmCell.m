//
//  AlarmCell.m
//  StandupAlarm
//
//  Created by Albert Li on 5/3/13.
//
//

#import "AlarmCell.h"
#import "CountingEngine.h"
#import <QuartzCore/QuartzCore.h>

@implementation AlarmCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    [[UIImage imageNamed:@"alarmcellbg.png"] drawInRect:self.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    
    [self.lblAlarmTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.lblAlarmTime.font.pointSize]];
    [self.lblAlarmRepeat setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.lblAlarmRepeat.font.pointSize]];
    [self.lblAlarmExercise setFont:[UIFont fontWithName:@"HelveticaNeue" size:self.lblAlarmExercise.font.pointSize]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.showingDeleteConfirmation && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
                CGRect frame = subview.frame;
                frame.origin.x -= 40;
                subview.frame = frame;
                subview.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
            }
        }
    }
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
    [super didTransitionToState:state];

    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        self.editingAccessoryView.backgroundColor = [UIColor redColor];
        [self.editingAccessoryView setFrame:CGRectMake(0, 0, 119, 68)];
        self.editingAccessoryView = nil;
    }
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setSelected:highlighted animated:animated];
    
    // Configure the view for the selected state
    if (highlighted) {
        [self.lblAlarmTime setDrawOutline:NO];
        [self.lblAlarmRepeat setDrawOutline:NO];
        [self.lblAlarmExercise setDrawOutline:NO];
    } else {
        [self.lblAlarmTime setDrawOutline:YES];
        [self.lblAlarmRepeat setDrawOutline:YES];
        [self.lblAlarmExercise setDrawOutline:YES];
    }
}

- (void)setAlarmTime:(NSDate*)time
{
    [self.lblAlarmTime setText:[AlarmCell formatAlarmTime:time]];
}

- (void)setAlarmRepeat:(int)repeat
{
    [self.lblAlarmRepeat setText:[AlarmCell formatAlarmRepeat:repeat]];
}

- (void)setAlarmExercise:(int)exercise
{
    [self.lblAlarmExercise setText:[AlarmCell formatAlarmExercise:exercise]];
}

+ (NSString*)formatAlarmTime:(NSDate*)time
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    NSString *ret = [timeFormatter stringFromDate:time];
    NSString *suf = [ret substringFromIndex:ret.length - 2];
    ret = [ret substringToIndex:ret.length-2];
    if ([suf isEqualToString:@"AM"] || [suf isEqualToString:@"am"]) {
        ret = [ret stringByAppendingString:@"am"];
    }
    else{
        ret = [ret stringByAppendingString:@"pm"];
    }
    return ret;
}

+ (NSString*)formatAlarmRepeat:(int)repeat
{
    NSMutableString* msg = [NSMutableString stringWithCapacity:30];
    NSArray* shortWeekdays = @[@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"];
    NSArray* longWeekdays  = @[@"Monday", @"Tuesday", @"Wednesday", @"Thuesday", @"Friday", @"Saturday", @"Sunday"];
    
    if (repeat == 0)
        [msg setString:@"Never"];
    else if (repeat == 31)
        [msg setString:@"Weekdays"];
    else if (repeat == 96)
        [msg setString:@"Weekends"];
    else if (repeat == 127)
        [msg setString:@"Every day"];
    else if (log2(repeat) == (int)log2(repeat)) {
        [msg setString:@"Every "];
        [msg appendString:[longWeekdays objectAtIndex:(int)log2(repeat)]];
    } else {
        for (int i = 0; i < 7; i++) {
            if ((repeat & (1 << i)) > 0) {
                if ([msg length] > 0)
                    [msg appendString:@","];
                [msg appendString:[shortWeekdays objectAtIndex:i]];
            }
        }
    }

    return msg;
}

+ (NSString*)formatAlarmExercise:(int)exercise
{
    if (exercise == 0)
        return @"Randomly";
    
    int group = exercise / 1000 - 1;
    int index = exercise % 1000;
    NSDictionary *action = [[CountingEngine getInstance] actionAtIndex:index group:group];
    return [action objectForKey:@"actionTitle"];
}

@end
