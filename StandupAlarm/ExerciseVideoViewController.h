//
//  ExerciseVideoViewController.h
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GADBannerView.h"
#import "CountingClockView.h"

@interface ExerciseVideoViewController : UIViewController
{
    MPMoviePlayerController *mpc;
    GADBannerView *bannerView_;
    
    int currentGroup;
    int currentIndex;
}

@property (nonatomic, weak) IBOutlet UIView* videoRegion;
@property (weak, nonatomic) IBOutlet CountingClockView *countingClock;
@property (weak, nonatomic) IBOutlet UILabel *ledIndicator;

- (void) setActionByIndex:(int)index group:(int)group;

- (IBAction)replayVideo:(id)sender;

- (void)viewControllerDidBecomeActive;

- (void)loadExerciseData;

- (void)playbackDidFinish:(NSNotification *)notification;

@end
