//
//  KGKSettingsScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 06/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKSettingsScreenViewController.h"
#import "ToastView.h"
#import "AppDelegate.h"
#import "UtilityConstants.h"
#import "KGKDispatcher.h"
#import "ActionCreator.h"
#import "Tolo.h"
#import "SettingsSentEvent.h"
#import "ToastView.h"

@interface KGKSettingsScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *connectionPeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberSmsLabel;
@property (weak, nonatomic) IBOutlet UILabel *gpsPositioningLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLimitLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceCommandLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITextField *connectionPeriod;
@property (weak, nonatomic) IBOutlet UITextField *smsOmissions;
@property (weak, nonatomic) IBOutlet UITextField *positioningPeriod;
@property (weak, nonatomic) IBOutlet UITextField *balanceLimit;
@property (weak, nonatomic) IBOutlet UITextField *balanceCommand;
@property (weak, nonatomic) IBOutlet UISwitch *gprsSwitch;
@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) ActionCreator *actionCreator;

@end

@implementation KGKSettingsScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Settings", nil)];
    
    self.connectionPeriodLabel.text = NSLocalizedString(@"Connection Period", nil);
    self.numberSmsLabel.text = NSLocalizedString(@"Number of SMS omissions", nil);
    self.gpsPositioningLabel.text = NSLocalizedString(@"GPS positioning period", nil);
    self.balanceLimitLabel.text = NSLocalizedString(@"Balance control limit", nil);
    self.balanceCommandLabel.text = NSLocalizedString(@"Balance request command", nil);
    [self.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    self.dispatcher = [KGKDispatcher getInstance];
    self.actionCreator = [ActionCreator getInstance:self.dispatcher];
    [self loadSettingsFromUserDefaults];
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
}

- (IBAction)send:(id)sender {
    if (![self validateFields]) {
        return;
    }
    
    [self saveSettingsToUserDefaults];
    [self.actionCreator sendSettingsRequest:[self generateJsonWithSettings]];
}

- (BOOL)validateFields {
    if ([[self.balanceCommand text] length] > 10) {
        [ToastView showToastInParentView:self.view
                                withText:@"Balance request command is too long"
                           withDuaration:3.0];
        return NO;
    }
    return YES;
}

- (void)saveSettingsToUserDefaults {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    
    [AppDelegate saveStringToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_CONNECTION_PERIOD, deviceId]
                                    value:[self.connectionPeriod text]];
    [AppDelegate saveStringToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_NUMBER_SMS_OMISSIONS, deviceId]
                                    value:[self.smsOmissions text]];
    [AppDelegate saveStringToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_GPS_POSITIONING_PERIOD, deviceId]
                                    value:[self.positioningPeriod text]];
    [AppDelegate saveStringToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_BALANCE_CONTROL_LIMIT, deviceId]
                                    value:[self.balanceLimit text]];
    [AppDelegate saveStringToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_BALANCE_REQUEST_COMMAND, deviceId]
                                    value:[self.balanceCommand text]];
    [AppDelegate saveBooleanToUserDefaults:[[NSString alloc] initWithFormat:@"%@%@", KEY_GPRS_STATUS, deviceId]
                                    value:self.gprsSwitch.on];
    
}

- (void)loadSettingsFromUserDefaults {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    
    self.connectionPeriod.text = [AppDelegate loadStringFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_CONNECTION_PERIOD, deviceId]];
    if ([self.connectionPeriod.text length] == 0) {
        self.connectionPeriod.text = @"1440";
    }
    
    self.smsOmissions.text = [AppDelegate loadStringFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_NUMBER_SMS_OMISSIONS, deviceId]];
    if ([self.smsOmissions.text length] == 0) {
        self.smsOmissions.text = @"0";
    }
    
    self.positioningPeriod.text = [AppDelegate loadStringFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_GPS_POSITIONING_PERIOD, deviceId]];
    if ([self.positioningPeriod.text length] == 0) {
        self.positioningPeriod.text = @"5";
    }
    
    self.balanceLimit.text = [AppDelegate loadStringFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_BALANCE_CONTROL_LIMIT, deviceId]];
    if ([self.balanceLimit.text length] == 0) {
        self.balanceLimit.text = @"100";
    }
    
    self.balanceCommand.text = [AppDelegate loadStringFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_BALANCE_REQUEST_COMMAND, deviceId]];
    if ([self.balanceCommand.text length] == 0) {
        self.balanceCommand.text = @"*100#";
    }
    
    self.gprsSwitch.on = [AppDelegate loadBooleanFromUserDefaults:[[NSString alloc]
                                                                          initWithFormat:@"%@%@", KEY_GPRS_STATUS, deviceId]];
}

- (NSString *)generateJsonWithSettings {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    
    NSMutableDictionary *testDict = [[NSMutableDictionary alloc] init];
    [testDict setObject:self.connectionPeriod.text forKey:@"connection_period"];
    [testDict setObject:self.smsOmissions.text forKey:@"sms_omissions"];
    [testDict setObject:self.positioningPeriod.text forKey:@"gps_period"];
    [testDict setObject:self.balanceLimit.text forKey:@"balance_limit"];
    [testDict setObject:self.balanceCommand.text forKey:@"balance_command"];
    [testDict setObject:deviceId forKey:@"id"];
    [testDict setObject:[NSNumber numberWithBool:self.gprsSwitch.on] forKey:@"gprs_status"];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:testDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonData;
}

SUBSCRIBE(SettingsSentEvent) {
    NSString *message;
    if (event.status == 1) {
        message = NSLocalizedString(@"Command has been sent" , nil);
    } else {
        message = NSLocalizedString(@"Error sending command", nil);
    }
    [ToastView showToastInParentView:self.view
                            withText:message
                       withDuaration:2.0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end
