//
//  KGKInformationScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 05/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKInformationScreenViewController.h"
#import "KGKSettingsScreenViewController.h"
#import "KGKMapScreenViewController.h"
#import "KGKHistoryScreenViewController.h"
#import "KGKDispatcher.h"
#import "ActionCreator.h"
#import "Tolo.h"
#import "KGKStoreChangeEvent.h"
#import "ToggleSearchModeEvent.h"
#import "ToastView.h"
#import "AppDelegate.h"
#import "UtilityConstants.h"
#import "KGKSignal.h"
#import "LastActionDateStorage.h"
#import "KGKSignalStore.h"
#import "KGKDownloadDataInProgressEvent.h"
#import "KGKHttpConstants.h"
@import GoogleMaps;

@interface KGKInformationScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *modelDescription;
@property (weak, nonatomic) IBOutlet UILabel *lastActionDate;
@property (weak, nonatomic) IBOutlet UILabel *lastPositioningDate;
@property (weak, nonatomic) IBOutlet UILabel *satellites;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *direction;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *voltage;
@property (weak, nonatomic) IBOutlet UILabel *charge;
@property (weak, nonatomic) IBOutlet UILabel *balance;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *queryButton;
@property (weak, nonatomic) IBOutlet UILabel *lastActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastPositioningLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;
@property (weak, nonatomic) IBOutlet UILabel *satellitesLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (nonatomic) GMSMarker *marker;

@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) ActionCreator *actionCreator;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (nonatomic) BOOL searchMode;
@property (nonatomic) KGKSignal *signal;

@end

@implementation KGKInformationScreenViewController {
    
    GMSMapView *mapView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Information", nil)];
    
    [self drawLabels];
    
    self.dispatcher = [KGKDispatcher getInstance];
    self.actionCreator = [ActionCreator getInstance:self.dispatcher];
    self.googleMapView.delegate = self;
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", (long)delegate.activeDeviceId];
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@", KEY_SEARCH_SWITCH, deviceId];
    self.searchMode = [AppDelegate loadBooleanFromUserDefaults:key];
    if (self.searchMode) {
        [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_on_button.png"] forState:UIControlStateNormal];
        [self.searchButton setTitle:NSLocalizedString(@"Search: On", nil) forState:UIControlStateNormal];
    } else {
        [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_off_button.png"] forState:UIControlStateNormal];
        [self.searchButton setTitle:NSLocalizedString(@"Search: Off", nil) forState:UIControlStateNormal];
    }
    
    self.signal = [[KGKSignalStore getInstance:self.dispatcher] lastSignal];
    if (self.signal != nil) {
        [self refreshUI];
    }
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

- (void)drawLabels {
    [self.mapButton setTitle:NSLocalizedString(@"Map", nil) forState:UIControlStateNormal];
    [self.historyButton setTitle:NSLocalizedString(@"History", nil) forState:UIControlStateNormal];
    [self.settingsButton setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
    [self.queryButton setTitle:NSLocalizedString(@"Query", nil) forState:UIControlStateNormal];
    
    self.lastActionLabel.text = NSLocalizedString(@"Last Action", nil);
    self.lastPositioningLabel.text = NSLocalizedString(@"Last Positioning", nil);
    self.modeLabel.text = NSLocalizedString(@"Message in detecting mode", nil);
    self.satellitesLabel.text = NSLocalizedString(@"Satellites", nil);
    self.speedLabel.text = NSLocalizedString(@"Speed", nil);
    self.directionLabel.text = NSLocalizedString(@"Direction", nil);
    self.temperatureLabel.text = NSLocalizedString(@"Temperature", nil);
    self.voltageLabel.text = NSLocalizedString(@"Voltage", nil);
    self.chargeLabel.text = NSLocalizedString(@"Charge", nil);
    self.balanceLabel.text = NSLocalizedString(@"Balance", nil);
}

- (void)refreshUI {
    self.modelDescription.text = [NSString stringWithFormat:@"KGK Actis %ld", self.signal.deviceId];
    self.lastActionDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:[[LastActionDateStorage getInstance] load]]]];
    self.lastPositioningDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:self.signal.date]]];
    self.satellites.text = [NSString stringWithFormat:NSLocalizedString(@"%ldst", nil), self.signal.satellites];
    self.speed.text = [NSString stringWithFormat:NSLocalizedString(@"%ldkm/h", nil), self.signal.speed];
    self.direction.text = [self directionLetterFromAzimut:self.signal.direction];
    self.temperature.text = [NSString stringWithFormat:NSLocalizedString(@"%ld°C", nil), self.signal.temperature];
    self.voltage.text = [NSString stringWithFormat:NSLocalizedString(@"%.01fV", nil), self.signal.voltage];
    self.charge.text = [NSString stringWithFormat:NSLocalizedString(@"%ld%%", nil), self.signal.charge];
    self.balance.text = [NSString stringWithFormat:NSLocalizedString(@"%.01frub", nil), self.signal.balance];
    [self refreshMap];
}

- (void)refreshMap {
    if (self.marker != nil) {
        [self.googleMapView clear];
    }
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.signal.latitude, self.signal.longitude);
    self.marker = [GMSMarker markerWithPosition:position];
    self.marker.icon = [self prepareMarkerImage];
    self.marker.map = self.googleMapView;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.signal.latitude longitude:self.signal.longitude zoom:13.0];
    [self.googleMapView setCamera:camera];
}

- (UIImage *)prepareMarkerImage {
    UIImage *markerBackground = [UIImage imageNamed:@"map_custom_marker_point_background.png"];
    UIImage *markerPointer = [self markerWithDirection];
    
    CGSize destinationSize = CGSizeMake(20.0, 20.0);
    
    UIGraphicsBeginImageContext(destinationSize);
    [markerBackground drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    [markerPointer drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)markerWithDirection {
    if ([self.direction.text isEqualToString:NSLocalizedString(@"N", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"NE", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north_east.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"E", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_east.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"SE", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_east.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"S", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"SW", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_west.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"W", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_west.png"];
    } else if ([self.direction.text isEqualToString:NSLocalizedString(@"NW", nil)]) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north_west.png"];
    } else {
        return nil;
    }
}

- (NSString *)directionLetterFromAzimut:(NSInteger)azimut {
    if (azimut > 337 || azimut <= 22) {
        return NSLocalizedString(@"N", nil);
    } else if (azimut > 22 && azimut <= 67) {
        return NSLocalizedString(@"NE", nil);
    } else if (azimut > 67 && azimut <= 112) {
        return NSLocalizedString(@"E", nil);
    } else if (azimut > 112 && azimut <=157) {
        return NSLocalizedString(@"SE", nil);
    } else if (azimut > 157 && azimut <= 202) {
        return NSLocalizedString(@"S", nil);
    } else if (azimut > 202 && azimut <= 247) {
        return NSLocalizedString(@"SW", nil);
    } else if (azimut > 247 && azimut <= 292) {
        return NSLocalizedString(@"W", nil);
    } else if (azimut > 292 && azimut <= 337) {
        return NSLocalizedString(@"NW", nil);
    }
    
    return @"N/A";
}

SUBSCRIBE(KGKStoreChangeEvent) {
    self.signal = [[KGKSignalStore getInstance:self.dispatcher] lastSignal];
    [self refreshUI];
}

SUBSCRIBE(ToggleSearchModeEvent) {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *deviceId = [[NSString alloc] initWithFormat:@"%ld", delegate.activeDeviceId];
    NSString *key = [[NSString alloc] initWithFormat:@"%@%@", KEY_SEARCH_SWITCH, deviceId];
    
    if (event.searchModeState) {
        if (self.searchMode) {
            [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_off_button.png"]
                                         forState:UIControlStateNormal];
            [self.searchButton setTitle:NSLocalizedString(@"Search: Off", nil) forState:UIControlStateNormal];
            self.searchMode = NO;
        } else {
            [self.searchButton setBackgroundImage:[UIImage imageNamed:@"search_on_button.png"] forState:UIControlStateNormal];
            [self.searchButton setTitle:NSLocalizedString(@"Search: On", nil) forState:UIControlStateNormal];
            self.searchMode = YES;
        }
        [AppDelegate saveBooleanToUserDefaults:key value:self.searchMode];
        [ToastView showToastInParentView:self.view
                                withText:NSLocalizedString(@"Command has been sent", nil)
                           withDuaration:2.0];
        self.lastActionDate.text = [NSString stringWithFormat:@"%@",
                                    [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:[[LastActionDateStorage getInstance] load]]]];
    } else {
        [ToastView showToastInParentView:self.view
                                withText:NSLocalizedString(@"Error sending command", nil)
                           withDuaration:2.0];
    }
}

// Button actions

- (IBAction)goToSettingsMenu:(id)sender {
    KGKSettingsScreenViewController *settingsScreenViewController = [[KGKSettingsScreenViewController alloc] init];
    [self.navigationController pushViewController:settingsScreenViewController
                                         animated:YES];
}

- (IBAction)goToMap:(id)sender {
    [KGKSignalStore getInstance:self.dispatcher].signalForMap = self.signal;
    KGKMapScreenViewController *mapScreenViewController = [[KGKMapScreenViewController alloc] init];
    [self.navigationController pushViewController:mapScreenViewController
                                         animated:YES];
}

- (IBAction)goToHistory:(id)sender {
    KGKHistoryScreenViewController *historyScreenViewController = [[KGKHistoryScreenViewController alloc] init];
    [self.navigationController pushViewController:historyScreenViewController
                                         animated:YES];
}

- (IBAction)query:(id)sender {
    [self.actionCreator sendQueryBeaconRequest];
    [self.actionCreator getLastSignalDateFromDatabase];
}

- (IBAction)search:(id)sender {
    NSString *dialogMessage = self.searchMode ? NSLocalizedString(@"Do you want to deactivate search mode?", nil) :
                                                        NSLocalizedString(@"Do you want to activate search mode?", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Search mode", nil)
                                                    message:dialogMessage
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.actionCreator sendToggleSearchModeRequest:self.searchMode ? NO : YES];
    }
}

// Google map protocol

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [KGKSignalStore getInstance:self.dispatcher].signalForMap = self.signal;
    KGKMapScreenViewController *mapScreenViewController = [[KGKMapScreenViewController alloc] init];
    [self.navigationController pushViewController:mapScreenViewController
                                         animated:YES];
    return YES;
}

@end