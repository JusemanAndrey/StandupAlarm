#import "PCLineChartView.h"

extern BOOL bTracker;

@implementation PCLineChartViewComponent

- (id)init
{
    self = [super init];
    if (self)
    {
        _labelFormat = @"%.1f%%";
    }
    return self;
}

@end

@implementation PCLineChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        if (bTracker) {//counts chart
            _interval = 5;
            _maxValue = 20;
            _minValue = 0;
            _yLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
            _xLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
            _valueLabelFont = [UIFont boldSystemFontOfSize:10];
            _legendFont = [UIFont boldSystemFontOfSize:10];
            _numYIntervals = 4;
            _numXIntervals = 1;
        }
        else{//calories chart
            _interval = 20;
            _maxValue = 240;
            _minValue = 0;
            _yLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
            _xLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:12];
            _valueLabelFont = [UIFont boldSystemFontOfSize:10];
            _legendFont = [UIFont boldSystemFontOfSize:10];
            _numYIntervals = 5;
            _numXIntervals = 1;
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    int n_div;
    int power = 0;
    float scale_min, scale_max, div_height;
    float top_margin = 10;
    float bottom_margin = 25;
    float x_label_height = 20;
    
    if (bTracker) {//count
        if (self.autoscaleYAxis) {
            scale_min = 0.0;
            power = floor(log10(self.maxValue/4));
            float increment = self.maxValue / (4 * pow(10,power));
            increment = (increment <= 4) ? ceil(increment) : 10;
            increment = increment * pow(10,power);
            scale_max = 4 * increment;
            self.interval = scale_max / self.numYIntervals;
        } else {
            scale_min = self.minValue;
            scale_max = self.maxValue;
        }
        n_div = (scale_max-scale_min)/self.interval + 1;
        div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
        
        //maxim
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByCharWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        // y axis 20 and lines
        for (int i=0; i<n_div; i++)
        {
            float y_axis = scale_max - i*self.interval;
            int y = top_margin + div_height*i;
            CGRect textFrame = CGRectMake(0,y-8,25,20);
            NSString *formatString = [NSString stringWithFormat:@"%%.%df", (power < 0) ? -power : 0];
            NSString *text = [NSString stringWithFormat:formatString, y_axis];
            [text drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.yLabelFont, NSForegroundColorAttributeName:PCColorWhite, NSParagraphStyleAttributeName:textStyle}];
        }
        CGContextSetLineWidth(ctx, 0.5);
        CGContextSetRGBStrokeColor(ctx, 38.0/255.0f, 198.0/255.0f, 1.0f, 1.0f);
        CGContextMoveToPoint(ctx, 0, 1);
        CGContextAddLineToPoint(ctx, self.frame.size.width-10, 1);
        CGContextStrokePath(ctx);
        CGContextMoveToPoint(ctx, 0, self.frame.size.height-25);
        CGContextAddLineToPoint(ctx, self.frame.size.width-10, self.frame.size.height-25);
        CGContextStrokePath(ctx);
        
        float margin = 45;
        float div_width;
        if ([self.xLabels count] == 1)
        {
            div_width = 0;
        }
        else
        {
            div_width = (self.frame.size.width-2*margin)/([self.xLabels count]-1);
        }
        
        for (NSUInteger i=0; i<[self.xLabels count]; i++)
        {
            if (i % self.numXIntervals == 1 || self.numXIntervals==1) {
                int x = (int) (margin + div_width * i);
                NSString *x_label = [NSString stringWithFormat:@"%@", [self.xLabels objectAtIndex:i]];
                CGRect textFrame = CGRectMake(x - 100, self.frame.size.height - x_label_height, 200, x_label_height);
                [x_label drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.xLabelFont, NSForegroundColorAttributeName:PCColorCustom, NSParagraphStyleAttributeName:textStyle}];
            }
            
        }
        CGColorRef shadowColor = [[UIColor darkGrayColor] CGColor];
        CGContextSetShadowWithColor(ctx, CGSizeMake(0,-1), 1, shadowColor);
        
        NSMutableArray *legends = [NSMutableArray array];
        
        float circle_diameter = 5;
        float circle_stroke_width = 3;
        float line_width = 3;
        
        for (PCLineChartViewComponent *component in self.components)
        {
            int last_x = 0;
            int last_y = 0;
            if (!component.colour)
            {
                component.colour = PCColorBlue;
            }
            
            for (int x_axis_index=0; x_axis_index<[component.points count]; x_axis_index++)
            {
                id object = [component.points objectAtIndex:x_axis_index];
                if (object!=[NSNull null] && object)
                {
                    float value = [object floatValue];
                    CGContextSetStrokeColorWithColor(ctx, [component.colour CGColor]);
                    CGContextSetLineWidth(ctx, circle_stroke_width);
                    int x = margin + div_width*x_axis_index;
                    int y = top_margin + (scale_max-value)/self.interval*div_height;
                    CGRect circleRect = CGRectMake(x-circle_diameter/2, y-circle_diameter/2, circle_diameter,circle_diameter);
                    CGContextStrokeEllipseInRect(ctx, circleRect);
                    CGContextSetFillColorWithColor(ctx, [component.colour CGColor]);
                    if (last_x!=0 && last_y!=0)
                    {
                        float distance = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) );
                        float last_x1 = last_x + (circle_diameter/2) / distance * (x-last_x);
                        float last_y1 = last_y + (circle_diameter/2) / distance * (y-last_y);
                        float x1 = x - (circle_diameter/2) / distance * (x-last_x);
                        float y1 = y - (circle_diameter/2) / distance * (y-last_y);
                        CGContextSetLineWidth(ctx, line_width);
                        CGContextMoveToPoint(ctx, last_x1, last_y1);
                        CGContextAddLineToPoint(ctx, x1, y1);
                        CGContextStrokePath(ctx);
                    }
                    
                    if (x_axis_index==[component.points count]-1)
                    {
                        NSMutableDictionary *info = [NSMutableDictionary dictionary];
                        if (component.title)
                        {
                            [info setObject:component.title forKey:@"title"];
                        }
                        [info setObject:[NSNumber numberWithFloat:x+circle_diameter/2+15] forKey:@"x"];
                        [info setObject:[NSNumber numberWithFloat:y-10] forKey:@"y"];
                        [info setObject:component.colour forKey:@"colour"];
                        [legends addObject:info];
                    }
                    last_x = x;
                    last_y = y;
                }
                
            }
        }
        
        for (int i=0; i<[self.xLabels count]; i++) //on axis present value.
        {
            int y_level = top_margin;
            
            for (int j=0; j<[self.components count]; j++)
            {
                NSArray *items = [[self.components objectAtIndex:j] points];
                id object = [items objectAtIndex:i];
                if (object!=[NSNull null] && object)
                {
                    float value = [object floatValue];
                    int x = margin + div_width*i;
                    int y = top_margin + (scale_max-value)/self.interval*div_height;
                    int y1 = y - circle_diameter/2 - self.valueLabelFont.pointSize;
                    int y2 = y + circle_diameter/2;
                    
                    if ([[self.components objectAtIndex:j] shouldLabelValues]) {
                        if (y1 > y_level)
                        {
                            //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
                            CGContextSetRGBFillColor(ctx, 255.0f, 255.0f, 255.0f, 1.0f);
                            NSString *perc_label = [NSString stringWithFormat:[[self.components objectAtIndex:j] labelFormat], value];
                            CGRect textFrame = CGRectMake(x-25,y1, 50,20);
                            [perc_label drawInRect:textFrame withFont:self.valueLabelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                            y_level = y1 + 20;
                        }
                        else // if (y2 < y_level+20 && y2 < self.frame.size.height-top_margin-bottom_margin)
                        {
                            //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
                            CGContextSetRGBFillColor(ctx, 255.0f, 255.0f, 255.0f, 1.0f);
                            NSString *perc_label = [NSString stringWithFormat:[[self.components objectAtIndex:j] labelFormat], value];
                            CGRect textFrame = CGRectMake(x-25,y2, 50,20);
                            [perc_label drawInRect:textFrame withFont:self.valueLabelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                            y_level = y2 + 20;
                        }
                    }
                    if (y+circle_diameter/2>y_level) y_level = y+circle_diameter/2;
                }
                
            }
        }
        
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES];
        [legends sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        
        //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
        float y_level = 0;
        for (NSMutableDictionary *legend in legends)
        {
            UIColor *colour = [legend objectForKey:@"colour"];
            CGContextSetFillColorWithColor(ctx, [colour CGColor]);
            
            NSString *title = [legend objectForKey:@"title"];
            float x = [[legend objectForKey:@"x"] floatValue];
            float y = [[legend objectForKey:@"y"] floatValue];
            if (y<y_level)
            {
                y = y_level;
            }
            
            CGRect textFrame = CGRectMake(x,y,margin,15);
            [title drawInRect:textFrame withFont:self.legendFont];
            
            y_level = y + 15;
        }
    }
    else{//calories
        if (self.autoscaleYAxis) {
            scale_min = 0.0;
            power = floor(log10(self.maxValue/5));
            float increment = self.maxValue / (5 * pow(10,power));
            increment = (increment <= 5) ? ceil(increment) : 10;
            increment = increment * pow(10,power);
            scale_max = 5 * increment;
            self.interval = scale_max / self.numYIntervals;
        } else {
            scale_min = self.minValue;
            scale_max = self.maxValue;
        }
        n_div = (scale_max-scale_min)/self.interval + 1;
        div_height = (self.frame.size.height-top_margin-bottom_margin-x_label_height)/(n_div-1);
        
        //maxim
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByCharWrapping;
        textStyle.alignment = NSTextAlignmentCenter;
        // y axis 240 and lines
        for (int i=0; i<n_div; i++)
        {
            float y_axis = scale_max - i*self.interval;
            int y = top_margin + div_height*i;
            CGRect textFrame = CGRectMake(0,y-8,25,20);
            NSString *formatString = [NSString stringWithFormat:@"%%.%df", (power < 0) ? -power : 0];
            NSString *text = [NSString stringWithFormat:formatString, y_axis];
            [text drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.yLabelFont, NSForegroundColorAttributeName:PCColorWhite, NSParagraphStyleAttributeName:textStyle}];
        }
        CGContextSetLineWidth(ctx, 0.5);
        CGContextSetRGBStrokeColor(ctx, 38.0/255.0f, 198.0/255.0f, 1.0f, 1.0f);
        CGContextMoveToPoint(ctx, 0, 1);
        CGContextAddLineToPoint(ctx, self.frame.size.width-10, 1);
        CGContextStrokePath(ctx);
        CGContextMoveToPoint(ctx, 0, self.frame.size.height-25);
        CGContextAddLineToPoint(ctx, self.frame.size.width-10, self.frame.size.height-25);
        CGContextStrokePath(ctx);
        
        float margin = 45;
        float div_width;
        if ([self.xLabels count] == 1)
        {
            div_width = 0;
        }
        else
        {
            div_width = (self.frame.size.width-2*margin)/([self.xLabels count]-1);
        }
        
        for (NSUInteger i=0; i<[self.xLabels count]; i++)
        {
            if (i % self.numXIntervals == 1 || self.numXIntervals==1) {
                int x = (int) (margin + div_width * i);
                NSString *x_label = [NSString stringWithFormat:@"%@", [self.xLabels objectAtIndex:i]];
                CGRect textFrame = CGRectMake(x - 100, self.frame.size.height - x_label_height, 200, x_label_height);
                [x_label drawInRect:textFrame withAttributes:@{NSFontAttributeName:self.xLabelFont, NSForegroundColorAttributeName:PCColorCustom, NSParagraphStyleAttributeName:textStyle}];
                //[x_label drawInRect:textFrame withFont:self.xLabelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
            }
            
        }
        CGColorRef shadowColor = [[UIColor darkGrayColor] CGColor];
        CGContextSetShadowWithColor(ctx, CGSizeMake(0,-1), 1, shadowColor);
        
        NSMutableArray *legends = [NSMutableArray array];
        
        float circle_diameter = 5;
        float circle_stroke_width = 3;
        float line_width = 3;
        
        for (PCLineChartViewComponent *component in self.components)
        {
            int last_x = 0;
            int last_y = 0;
            if (!component.colour)
            {
                component.colour = PCColorBlue;
            }
            
            for (int x_axis_index=0; x_axis_index<[component.points count]; x_axis_index++)
            {
                id object = [component.points objectAtIndex:x_axis_index];
                if (object!=[NSNull null] && object)
                {
                    float value = [object floatValue];
                    CGContextSetStrokeColorWithColor(ctx, [component.colour CGColor]);
                    CGContextSetLineWidth(ctx, circle_stroke_width);
                    int x = margin + div_width*x_axis_index;
                    int y = top_margin + (scale_max-value)/self.interval*div_height;
                    CGRect circleRect = CGRectMake(x-circle_diameter/2, y-circle_diameter/2, circle_diameter,circle_diameter);
                    CGContextStrokeEllipseInRect(ctx, circleRect);
                    CGContextSetFillColorWithColor(ctx, [component.colour CGColor]);
                    if (last_x!=0 && last_y!=0)
                    {
                        float distance = sqrt( pow(x-last_x, 2) + pow(y-last_y,2) );
                        float last_x1 = last_x + (circle_diameter/2) / distance * (x-last_x);
                        float last_y1 = last_y + (circle_diameter/2) / distance * (y-last_y);
                        float x1 = x - (circle_diameter/2) / distance * (x-last_x);
                        float y1 = y - (circle_diameter/2) / distance * (y-last_y);
                        CGContextSetLineWidth(ctx, line_width);
                        CGContextMoveToPoint(ctx, last_x1, last_y1);
                        CGContextAddLineToPoint(ctx, x1, y1);
                        CGContextStrokePath(ctx);
                    }
                    
                    if (x_axis_index==[component.points count]-1)
                    {
                        NSMutableDictionary *info = [NSMutableDictionary dictionary];
                        if (component.title)
                        {
                            [info setObject:component.title forKey:@"title"];
                        }
                        [info setObject:[NSNumber numberWithFloat:x+circle_diameter/2+15] forKey:@"x"];
                        [info setObject:[NSNumber numberWithFloat:y-10] forKey:@"y"];
                        [info setObject:component.colour forKey:@"colour"];
                        [legends addObject:info];
                    }
                    last_x = x;
                    last_y = y;
                }
                
            }
        }
        
        for (int i=0; i<[self.xLabels count]; i++) //on axis present value.
        {
            int y_level = top_margin;
            
            for (int j=0; j<[self.components count]; j++)
            {
                NSArray *items = [[self.components objectAtIndex:j] points];
                id object = [items objectAtIndex:i];
                if (object!=[NSNull null] && object)
                {
                    float value = [object floatValue];
                    int x = margin + div_width*i;
                    int y = top_margin + (scale_max-value)/self.interval*div_height;
                    int y1 = y - circle_diameter/2 - self.valueLabelFont.pointSize;
                    int y2 = y + circle_diameter/2;
                    
                    if ([[self.components objectAtIndex:j] shouldLabelValues]) {
                        if (y1 > y_level)
                        {
                            //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
                            CGContextSetRGBFillColor(ctx, 255.0f, 255.0f, 255.0f, 1.0f);
                            NSString *perc_label = [NSString stringWithFormat:[[self.components objectAtIndex:j] labelFormat], value];
                            CGRect textFrame = CGRectMake(x-25,y1, 50,20);
                            [perc_label drawInRect:textFrame withFont:self.valueLabelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                            y_level = y1 + 20;
                        }
                        else // if (y2 < y_level+20 && y2 < self.frame.size.height-top_margin-bottom_margin)
                        {
                            //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
                            CGContextSetRGBFillColor(ctx, 255.0f, 255.0f, 255.0f, 1.0f);
                            NSString *perc_label = [NSString stringWithFormat:[[self.components objectAtIndex:j] labelFormat], value];
                            CGRect textFrame = CGRectMake(x-25,y2, 50,20);
                            [perc_label drawInRect:textFrame withFont:self.valueLabelFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                            y_level = y2 + 20;
                        }
                    }
                    if (y+circle_diameter/2>y_level) y_level = y+circle_diameter/2;
                }
                
            }
        }
        
        NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES];
        [legends sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        
        //CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
        float y_level = 0;
        for (NSMutableDictionary *legend in legends)
        {
            UIColor *colour = [legend objectForKey:@"colour"];
            CGContextSetFillColorWithColor(ctx, [colour CGColor]);
            
            NSString *title = [legend objectForKey:@"title"];
            float x = [[legend objectForKey:@"x"] floatValue];
            float y = [[legend objectForKey:@"y"] floatValue];
            if (y<y_level)
            {
                y = y_level;
            }
            
            CGRect textFrame = CGRectMake(x,y,margin,15);
            [title drawInRect:textFrame withFont:self.legendFont];
            
            y_level = y + 15;
        }
    }
}


@end
