#import "KSLabel.h"

@implementation KSLabel

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (void)awakeFromNib {
    [self setDrawOutline:YES];
    [self setOutlineColor:[UIColor whiteColor]];
}

-(void) setGradientColors: (CGFloat [8]) colors {
	memcpy(gradientColors, colors, 8 * sizeof (CGFloat));
}

- (void)drawTextInRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();  
	
	CGContextSaveGState(context);
	CGContextSetTextDrawingMode(context, kCGTextFill);    
	
	// Draw the text without an outline
	[super drawTextInRect:rect];
	
	CGImageRef alphaMask = NULL;
	
	if ([self drawGradient]) {
		// Create a mask from the text
		alphaMask = CGBitmapContextCreateImage(context);
		
		// clear the image
		CGContextClearRect(context, rect);
		
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, 0, rect.size.height);
		
		// invert everything because CoreGraphics works with an inverted coordinate system
		CGContextScaleCTM(context, 1.0, -1.0);
		
		// Clip the current context to our alphaMask
		CGContextClipToMask(context, rect, alphaMask);
		
		CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, gradientColors, NULL, 2);
		CGColorSpaceRelease(baseSpace), baseSpace = NULL;
		
		CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
		CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
		
		// Draw the gradient
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
		CGGradientRelease(gradient), gradient = NULL;
		CGContextRestoreGState(context);

		// Clean up because ARC doesnt handle CG
		CGImageRelease(alphaMask);
	}
	
	if ([self drawOutline]) {
		// Create a mask from the text (with the gradient)
		alphaMask = CGBitmapContextCreateImage(context);
		
		// Outline width
		CGContextSetLineWidth(context, 4);
		CGContextSetLineJoin(context, kCGLineJoinRound);
		
		// Set the drawing method to stroke
		CGContextSetTextDrawingMode(context, kCGTextStroke);
		
		// Outline color
		UIColor *tmpColor = self.textColor;
		self.textColor = [self outlineColor];
		
		// notice the +1 for the y-coordinate. this is to account for the face that the outline appears to be thicker on top
		[super drawTextInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
		
		// Draw the saved image over the outline
		// and invert everything because CoreGraphics works with an inverted coordinate system
		CGContextTranslateCTM(context, 0, rect.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextDrawImage(context, rect, alphaMask);
		
		// Clean up because ARC doesnt handle CG
		CGImageRelease(alphaMask);
		
		// restore the original color
		self.textColor = tmpColor;
	}
}
@end
