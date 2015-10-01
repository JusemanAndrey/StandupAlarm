#import <UIKit/UIKit.h>

@interface KSLabel : UILabel {
	CGFloat gradientColors[8];
}

@property BOOL drawOutline;
@property (strong, nonatomic) UIColor *outlineColor;

@property BOOL drawGradient;
-(void) setGradientColors: (CGFloat [8]) colors;
@end
