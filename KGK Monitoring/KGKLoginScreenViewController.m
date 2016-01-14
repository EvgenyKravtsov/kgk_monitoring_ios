//
//  KGKLoginScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 05/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKLoginScreenViewController.h"
#import "KGKInformationScreenViewController.h"
#import "KGKDevicesScreenViewController.h"
#import "AppDelegate.h"
#import "KGKDispatcher.h"
#import "ActionCreator.h"
#import "Tolo.h"
#import "KGKLoginEvent.h"
#import "KGKHttpConstants.h"
#import "ToastView.h"

@interface KGKLoginScreenViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *rememberMeLabel;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeCheckButton;
@property (nonatomic) BOOL isRememberMeOptionSelected;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) ActionCreator *actionCreator;

@end

@implementation KGKLoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    REGISTER();
    
    [self.navigationItem setTitle:NSLocalizedString(@"Login", nil)];
    
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
//                                    initWithTitle:NSLocalizedString(@"Settings", nil)
//                                    style:UIBarButtonItemStylePlain
//                                    target:self
//                                    action:@selector(settings:)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.dispatcher = [KGKDispatcher getInstance];
    self.actionCreator = [ActionCreator getInstance:self.dispatcher];
    
    [self.indicator setHidesWhenStopped:YES];
    
    self.rememberMeLabel.text = NSLocalizedString(@"Remember Me", nil);
    [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    self.loginTextField.placeholder = NSLocalizedString(@"Login Placeholder", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password Placeholder", nil);
    
    
    
    [self loadLoginAndPassword];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveLoginAndPassword:(NSString *)login password:(NSString *)password {
    [AppDelegate saveStringToUserDefaults:@"login" value:login];
    [AppDelegate saveStringToUserDefaults:@"password" value:password];
}

- (void)loadLoginAndPassword {
    self.isRememberMeOptionSelected = [AppDelegate loadBooleanFromUserDefaults:@"remember"];
    
    if (self.isRememberMeOptionSelected) {
        [self.rememberMeCheckButton setBackgroundImage:[UIImage imageNamed:@"selectedcheckbox.png"]
                                              forState:UIControlStateNormal];
    } else {
        [self.rememberMeCheckButton setBackgroundImage:[UIImage imageNamed:@"notselectedcheckbox.png"]
                                              forState:UIControlStateNormal];
    }
    
    
    if (self.isRememberMeOptionSelected) {
        NSString *login = [AppDelegate loadStringFromUserDefaults:@"login"];
        NSString *password = [AppDelegate loadStringFromUserDefaults:@"password"];
        
        login == nil ? [self.loginTextField setText:@""] :
        [self.loginTextField setText:login];
        
        password == nil ? [self.passwordTextField setText:@""] :
        [self.passwordTextField setText:password];
    }
}

SUBSCRIBE(KGKLoginEvent) {
    if ([event.type isEqualToString:LOGIN_FAILED]) {
        [self.indicator stopAnimating];
        [ToastView showToastInParentView:self.view
                                withText:NSLocalizedString(@"Wrong login or password", nil)
                           withDuaration:3.0];
    } else if ([event.type isEqualToString:LOGIN_ERROR]) {
        [self.indicator stopAnimating];
        [ToastView showToastInParentView:self.view
                                withText:NSLocalizedString(@"Network error", nil)
                           withDuaration:3.0];
    } else if ([event.type isEqualToString:LOGIN_NO_DEVICES]) {
        [self.indicator stopAnimating];
        [ToastView showToastInParentView:self.view
                                withText:NSLocalizedString(@"No registered devices", nil)
                           withDuaration:3.0];
    } else if ([event.type isEqualToString:LOGIN_SUCCESS]) {
        [self.indicator stopAnimating];
        KGKDevicesScreenViewController *devicesScreenViewController = [[KGKDevicesScreenViewController alloc] init];
        [self.navigationController pushViewController:devicesScreenViewController
                                             animated:YES];
    }
}

// Button actions

- (void)settings:(id)sender {}

- (void)switchRememberMeCheckButton {
    if (self.isRememberMeOptionSelected) {
        [self.rememberMeCheckButton setBackgroundImage:[UIImage imageNamed:@"notselectedcheckbox.png"]
                                              forState:UIControlStateNormal];
        self.isRememberMeOptionSelected = false;
        [AppDelegate saveBooleanToUserDefaults:@"remember"
                                         value:self.isRememberMeOptionSelected];
        
    } else {
        [self.rememberMeCheckButton setBackgroundImage:[UIImage imageNamed:@"selectedcheckbox.png"]
                                              forState:UIControlStateNormal];
        self.isRememberMeOptionSelected = true;
    }
    
    [AppDelegate saveBooleanToUserDefaults:@"remember"
                                     value:self.isRememberMeOptionSelected];
}

- (IBAction)login:(id)sender {
    if (self.isRememberMeOptionSelected) {
        [self saveLoginAndPassword:[self.loginTextField text]
                          password:[self.passwordTextField text]];
    }
    
    [self.actionCreator sendAuthenticationRequest:[self.loginTextField text]
                                                 :[self.passwordTextField text]];
    
    [self.indicator startAnimating];
}

- (IBAction)rememberMe:(id)sender {
    [self switchRememberMeCheckButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

@end




























