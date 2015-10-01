//
//  StoreFlyerViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 10/21/12.
//
//

#import <UIKit/UIKit.h>

@class ExerciseViewController;

@interface StoreFlyerViewController : UIViewController

- (IBAction)visitStandAppStore:(id)sender;
- (IBAction)closeStoreFlyer:(id)sender;

@property (nonatomic, assign) BOOL playWhenResume;
@property (nonatomic, strong) ExerciseViewController* exerciseViewController;

@end
