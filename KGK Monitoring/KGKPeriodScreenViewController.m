//
//  KGKPeriodScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKPeriodScreenViewController.h"
#import "ActionCreator.h"
#import "KGKDispatcher.h"

@interface KGKPeriodScreenViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *toDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@end

@implementation KGKPeriodScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Period", nil)];
    
    self.fromLabel.text = NSLocalizedString(@"fromLabel", nil);
    self.toLabel.text = NSLocalizedString(@"toLabel", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPeriod:(id)sender {
    NSInteger fromDateInSeconds = (NSInteger) [self.fromDatePicker.date timeIntervalSince1970];
    NSInteger toDateInSeconds = (NSInteger) [self.toDatePicker.date timeIntervalSince1970];
    
    ActionCreator *actionCreator = [ActionCreator getInstance:[KGKDispatcher getInstance]];
    [actionCreator getSignalsFromDatabaseByPeriod:fromDateInSeconds toDate:toDateInSeconds];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
