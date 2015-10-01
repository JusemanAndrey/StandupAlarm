//
//  ExerciseViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExerciseViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <AVFoundation/AVAudioSession.h>
#import "CountingEngine.h"
#import "CountingViewController.h"
#import "Config.h"

extern NSString *breakDuration;
extern int choseInterval;

@implementation ExerciseViewController

@synthesize videoRegion;

#ifdef USE_HTMLDESCRIPTION
@synthesize exerciseDescription;
#endif

@synthesize ledIndicator;
@synthesize countingClock;
@synthesize domoreButton;
@synthesize snoozeButton;
@synthesize snoozeProgress;

@synthesize videoProgress;
@synthesize videoNameLabel;
@synthesize centerButton;
@synthesize rightButton;
@synthesize leftButton;
@synthesize durationLabel;

NSString* const actionFolder = @"data";
int playTime, realTime, playBackTime;
BOOL isPlaying, willExercise = FALSE;
static int elapsedSeconds = 0;
static int stopSeconds = 0;

BOOL recorded = TRUE, newrecord = TRUE;
NSDate *enterDate;

static NSDate *rememberDate = nil;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    MPVolumeView *volumeViewSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(73, 358, 175, 31)];
//    [self.view addSubview:volumeViewSlider];
//    [volumeViewSlider sizeToFit];
    elapsedSeconds = 0;
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    videoProgress.transform = transform;
    realTime = 0;
    stopSeconds = 0;
    playTime = [breakDuration intValue] * 60;
    videoFileList = [[NSMutableArray alloc] init];
    durationList = [[NSMutableArray alloc] init];
    videoFileTitleList = [[NSMutableArray alloc] init];
    durationLabel.text = [breakDuration stringByAppendingString:@":00"];
    isPlaying = TRUE;
    [centerButton setImage:[UIImage imageNamed:@"pause_main.png"] forState:UIControlStateNormal];
    rememberDate = [NSDate date];
    videoTimer = [[NSTimer alloc] init];
    
    [self loadActionList];//my code    
    [self loadExerciseData];
    NSString *str = [durationList objectAtIndex:currentIndex];
    playBackTime = [[[str componentsSeparatedByString:@":"] objectAtIndex:0] intValue]*60 + [[[str componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    [ledIndicator setText:[[CountingEngine getInstance] getRemainingTimeString]];
    ledIndicator.font = [UIFont fontWithName:@"HelveticaNeue" size:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 40.0 : 25.0];
    ledIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(updateLedIndicator) userInfo:nil repeats:YES];

#if USE_ADMOB
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
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    [bannerView_ loadRequest:[GADRequest request]];
#endif
}

- (void)viewDidUnload
{
    [self stopExercise];
    [ledIndicatorTimer invalidate];
    ledIndicatorTimer = nil;
    [videoTimer invalidate];
    videoTimer = nil;

    self.storeFlyerViewController = nil;
    elapsedSeconds = 0;
    stopSeconds = 0;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [ledIndicator setText:[[CountingEngine getInstance] getRemainingTimeString]];
    if ([[CountingEngine getInstance] restartFlag]) {
        [[CountingEngine getInstance] setRestartFlag:NO];
        [self stopExercise];
        [self loadExerciseData];
    }
    //maxim add
    realTime = elapsedSeconds;
    elapsedSeconds = 0;
    
    enterDate = [NSDate date];
    int period = [enterDate timeIntervalSinceDate:rememberDate];
    if ( period > playTime ) {
        newrecord = TRUE;
        recorded = FALSE;
        rememberDate = enterDate;
    }
    else{
        if (newrecord){
            recorded = FALSE;
            rememberDate = enterDate;
        }
        else{
            recorded = TRUE;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSArray *tt = [[[CountingEngine getInstance] getRemainingTimeString] componentsSeparatedByString:@":"];
    int m = [[tt objectAtIndex:0] intValue]*60;
    int s = [[tt objectAtIndex:1] intValue];
    elapsedSeconds = playTime - m - s;
    if (!recorded) {
        [[CountingEngine getInstance] addCountsData:rememberDate];
        [[CountingEngine getInstance] saveCountsData];
        [[CountingEngine getInstance] calcCalories];
        [[CountingEngine getInstance] calcCaloriesSitting];
        [[CountingEngine getInstance] saveCaloriesData];
        recorded = TRUE;
        newrecord = TRUE;
    }
    rememberDate = [NSDate date];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)replayVideo:(id)sender {
    [self.mpc setCurrentPlaybackTime:0];
    [self.mpc play];
}

- (void)checkScheduleTimer
{
    if (![snoozeButton isSelected]) {
        CountingEngine* engine = [CountingEngine getInstance];
        
        if ([engine isReachedTarget] && (GETCURRENTTIME >= engine.targetTime + engine.nextTargetInterval)) {
            // update watch
#if !USE_TEST_TIME
            
            NSDictionary* action = [engine currentAction];
            int base = [breakDuration intValue], exerciseTime;
            if ( base < 1 || base > 15) {
                exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
            }
            else
                exerciseTime = base * 60;
            //int exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
            [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", exerciseTime / 60, exerciseTime % 60]];
#else
            [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", TEST_EXERCISE_TIME / 60, TEST_EXERCISE_TIME % 60]];
#endif            
            [countingClock setProgressValue:0];
            [countingClock setNeedsDisplay];
            
#if !USE_TEST_TIME
            if ( base < 1 || base > 15) {
                //[engine startCountingWithInterval:[[action objectForKey:@"actionTime"] intValue] * 60 scheduleType:1 resetInterval:NO];
            }
            else
                //[engine startCountingWithInterval:base * 60 scheduleType:1 resetInterval:NO];
#else
            //[engine startCountingWithInterval:TEST_EXERCISE_TIME scheduleType:1 resetInterval:NO];
#endif
            [self.mpc setCurrentPlaybackTime:0];
        }
    }
}

- (void)viewControllerDidBecomeActive
{
    [self.mpc play];
}

- (IBAction)clickDoMoreButton:(id)sender
{
    [self pauseExercise];
    
#ifdef FREEVERSION
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_Free_iPad" : @"MainStoryboard_Free_iPhone";
#else
    NSString* storyboardName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"MainStoryboard_iPad" : @"MainStoryboard_iPhone";
#endif
    if (isPhone568)
        storyboardName = [storyboardName stringByAppendingString:@"_568h"];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    self.storeFlyerViewController = (StoreFlyerViewController*)[storyboard instantiateViewControllerWithIdentifier:@"storeFlyerViewController"];
    self.storeFlyerViewController.exerciseViewController = self;
    self.storeFlyerViewController.playWhenResume = ([self.mpc playbackState] ==  MPMoviePlaybackStatePlaying);
    
    [self.mpc pause];
    [self.view addSubview:self.storeFlyerViewController.view];
}

- (IBAction)snoozeExcercise
{
    [snoozeButton setSelected:![snoozeButton isSelected]];
    
    CountingEngine* engine = [CountingEngine getInstance];
    if ([snoozeButton isSelected]) {
        [snoozeButton setImage:[UIImage imageNamed:@"unsnooze.png"] forState:UIControlStateNormal];
        [snoozeButton setImage:[UIImage imageNamed:@"unsnooze.png"] forState:UIControlStateHighlighted];
        
        [snoozeProgress setProgress:0];
        [snoozeProgress setHidden:NO];
        
        NSDictionary* action = [engine currentAction];
        int base = [breakDuration intValue], exerciseTime;
        // update watch
#if !USE_TEST_TIME
        if ( base < 1 || base > 15) {
            exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
        }
        else
            exerciseTime = base * 60;
        //int exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
        [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", exerciseTime / 60, exerciseTime % 60]];
#else
        [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", TEST_EXERCISE_TIME / 60, TEST_EXERCISE_TIME % 60]];
#endif
        [countingClock setProgressValue:0];
        [countingClock setNeedsDisplay];

#if !USE_TEST_TIME
        [engine startCountingWithInterval:SNOOZE_TIME scheduleType:2 resetInterval:NO];
#else
        [engine startCountingWithInterval:TEST_SNOOZE_TIME scheduleType:2 resetInterval:NO];
#endif
        
        [self.mpc setCurrentPlaybackTime:[[action objectForKey:@"pauseTime"] intValue]];
        [self.mpc pause];
    }
    else {
        [snoozeButton setImage:[UIImage imageNamed:@"snooze.png"] forState:UIControlStateNormal];
        [snoozeButton setImage:nil forState:UIControlStateHighlighted];
        
        [snoozeProgress setHidden:YES];
        
        [engine stopCounting];
        
        [self.mpc setCurrentPlaybackTime:0];
        [self.mpc play];
        
#if !USE_TEST_TIME
        int base = [breakDuration intValue], exerciseTime;
        if ( base < 1 || base > 15) {
            exerciseTime = [[[engine currentAction] objectForKey:@"actionTime"] intValue] * 60;
        }
        else
            exerciseTime = base * 60;
        
        //[engine startCountingWithInterval:exerciseTime scheduleType:1 resetInterval:NO];
#else
        //[engine startCountingWithInterval:TEST_EXERCISE_TIME scheduleType:1 resetInterval:NO];
#endif
    }
}

/////maxim////////////////////////////////////////////////////////////////////////////////
- (void)loadActionList
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"ActionList.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        plistPath = [[NSBundle mainBundle] pathForResource:@"ActionList" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    actionsGroupList = [NSPropertyListSerialization propertyListFromData:plistXML
                                                        mutabilityOption:NSPropertyListMutableContainers
                                                                  format:&format
                                                        errorDescription:&errorDesc];
    
    if (!actionsGroupList) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    BOOL flag = FALSE;
    for (currentGroup = 0; currentGroup < [actionsGroupList count]; currentGroup++) {
        NSDictionary* group = [actionsGroupList objectAtIndex:currentGroup];
        NSArray* actionList = [group objectForKey:@"actionList"];
        for (int i = 0; i < [actionList count]; i++) {
            if (![[actionList objectAtIndex:i] objectForKey:@"actionFile"]) {
                flag = TRUE;
                break;
            }
            [videoFileList addObject:[[actionList objectAtIndex:i] objectForKey:@"actionFile"]];
            [videoFileTitleList addObject:[[actionList objectAtIndex:i] objectForKey:@"actionTitle"]];
            [durationList addObject:[[actionList objectAtIndex:i] objectForKey:@"duration"]];
        }
        if (flag) {
            break;
        }
    }
}

- (void) changeProgress{
    realTime = realTime + 1;
    if (realTime >= playTime) {
        elapsedSeconds = 0;
        stopSeconds = 0;
        [self stopVideoTimer];
    }
    else {
        if (!isPlaying) {
            stopSeconds++;
        }
        if( (realTime - stopSeconds) % playBackTime == 0 ){
            NSString *str = [durationList objectAtIndex:currentIndex];
            playBackTime = [[[str componentsSeparatedByString:@":"] objectAtIndex:0] intValue]*60 + [[[str componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
            [centerButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            isPlaying = FALSE;
            //[self.mpc stop];
        }
        else{
            isPlaying = TRUE;
        }
    }
}

- (NSString *)getFileName:(int)index{
    return [videoFileList objectAtIndex:index];
}

- (IBAction)playClicked:(id)sender {//3 buttons click
    UIButton *btn = (UIButton *)sender;
    if (btn == rightButton){
        if (currentIndex == 29) {
            return;
        }
        currentIndex++;
        if ( currentIndex <= [videoFileList count] - 1 ) {
            [self setPlayControls:currentIndex];//init controls
            [self startPlay:currentIndex];
            isPlaying = TRUE;
            [centerButton setImage:[UIImage imageNamed:@"pause_main.png"] forState:UIControlStateNormal];
        }
    }
    else if( btn == leftButton ){//leftbutton
        if (currentIndex == 0) {
            return;
        }
        currentIndex--;
        if ( currentIndex >= 0 ) {
            [self setPlayControls:currentIndex];//init controls
            [self startPlay:currentIndex];
            isPlaying = TRUE;
            [centerButton setImage:[UIImage imageNamed:@"pause_main.png"] forState:UIControlStateNormal];
        }
    }
    else {
        if (isPlaying ){
            [centerButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            [self pausePlay];
        }
        else{
            [centerButton setImage:[UIImage imageNamed:@"pause_main.png"] forState:UIControlStateNormal];
            //[self startPlay:currentIndex];
            [self.mpc play];
        }
        isPlaying = !isPlaying;
    }
}

- (void)startVideoTimer{
    //realTime = elapsedSeconds;
    if ( ! videoTimer ) {
        videoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeProgress) userInfo:nil repeats:YES];
    }
}

- (void)stopVideoTimer{
    if ([videoTimer isValid]) {
        [videoTimer invalidate];
    }
    videoTimer = nil;
}

- (void)startPlay:(int)index{
    //if ( !isPlaying ) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[@"data" stringByAppendingPathComponent:[self getFileName:currentIndex]] ofType:@"mp4"];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [self.mpc setContentURL:[NSURL fileURLWithPath:path]];
        [self.mpc prepareToPlay];
        [self.mpc play];
        [self.mpc setCurrentPlaybackTime:0];
    //}
//    else {
//        NSString *str = [durationList objectAtIndex:currentIndex];
//        int playBackTime = [[[str componentsSeparatedByString:@":"] objectAtIndex:0] intValue]*60 + [[[str componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
//        [self.mpc prepareToPlay];
//        [self.mpc setCurrentPlaybackTime:realTime % playBackTime];
//        [self.mpc play];
//    }
}

- (void) pausePlay {
    [self.mpc pause];
}

- (void) setPlayControls:(int)index{
    currentIndex = index;
    self.videoNameLabel.text = [videoFileTitleList objectAtIndex:currentIndex];
    //NSString *str = [durationList objectAtIndex:currentIndex];
    //playTime = [[[str componentsSeparatedByString:@":"] objectAtIndex:0] intValue]*60 + [[[str componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    if (index < 1) {
        [leftButton setImage:[UIImage imageNamed:@"prev0.png"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"next1.png"] forState:UIControlStateNormal];
    }
    else if (index >= [videoFileList count] - 1){
        [leftButton setImage:[UIImage imageNamed:@"prev1.png"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"next0.png"] forState:UIControlStateNormal];
    }
    else{
        [leftButton setImage:[UIImage imageNamed:@"prev1.png"] forState:UIControlStateNormal];
        [rightButton setImage:[UIImage imageNamed:@"next1.png"] forState:UIControlStateNormal];
    }
}

////////////////////////////////////////////////////////////////////////////

- (void)loadExerciseData
{
    NSDictionary* action = [[CountingEngine getInstance] currentAction];
    //maxim add 4.4
    self.videoNameLabel.text = [action objectForKey:@"actionTitle"];
    currentIndex = [[CountingEngine getInstance] getCurrentIndex];
    [self setPlayControls:currentIndex];

#ifdef USE_HTMLDESCRIPTION  
    // show description
    NSString* htmlFile = [[NSBundle mainBundle] pathForResource:[@"data" stringByAppendingPathComponent:[action objectForKey:@"actionFile"]] ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [exerciseDescription loadHTMLString:htmlString baseURL:nil];
    
    for (id subview in exerciseDescription.subviews){
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]){
			((UIScrollView *)subview).bounces = NO;
        }
    }
#endif
    
#if !USE_TEST_TIME
    int base = [breakDuration intValue];
    if ( base < 1 || base > 15) {
        [[CountingEngine getInstance] startCountingWithInterval:[[action objectForKey:@"actionTime"] intValue] * 60 scheduleType:1 resetInterval:NO];
    }
    else
        [[CountingEngine getInstance] startCountingWithInterval:base * 60 scheduleType:1 resetInterval:NO];
#else
    [[CountingEngine getInstance] startCountingWithInterval:TEST_EXERCISE_TIME scheduleType:1 resetInterval:NO];
#endif
    // path for video
    NSString *path = [[NSBundle mainBundle] pathForResource:[@"data" stringByAppendingPathComponent:[action objectForKey:@"actionFile"]] ofType:@"mp4"];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // create movie player
    self.mpc = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [self.mpc setControlStyle:MPMovieControlStyleNone];
    [self.mpc setScalingMode:MPMovieScalingModeFill];
    [self.mpc setUseApplicationAudioSession:YES];
    [self.mpc prepareToPlay];
    [self.mpc.view setFrame:[videoRegion bounds]];
    [videoRegion addSubview:self.mpc.view];
    [self.mpc play];
    //maxim/////////////////////////////////
    [self startVideoTimer];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.mpc];
}

- (void)stopExercise
{
    [self.mpc stop];
    self.mpc = nil;
}

- (void)updateLedIndicator
{
    CountingEngine* engine = [CountingEngine getInstance];
    
    if (![snoozeButton isSelected]) {
        // check if is reached the target
        if ([engine isReachedTarget]) {
            // When clicking local notification to stand after time to back work .
            //maxim add
            //[engine calcCaloriesSitting];
            //[engine saveCaloriesData];
            if (GETCURRENTTIME >= engine.targetTime + engine.nextTargetInterval) {
                // select new exercise
                [engine setCurrentActionRandomly];
                NSDictionary *action = [engine currentAction];
                [action setValue:[NSNumber numberWithBool:NO] forKey:@"actionQueue"];
                if ([engine isEmeptyActionQueue]) {
                    [engine resetActionQueue];
                    [action setValue:[NSNumber numberWithBool:NO] forKey:@"actionQueue"];
                }
                [engine saveActionList];
                //maxim add
                int base = [breakDuration intValue];

                // update watch
#if !USE_TEST_TIME
                int exerciseTime;
                if ( base < 1 || base > 15) {
                    exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
                }
                else
                    exerciseTime = base * 60;
                //int exerciseTime = [[action objectForKey:@"actionTime"] intValue] * 60;
                [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", exerciseTime / 60, exerciseTime % 60]];
#else
                [ledIndicator setText:[NSString stringWithFormat:@"%02d:%02d", TEST_EXERCISE_TIME / 60, TEST_EXERCISE_TIME % 60]];
#endif
                [countingClock setProgressValue:0];
                [countingClock setNeedsDisplay];
                
#if !USE_TEST_TIME
                if ( base < 1 || base > 15) {
                    //[engine startCountingWithInterval:[[action objectForKey:@"actionTime"] intValue] * 60 scheduleType:1 resetInterval:NO];
                }
                else{
                   // [engine startCountingWithInterval:base * 60 scheduleType:1 resetInterval:NO];
                }
#else
                //[engine startCountingWithInterval:TEST_EXERCISE_TIME scheduleType:1 resetInterval:NO];
#endif
                
                // path for video
                NSString *path = [[NSBundle mainBundle] pathForResource:[@"data" stringByAppendingPathComponent:[action objectForKey:@"actionFile"]] ofType:@"mp4"];
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                
                // create movie player
                [self.mpc setContentURL:[NSURL fileURLWithPath:path]];
                [self.mpc prepareToPlay];
                [self.mpc play];
                [self.mpc setCurrentPlaybackTime:0];
            }
            else
            {
                isActive = NO;
                elapsedSeconds = 0;
                stopSeconds = 0;
                [self stopExercise];
                [ledIndicatorTimer invalidate];
                ledIndicatorTimer = nil;
                [engine stopCounting];
                [engine setAdCounter:[engine adCounter] + 1];                
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                if ([allViewControllers count] > 1 && self.scheduledExercise) {
                    UIViewController *popViewCtrl = [allViewControllers objectAtIndex:[allViewControllers count] - 2];
                    if ([popViewCtrl isKindOfClass:[CountingViewController class]]) {// CountingViewController
                        [engine startCountingWithInterval:choseInterval * 60 scheduleType:2 resetInterval:YES];
                    }
                    else{
                        for (int i = [allViewControllers count] - 2; i < 0; i--) {
                            UIViewController *rep = [allViewControllers objectAtIndex:i];
                            if ([rep isKindOfClass:[ExerciseViewController class]]) {
                                [allViewControllers removeObjectIdenticalTo:popViewCtrl];
                                self.navigationController.viewControllers = allViewControllers;
                            }
                        }
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    //[engine stopCounting];
                    [self performSegueWithIdentifier:@"exerciseToInterval" sender:self];
                }
            }
        }
        else {
            // update watch
            [ledIndicator setText:[engine getRemainingTimeString]];
            [countingClock setProgressValue:[engine getPassRate]];
            [countingClock setNeedsDisplay];
            //Maxim
            NSArray *tt = [[engine getRemainingTimeString] componentsSeparatedByString:@":"];
            int m = [[tt objectAtIndex:0] intValue]*60;
            int s = [[tt objectAtIndex:1] intValue];
            [self.videoProgress setProgress:(float)(playTime - m - s)/playTime animated:YES];
            int val = m + s;
            if( val % 60 < 10)
                durationLabel.text = [NSString stringWithFormat:@"%i:0%i",val/60, val%60];
            else
                durationLabel.text = [NSString stringWithFormat:@"%i:%i",val/60, val%60];
        }
    }
    else
    {
        // check if snooze time is riched.
        if ([engine isReachedTarget]) {
            [snoozeButton setSelected:NO];
            
            [snoozeButton setImage:[UIImage imageNamed:@"snooze.png"] forState:UIControlStateNormal];
            [snoozeButton setImage:nil forState:UIControlStateHighlighted];
            
            [snoozeProgress setHidden:YES];
            
            [engine stopCounting];
            
            [self.mpc setCurrentPlaybackTime:0];
            [self.mpc play];
            
#if !USE_TEST_TIME
            int base = [breakDuration intValue], exerciseTime;
            if ( base < 1 || base > 15) {
                exerciseTime = [[[engine currentAction] objectForKey:@"actionTime"] intValue] * 60;
            }
            else
                exerciseTime = base * 60;
            //int exerciseTime = [[[engine currentAction] objectForKey:@"actionTime"] intValue] * 60;
            //[engine startCountingWithInterval:exerciseTime scheduleType:1 resetInterval:NO];
#else
            //[engine startCountingWithInterval:TEST_EXERCISE_TIME scheduleType:1 resetInterval:NO];
#endif
        }
        else {
            [snoozeProgress setProgress:[engine getPassRate] animated:YES];
        }
    }
}

- (IBAction)skipClicked:(id)sender {
    isActive = NO;
    elapsedSeconds = 0;
    stopSeconds = 0;
    CountingEngine* engine = [CountingEngine getInstance];
    [self stopExercise];
    [ledIndicatorTimer invalidate];
    ledIndicatorTimer = nil;
    [engine stopCounting];
    [engine setAdCounter:[engine adCounter] + 1];
    //[engine startCountingWithInterval:choseInterval * 60 scheduleType:1 resetInterval:YES];
    // back view controller
    NSArray *views = [self.navigationController viewControllers];
    if ([views count] > 1 && self.scheduledExercise) {
        UIViewController *popViewCtrl = [views objectAtIndex:[views count] - 2];
        if ([popViewCtrl isKindOfClass:[CountingViewController class]]) {// CountingViewController
            [engine startCountingWithInterval:choseInterval * 60 scheduleType:2 resetInterval:YES];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        //[engine stopCounting];
        [self performSegueWithIdentifier:@"exerciseToInterval" sender:self];
    }
}

- (void)playbackDidFinish:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo]; // Check the finish reson
    if ([[userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] != MPMovieFinishReasonUserExited) {
        NSDictionary* action = [[CountingEngine getInstance] currentAction];
        [self.mpc setCurrentPlaybackTime:[[action objectForKey:@"pauseTime"] intValue]];
    }
}

- (void)pauseExercise
{
    [snoozeButton setSelected:NO];
    
    [snoozeButton setImage:[UIImage imageNamed:@"snooze.png"] forState:UIControlStateNormal];
    [snoozeButton setImage:nil forState:UIControlStateHighlighted];
    
    [snoozeProgress setHidden:YES];
    
    [[CountingEngine getInstance] pauseCounting];

//    [self.mpc pause];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ListSegue"]) {
        [self pauseExercise];
    }
}

@end
