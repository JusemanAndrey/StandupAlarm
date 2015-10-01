//
//  MapAnnotation.m
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import "MapAnnotation.h"

@implementation MapAnnotation

-(id)initWithTitle:(NSString *)title andCoordinate: (CLLocationCoordinate2D)coordinate2d{
    self.title1 = title;
    self.coordinate =coordinate2d; return self;
}
@end
