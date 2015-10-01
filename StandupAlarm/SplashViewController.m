//
//  SplashViewController.m
//  StandupAlarm
//
//  Created by Apple Fan on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

@synthesize nextSplashButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentFrame = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [[UIImage imageNamed:@"splash1.jpg"] drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
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

- (IBAction)nextSplash:(id)sender
{
    currentFrame++;
    if (currentFrame >= 11) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    NSString* imgFile = [NSString stringWithFormat:@"splash%d.jpg", currentFrame + 1];
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0);
    [[UIImage imageNamed:imgFile] drawInRect:self.view.bounds];
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
    if (currentFrame == 10)
        [nextSplashButton setImage:[UIImage imageNamed:@"closesplash.png"] forState:UIControlStateNormal];
}

@end
