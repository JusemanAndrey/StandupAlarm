//
//  ReplaceSegue.m
//  StandupAlarm
//
//  Created by Apple Fan on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReplaceSegue.h"

@implementation ReplaceSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    UINavigationController *nvc = src.navigationController;
    
    [UIView transitionWithView:nvc.view duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if ([[nvc viewControllers] count] > 1) {
                            [nvc popViewControllerAnimated:NO];
                            [nvc pushViewController:dst animated:NO];
                        } else {
                            [nvc setViewControllers:[NSArray arrayWithObject:dst] animated:NO];
                        }
                    }
                    completion:NULL];
}

@end
