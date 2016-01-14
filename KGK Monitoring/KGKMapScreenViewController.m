//
//  KGKMapScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKMapScreenViewController.h"
#import "KGKSignal.h"
#import "KGKSignalStore.h"
#import "KGKDispatcher.h"
#import "MarkerInformationView.h"
#import "AppDelegate.h"
#import "LastActionDateStorage.h"
@import GoogleMaps;

@interface KGKMapScreenViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (nonatomic) GMSMarker *marker;
@property (nonatomic) KGKSignal *signal;
@property (nonatomic) MarkerInformationView *markerInformationView;

@end

@implementation KGKMapScreenViewController {
    
    GMSMapView *mapView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Map", nil)];
    self.googleMapView.delegate = self;
    self.markerInformationView = [[MarkerInformationView alloc] init];
    
    self.signal = [KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalForMap;
    if (self.signal != nil) {
        [self refreshMap];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshMap {
    if (self.marker != nil) {
        [self.googleMapView clear];
    }
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(self.signal.latitude, self.signal.longitude);
    self.marker = [GMSMarker markerWithPosition:position];
    self.marker.icon = [self prepareMarkerImage];
    self.marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
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
    if (self.signal.direction > 337 || self.signal.direction <= 22) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north.png"];
    } else if (self.signal.direction > 22 && self.signal.direction <= 67) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north_east.png"];
    } else if (self.signal.direction > 67 && self.signal.direction <= 112) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_east.png"];
    } else if (self.signal.direction > 112 && self.signal.direction <= 157) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_east.png"];
    } else if (self.signal.direction > 157 && self.signal.direction <= 202) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south.png"];
    } else if (self.signal.direction > 202 && self.signal.direction <= 247) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_west.png"];
    } else if (self.signal.direction > 247 && self.signal.direction <= 292) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_west.png"];
    } else if (self.signal.direction > 292 && self.signal.direction <= 337) {
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

// Google map protocol

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self.googleMapView setSelectedMarker:marker];
    return YES;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    self.markerInformationView.lastActionLabel.text = NSLocalizedString(@"Last Action", nil);
    self.markerInformationView.positioningLabel.text = NSLocalizedString(@"Positioning", nil);
    self.markerInformationView.satellitesLabel.text = NSLocalizedString(@"Satellites", nil);
    self.markerInformationView.speedLabel.text = NSLocalizedString(@"Speed", nil);
    self.markerInformationView.directionLabel.text = NSLocalizedString(@"Direction", nil);
    self.markerInformationView.temperatureLabel.text = NSLocalizedString(@"Temperature", nil);
    self.markerInformationView.voltageLabel.text = NSLocalizedString(@"Voltage", nil);
    self.markerInformationView.chargeLabel.text = NSLocalizedString(@"Charge", nil);
    self.markerInformationView.balanceLabel.text = NSLocalizedString(@"Balance", nil);
    
    self.markerInformationView.lastActionDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:[[LastActionDateStorage getInstance] load]]]];
    self.markerInformationView.lastPositioningDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:self.signal.date]]];
    self.markerInformationView.satellites.text = [NSString stringWithFormat:NSLocalizedString(@"%ldst", nil), self.signal.satellites];
    self.markerInformationView.speed.text = [NSString stringWithFormat:NSLocalizedString(@"%ldkm/h", nil), self.signal.speed];
    self.markerInformationView.direction.text = [self directionLetterFromAzimut:self.signal.direction];
    self.markerInformationView.temperature.text = [NSString stringWithFormat:NSLocalizedString(@"%ld°C", nil), self.signal.temperature];
    self.markerInformationView.voltage.text = [NSString stringWithFormat:NSLocalizedString(@"%.01fV", nil),  self.signal.voltage];
    self.markerInformationView.batteryCharge.text = [NSString stringWithFormat:NSLocalizedString(@"%ld%%", nil), self.signal.charge];
    self.markerInformationView.balance.text = [NSString stringWithFormat:NSLocalizedString(@"%.01frub", nil), self.signal.balance];
    
    return self.markerInformationView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self.googleMapView setSelectedMarker:nil];
}

@end
