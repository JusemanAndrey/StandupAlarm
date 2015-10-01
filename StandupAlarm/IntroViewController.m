//
//  IntroViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IntroViewController.h"
#import "CountingEngine.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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

    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [[UIImage imageNamed:@"intro.jpg"] drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];

    if ([[CountingEngine getInstance] firstLunch])
        [self showMainMenuWithDelay];
        //[self performSegueWithIdentifier:@"ShowSplash" sender:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    CountingEngine* engine = [CountingEngine getInstance];
//    if ([engine firstLunch]) {
//        [engine setFirstLunch:NO];
//
//        [self showMainMenuWithDelay];
//    }
//}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showMainMenuWithDelay
{
    [self showMainMenu];
    //[self performSelectorOnMainThread:@selector(showMainMenuWithDelayOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)showMainMenuWithDelayOnMainThread
{
    [NSTimer scheduledTimerWithTimeInterval: INTRO_TIMEOUT target:self selector:@selector(showMainMenu) userInfo:nil repeats:NO];
}

- (void)showMainMenu
{
    [self performSegueWithIdentifier:@"Intro2MainMenu" sender:self];
}

@end
