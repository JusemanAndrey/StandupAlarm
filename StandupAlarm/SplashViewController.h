//
//  SplashViewController.h
//  StandupAlarm
//
//  Created by Apple Fan on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController
{
    int currentFrame;
}

@property (nonatomic, weak) IBOutlet UIButton* nextSplashButton;

- (IBAction)nextSplash:(id)sender;

@end
