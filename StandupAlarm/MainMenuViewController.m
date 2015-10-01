//
//  MainMenuViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuViewController.h"
#import "CountingEngine.h"
#import "Config.h"
#import "IntervalCell.h"
#import "NotificationSettingViewController.h"
#import <QuartzCore/QuartzCore.h>

extern NSDate *startDate;
extern NSDate *endDate;
int choseInterval;

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

@synthesize intervalTable;

UIAlertView *createIntervalAlert;

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
    //[self saveIntervalData];
    [self savePatterns];
//    if ([[self.navigationController viewControllers] count] > 1) {
//        [self.navigationController popViewControllerAnimated:YES];
//    } else {
//        [self performSegueWithIdentifier:@"Interval2home" sender:self];
//    }
    [self performSegueWithIdentifier:@"Interval2home" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    _startTime.text = [dateFormatter stringFromDate:startDate];
    _endTime.text = [dateFormatter stringFromDate:endDate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    choseInterval = 0;
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"commonbg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
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

#if USE_ADMOB
    // Create a view of the standard size at the bottom of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    CGSize adSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        adSize = GAD_SIZE_728x90;
    } else {
        adSize = GAD_SIZE_320x50;
    }
    
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2, self.view.frame.size.height - adSize.height,adSize.width,adSize.height)];
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14ff3a14d8de5d";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
#endif
    
    NSMutableArray *rec = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"listIntervals"] mutableCopy];
    // load interval list
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Interval" ofType:@"plist"];
    if ( [rec count] > 0) {
        intervalList = [NSMutableArray arrayWithArray:rec];
    }
    else{
        intervalList = [NSMutableArray arrayWithContentsOfFile:plistPath];
    }
    // load saved interval
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"firstlunch.inf"];
    NSArray* lunchData = [NSArray arrayWithContentsOfFile:plistPath];
    if (lunchData) {
        currentInterval = [[lunchData objectAtIndex:0] intValue];
//        [intervalTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentInterval inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    } else {
        currentInterval = DEFAULT_INTERVAL;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.    
    bannerView_.delegate = nil;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)createButtonClicked:(id)sender {
    createIntervalAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Length in minutes?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    createIntervalAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [createIntervalAlert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
    [createIntervalAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView == createIntervalAlert ) {
        if (buttonIndex == 1) {//add to list
            NSString* valstr = [[alertView textFieldAtIndex:0] text];
            int rep =0;
            if (valstr && [valstr floatValue] > 0 && [valstr floatValue] < 301) {
                int realint = (int)floor([valstr floatValue]);
                int repint = 0;
                for (rep = 0; rep < [intervalList count]; rep++) {
                    repint = [[[intervalList objectAtIndex:rep] objectForKey:@"interval"] intValue];
                    if (repint == realint) {
                        return;
                    }
                    else if(repint > realint){
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d minutes", realint],@"caption",[NSString stringWithFormat:@"%d", realint], @"interval", nil];
                        [intervalList insertObject:dic atIndex:rep];
                        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Interval" ofType:@"plist"];
                        [intervalList writeToFile:plistPath atomically:YES];
                        [self.intervalTable reloadData];
                        return;
                    }
                    else{
                        continue;
                    }
                }
                // bigest value
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d minutes", realint],@"caption",[NSString stringWithFormat:@"%d", realint], @"interval", nil];
                [intervalList insertObject:dic atIndex:rep];
                NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Interval" ofType:@"plist"];
                [intervalList writeToFile:plistPath atomically:YES];
                [self.intervalTable reloadData];
            }
            else{
                // retry input
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Length in minutes < 300?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField * alertTextField = [alert textFieldAtIndex:0];
                alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
                [alert show];
                return;
            }
        }
    }
}

- (void) saveIntervalData{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Interval" ofType:@"plist"];
    NSMutableArray *currentlist = [NSMutableArray arrayWithContentsOfFile:plistPath];
    [currentlist removeAllObjects];
    [currentlist writeToFile:plistPath atomically:YES];
    BOOL result = [intervalList writeToFile:plistPath atomically:YES];
    if (result) {
        NSLog(@"ok logged" );
    }
    else
        NSLog(@" not saved");
}

- (IBAction)startButtonClicked:(id)sender
{
    //[self saveIntervalData];
    [self savePatterns];
   
    int interval = [[[intervalList objectAtIndex:currentInterval] objectForKey:@"interval"] intValue];
    choseInterval = interval;
    [[NSUserDefaults standardUserDefaults] setInteger:choseInterval forKey:@"choseInterval"];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"firstlunch.inf"];
    
    NSArray* intervalArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:currentInterval], nil];
    [intervalArray writeToFile:plistPath atomically:YES];
    
    CountingEngine *engine = [CountingEngine getInstance];
    engine.targetInterval = interval * 60;
    engine.targetTime = GETCURRENTTIME + engine.targetInterval + 1;
    engine.pausedTime = 0;
    engine.nextTargetInterval = engine.targetInterval;
    [engine setCurrentActionRandomly];
/*
#if !USE_TEST_TIME
    [[CountingEngine getInstance] startCountingWithInterval:interval * 60 scheduleType:0 resetInterval:YES];
#else
    [[CountingEngine getInstance] startCountingWithInterval:interval / 3 scheduleType:0 resetInterval:YES];
#endif
*/
    [self performSegueWithIdentifier:@"StartCounting" sender:self];
}

- (IBAction)setInterval:(id)sender {//between setting
    NotificationSettingViewController *target = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationSettingViewController"];
    [self presentViewController:target animated:YES completion:nil];
}

- (void) savePatterns{
//    if ([tempList count] > 0) {
//        [tempList removeAllObjects];
//    }
//    tempList = [NSMutableArray arrayWithArray:intervalList];
    [[NSUserDefaults standardUserDefaults] setObject:intervalList forKey:@"listIntervals"];
}

#pragma mark -
#pragma mark UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [intervalList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntervalCell *cell;
    cell = (IntervalCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentInterval inSection:0]];
    [cell setChecked:NO];
    currentInterval = indexPath.row;
    cell = (IntervalCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setChecked:YES];
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *INTERVAL_CELL = @"IntervalCell";
    IntervalCell *cell = (IntervalCell*)[tableView dequeueReusableCellWithIdentifier:INTERVAL_CELL];
    if (cell == nil) {
        cell = [[IntervalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:INTERVAL_CELL];
    }
    [cell setChecked:(currentInterval == indexPath.row)];
    [cell setCaption:[[intervalList objectAtIndex:indexPath.row] objectForKey:@"caption"]];
    if ( currentInterval == indexPath.row )
        cell.captionLabel.textColor = [UIColor colorWithRed:33.0 / 255 green:99.0 / 255 blue:198.0 / 255 alpha:1];
    else
        cell.captionLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

@end
