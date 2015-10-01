//
//  MapAnnotation.h
//  StandupAlarm
//
//  Created by maxim on 3/27/15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *title1;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)title andCoordinate: (CLLocationCoordinate2D)coordinate2d;
@end
