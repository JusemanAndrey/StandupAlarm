//
//  CrossDissolvePushSegue.m
//  StandupAlarm
//
//  Created by Apple Fan on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossDissolvePushSegue.h"

@implementation CrossDissolvePushSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:src.navigationController.view duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}

@end
