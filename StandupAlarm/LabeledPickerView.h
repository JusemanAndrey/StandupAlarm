//
//  LabeledPickerView.h
//  StandupAlarm
//
//  Created by h on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 A picker view with labels under the selection indicator.
 Similar to the one in the timer tab in the Clock app.
 NB: has only been tested with less than four wheels. 
 */
@interface LabeledPickerView : UIPickerView {
	NSMutableDictionary *labels;
}

/** Adds the label for the given component. */
- (void) addLabel:(NSString *)labeltext forComponent:(NSUInteger)component forLongestString:(NSString *)longestString;
- (void) updateLabel:(NSString *)labeltext forComponent:(NSUInteger)component;

@end