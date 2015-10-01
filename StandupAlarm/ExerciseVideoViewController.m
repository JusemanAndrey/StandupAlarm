//
//  ExerciseVideoViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExerciseVideoViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <AVFoundation/AVAudioSession.h>
#import "CountingEngine.h"
#import "Config.h"
#import <QuartzCore/QuartzCore.h>

@implementation ExerciseVideoViewController
{
    NSDate* startTime;
    NSTimer* ledIndicatorTimer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)popViewController:(UIButton*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:self.navigationItem.title];
    titleLabel.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1.0);
    [self.view addSubview:titleLabel];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [backButton setFrame:CGRectMake(20, 18, 119, 72)];
        [titleLabel setFrame:CGRectMake(0, 0, 768, 107)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:72]];
    } else {
        [backButton setFrame:CGRectMake(5, 12, 26, 20)];
        [titleLabel setFrame:CGRectMake(0, 0, 320, 45)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:30]];
    }

    [self loadExerciseData];

    startTime = [NSDate date];
    ledIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(updateLedIndicator) userInfo:nil repeats:YES];
    
#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2,
                                                                  self.view.frame.size.height - adSize.height,
                                                                  adSize.width,
                                                                  adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)viewDidUnload
{
    [ledIndicatorTimer invalidate];
    ledIndicatorTimer = nil;

    [self setCountingClock:nil];
    [self setLedIndicator:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setActionByIndex:(int)index group:(int)group
{
    currentIndex = index;
    currentGroup = group;
}

- (IBAction)replayVideo:(id)sender {
    [mpc setCurrentPlaybackTime:0];
    [mpc play];
}

- (void)viewControllerDidBecomeActive
{
    [mpc play];
}

- (void)loadExerciseData
{
    NSDictionary* action = [[CountingEngine getInstance] actionAtIndex:currentIndex group:currentGroup];
    
    [self setTitle:[action objectForKey:@"actionTitle"]];
    
    // path for video
    NSString *path = [[NSBundle mainBundle] pathForResource:[@"data" stringByAppendingPathComponent:[action objectForKey:@"actionFile"]] ofType:@"mp4"];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    // create movie player
    mpc = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [mpc setControlStyle:MPMovieControlStyleNone];
    [mpc setScalingMode:MPMovieScalingModeFill];
    [mpc setUseApplicationAudioSession:YES];
    [mpc prepareToPlay];
    
    [mpc.view setFrame:[self.videoRegion bounds]];
    [self.videoRegion addSubview:mpc.view];
    
    [mpc play];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mpc];
}

- (void)playbackDidFinish:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo]; // Check the finish reson
    if ([[userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] != MPMovieFinishReasonUserExited) {
        NSDictionary* action = [[CountingEngine getInstance] actionAtIndex:currentIndex group:currentGroup];
        [mpc setCurrentPlaybackTime:[[action objectForKey:@"pauseTime"] intValue]];
    }
}

- (void)updateLedIndicator
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* now = [NSDate date];
    NSDateComponents* comps = [calendar components:NSSecondCalendarUnit fromDate:startTime toDate:now options:0];
    int passSeconds = comps.second;
    
    [self.ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", passSeconds / 60, passSeconds % 60]];

    float prog = mpc.currentPlaybackTime / mpc.playableDuration;
    if (prog > 1)
        prog = 1;
    if (mpc.playbackState != MPMoviePlaybackStatePlaying)
        prog = 1;
    
    [self.countingClock setProgressValue:prog];
    [self.countingClock setNeedsDisplay];
}

@end
