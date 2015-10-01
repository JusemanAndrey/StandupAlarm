//
//  ActionsGroup.m
//  StandupAlarm
//
//  Created by Apple Fan on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ActionsGroup.h"

@implementation ActionsGroup

@synthesize title;

- (id)init
{
    self = [super init];
    actionList = [[NSMutableArray alloc] init];
    
    return self;
}

- (int)numberOfActions
{
    return [actionList count];
}

- (id)actionAtIndex:(int)index
{
    return [actionList objectAtIndex:index];
}

- (void)addAction:(id)action
{
    [actionList addObject:action];
}

@end
