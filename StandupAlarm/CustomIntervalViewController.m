//
//  CustomIntervalViewController.m
//  StandupAlarm
//
//  Created by h on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomIntervalViewController.h"
#import "Config.h"
#import "CountingEngine.h"

@interface CustomIntervalViewController ()

@end

@implementation CustomIntervalViewController

@synthesize pickerView;

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
	// Do any additional setup after loading the view.
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [iPhoneImage(@"commonbg.png") drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
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
    
    // load custom intervals
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"CustomInterval" ofType:@"plist"];
    intervalList = [NSArray arrayWithContentsOfFile:plistPath];

    // fixed label
    [pickerView addLabel:@"mins" forComponent:0 forLongestString:@"mins"];

    
    // load saved interval
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"firstlunch.inf"];
    NSArray* intervalArray = [NSArray arrayWithContentsOfFile:plistPath];
    if (intervalArray) {
        if ([[intervalArray objectAtIndex:0] intValue] == 0) {
            [pickerView selectRow:[[intervalArray objectAtIndex:1] intValue] inComponent:0 animated:NO];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startButtonClicked:(id)sender
{
    int index = [pickerView selectedRowInComponent:0];
    int interval = [[intervalList objectAtIndex:index] intValue];

    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"firstlunch.inf"];
    
    NSArray* intervalArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:index], nil];
    [intervalArray writeToFile:plistPath atomically:YES];

#if !USE_TEST_TIME
    [[CountingEngine getInstance] startCountingWithInterval:interval * 60 scheduleType:0 resetInterval:YES];
#else
    [[CountingEngine getInstance] startCountingWithInterval:interval scheduleType:0 resetInterval:YES];
#endif

    [self performSegueWithIdentifier:@"StartCounting" sender:self];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [intervalList count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",[[intervalList objectAtIndex:row] intValue]];
}
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return 120;
    }
    
    return 0;
}
*/
@end
