//
//  ProgressViewController.h
//  StandupAlarm
//
//  Created by Albert Li on 10/18/12.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "PCLineChartView.h"

@interface ProgressViewController : UIViewController
{
    GADBannerView *bannerView_;
}

@property (weak, nonatomic) IBOutlet UIView *lineChartContainer;
@property (nonatomic, strong) PCLineChartView *lineChartView;
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *breaksLabel;
@property (strong, nonatomic) IBOutlet UISwitch *caloAndBreakSwitch;
@property (strong, nonatomic) IBOutlet UIButton *weightButton;

- (void)loadProgressChart;
- (IBAction)shareOnFacebook:(id)sender;
- (IBAction)editUserWeight:(id)sender;
- (IBAction)valueChangedOfSwitch:(id)sender;

@end
