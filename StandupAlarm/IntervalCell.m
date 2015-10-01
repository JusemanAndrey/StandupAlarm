//
//  IntervalCell.m
//  StandupAlarm
//
//  Created by h on 8/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IntervalCell.h"

@implementation IntervalCell

@synthesize checkImage;
@synthesize captionLabel;
//@synthesize healthImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.checked = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    //captionLabel.font             = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 48.0 : 30.0];
    captionLabel.font             = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 48.0 : 20.0];
    captionLabel.textColor        = [UIColor colorWithRed:76.0 / 255 green:113.0 / 255 blue:148.0 / 255 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
//    if (selected)
//        [super setSelected:NO animated:animated];
}

- (BOOL)checked 
{
    return checked;
}

- (void)setChecked:(BOOL)value 
{    
    checked = value;
    if (value)
        [checkImage setImage:[UIImage imageNamed:@"checked.png"]];
    else 
        //[checkImage setImage:[UIImage imageNamed:@"unchecked.png"]];
        checkImage.image = nil;
}

- (NSString*)caption 
{
    return [captionLabel text];
}

- (void)setCaption:(NSString*)value 
{
    [captionLabel setText:value];
}

/*
- (int)health
{
    return health;
}

- (void)setHealth:(int)value 
{
    health = value;
//    NSString* imgName = [NSString stringWithFormat:@"health-indication-%d.png", value];
//    [healthImage setImage:[UIImage imageNamed:imgName]];
}
*/
@end
