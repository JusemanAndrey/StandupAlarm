//
//  CustomIntervalViewController.h
//  StandupAlarm
//
//  Created by h on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "LabeledPickerView.h"

@interface CustomIntervalViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    GADBannerView *bannerView_;

    NSArray* intervalList;
}

@property (nonatomic, weak) IBOutlet LabeledPickerView* pickerView;

- (IBAction)startButtonClicked:(id)sender;

@end
