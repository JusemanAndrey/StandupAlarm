//
//  IntervalCell.h
//  StandupAlarm
//
//  Created by h on 8/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntervalCell : UITableViewCell {
    BOOL checked;
//    int health;
}

@property (nonatomic, weak) IBOutlet UIImageView* checkImage;
@property (nonatomic, weak) IBOutlet UILabel*     captionLabel;
//@property (nonatomic, weak) IBOutlet UIImageView* healthImage;

- (BOOL)checked;

- (void)setChecked:(BOOL)value;

- (NSString*)caption;

- (void)setCaption:(NSString*)value;

//- (int)health;

//- (void)setHealth:(int)value;

@end
