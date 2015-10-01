//
//  MainMenuViewController.h
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

#define PATTERNSFILE @"patternsfile.txt"

@interface MainMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    GADBannerView *bannerView_;
    NSMutableArray* intervalList;
    int currentInterval;
}

@property (nonatomic, weak) IBOutlet UITableView* intervalTable;
@property (strong, nonatomic) IBOutlet UILabel *startTime;
@property (strong, nonatomic) IBOutlet UILabel *endTime;

- (IBAction)createButtonClicked:(id)sender;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)setInterval:(id)sender;

@end
