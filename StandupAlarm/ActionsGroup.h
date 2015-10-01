//
//  ActionsGroup.h
//  StandupAlarm
//
//  Created by Apple Fan on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionsGroup : NSObject
{
    NSMutableArray __strong *actionList;
}

@property (atomic, strong) NSString* title;

- (int)numberOfActions;

- (id)actionAtIndex:(int)index;

- (void)addAction:(id)action;

@end
