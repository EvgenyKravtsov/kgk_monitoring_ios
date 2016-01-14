//
//  KGKDevicesScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 12/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKDevicesScreenViewController.h"
#import "KGKDispatcher.h"
#import "KGKDeviceStore.h"
#import "KGKDevice.h"
#import "KGKInformationScreenViewController.h"
#import "AppDelegate.h"
#import "ActionCreator.h"
#import "Tolo.h"
#import "KGKDownloadDataInProgressEvent.h"
#import "KGKHttpConstants.h"

@interface KGKDevicesScreenViewController ()

@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation KGKDevicesScreenViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Devices", nil)];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_background.png"]];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicator setColor:[UIColor colorWithRed:252.0/255.0 green:113.0/255.0 blue:9.0/255.0 alpha:1.0]];
    self.indicator.center = self.view.center;
    [self.view addSubview:self.indicator];
    
    [self showWarningDialog];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    REGISTER();
}

- (void)viewDidDisappear:(BOOL)animated {
    UNREGISTER();
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWarningDialog {
    NSString *dialogMessage = NSLocalizedString(@"Current version of application supports only Actis beacons", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
                                                    message:dialogMessage
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    KGKDispatcher *dispatcher = [KGKDispatcher getInstance];
    KGKDeviceStore *deviceStore = [KGKDeviceStore getInstance:dispatcher];
    return [deviceStore.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65f];
    cell.contentView.alpha = 0.65f;
    
    
    // Selection style
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75f];
    backgroundColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = backgroundColorView;
    
    KGKDispatcher *dispatcher = [KGKDispatcher getInstance];
    KGKDeviceStore *deviceStore = [KGKDeviceStore getInstance:dispatcher];
    NSArray *devices = deviceStore.devices;
    KGKDevice *device = devices[indexPath.row];
    cell.textLabel.text = [device description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KGKDispatcher *dispatcher = [KGKDispatcher getInstance];
    KGKDeviceStore *deviceStore = [KGKDeviceStore getInstance:dispatcher];
    
    KGKDevice *device = deviceStore.devices[indexPath.row];
    NSString *activeDeviceIdString = device.id;
    NSInteger activeDeviceId = [activeDeviceIdString integerValue];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.activeDeviceId = activeDeviceId;
    
    NSInteger defaultNumOfSignalsForHistory = 10;
    [[ActionCreator getInstance:dispatcher] getSignalsFromDatabase:defaultNumOfSignalsForHistory];
    
    [[ActionCreator getInstance:[KGKDispatcher getInstance]]getLastSignalDateFromDatabase];
}

SUBSCRIBE(KGKDownloadDataInProgressEvent) {
    if ([event.status isEqualToString:STARTED]) {
        [self.indicator startAnimating];
    } else if ([event.status isEqualToString:SUCCESS]) {
        [self.indicator stopAnimating];
        
        KGKInformationScreenViewController *informationScreenViewController = [[KGKInformationScreenViewController alloc] init];
        [self.navigationController pushViewController:informationScreenViewController
                                             animated:YES];
    }
}

@end
