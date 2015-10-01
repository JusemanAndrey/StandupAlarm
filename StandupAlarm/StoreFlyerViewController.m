//
//  StoreFlyerViewController.m
//  StandupAlarm
//
//  Created by Albert Li on 10/21/12.
//
//

#import "StoreFlyerViewController.h"
#import "Config.h"
#import "CountingEngine.h"
#import "ExerciseViewController.h"

@interface StoreFlyerViewController ()

@end

@implementation StoreFlyerViewController

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

//    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
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

- (IBAction)visitStandAppStore:(id)sender {
    if (self.playWhenResume) {
        [self.exerciseViewController.mpc play];
        self.exerciseViewController = nil;
    }
    
    [[CountingEngine getInstance] resumeCounting];
    
    [self.view removeFromSuperview];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOMORE_URL]];
}

- (IBAction)closeStoreFlyer:(id)sender {
    if (self.playWhenResume) {
        [self.exerciseViewController.mpc play];
        self.exerciseViewController = nil;
    }
    
    [[CountingEngine getInstance] resumeCounting];

    [self.view removeFromSuperview];
}

@end
