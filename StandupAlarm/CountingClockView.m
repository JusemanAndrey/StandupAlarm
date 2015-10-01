//
//  CountingClockView.m
//  StandupAlarm
//
//  Created by Apple Fan on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CountingClockView.h"

@implementation CountingClockView

@synthesize progressValue;

#define PI  3.14159265358979

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        progressValue = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // get current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set position and size
    int w = self.frame.size.width, h = self.frame.size.height;
    //int d = h / 8;
    int d = h / 12;
    CGRect rect1 = CGRectMake((w - h) / 2, 0, h, h);
    CGRect rect2 = CGRectMake((w - h) / 2 + d, d, h - d * 2, h - d * 2);
    
    // set color and fill background circle
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.71 green:0.85 blue:0.92 alpha:1.0].CGColor);
    CGContextAddEllipseInRect(context, rect1);
    CGContextAddEllipseInRect(context, rect2);
    CGContextEOFillPath(context);
    
    // progree circle
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.38 green:0.70 blue:0.86 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, w / 2, h);
    CGContextAddArc(context, w / 2, h / 2, h / 2, -PI / 2, -PI / 2 + 2 * PI * progressValue, 0);
    CGContextAddArc(context, w / 2, h / 2, h / 2 - d, -PI / 2 + 2 * PI * progressValue, -PI / 2, 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end
