//
//  ExerciseVideoListViewController.h
//  StandupAlarm
//
//  Created by Apple Fan on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface ExerciseVideoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
    GADBannerView *bannerView_;
}

@property(nonatomic, strong) IBOutlet UITableView *actionListTableView;

@end
