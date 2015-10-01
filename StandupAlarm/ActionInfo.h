//
//  ActionInfo.h
//  StandupAlarm
//
//  Created by Apple Fan on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionInfo : NSObject

@property (atomic, assign) BOOL enabled;
@property (atomic, strong) NSString* title;
@property (atomic, strong) NSString* file;

@end
