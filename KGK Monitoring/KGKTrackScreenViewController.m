//
//  KGKTrackScreenViewController.m
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "KGKTrackScreenViewController.h"
#import "KGKSignalStore.h"
#import "KGKDispatcher.h"
#import "KGKSignal.h"
#import "MarkerInformationView.h"
#import "AppDelegate.h"
#import "LastActionDateStorage.h"
@import GoogleMaps;

@interface KGKTrackScreenViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (nonatomic) NSArray *signals;
@property (nonatomic) NSMutableArray *markers;
@property (nonatomic) MarkerInformationView *markerInformationView;

@end

@implementation KGKTrackScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:NSLocalizedString(@"Track", nil)];
    self.googleMapView.delegate = self;
    self.markerInformationView = [[MarkerInformationView alloc] init];
    
    self.signals = [KGKSignalStore getInstance:[KGKDispatcher getInstance]].signalsForHistory;
    self.markers = [[NSMutableArray alloc] init];
    [self refreshMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshMap {
    [self addPolyline];
    [self addMarkers];
    
    KGKSignal *firstSignal = self.signals[0];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:firstSignal.latitude longitude:firstSignal.longitude zoom:13.0];
    [self.googleMapView setCamera:camera];
}

- (void)addPolyline {
    GMSMutablePath *path = [GMSMutablePath path];
    for (KGKSignal *signal in self.signals) {
        [path addCoordinate:CLLocationCoordinate2DMake(signal.latitude, signal.longitude)];
    }
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    
    polyline.strokeWidth = 2.0;
    polyline.strokeColor = [UIColor blueColor];
    
    polyline.map = self.googleMapView;
}

- (void)addMarkers {
    [self.markers removeAllObjects];
    for (int i = 0; i < [self.signals count]; i++) {
        KGKSignal *signal = self.signals[i];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(signal.latitude, signal.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [self prepareMarkerImage:signal];
        marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
        marker.map = self.googleMapView;
        [self.markers addObject:marker];
    }
}

- (UIImage *)prepareMarkerImage:(KGKSignal *)signal {
    UIImage *markerBackground = [UIImage imageNamed:@"map_custom_marker_point_background.png"];
    UIImage *markerPointer = [self markerWithDirection:signal];
    
    CGSize destinationSize = CGSizeMake(20.0, 20.0);
    
    UIGraphicsBeginImageContext(destinationSize);
    [markerBackground drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    [markerPointer drawInRect:CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)markerWithDirection:(KGKSignal *)signal {
    if (signal.direction > 337 || signal.direction <= 22) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north.png"];
    } else if (signal.direction > 22 && signal.direction <= 67) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_north_east.png"];
    } else if (signal.direction > 67 && signal.direction <= 112) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_east.png"];
    } else if (signal.direction > 112 && signal.direction <= 157) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_east.png"];
    } else if (signal.direction > 157 && signal.direction <= 202) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south.png"];
    } else if (signal.direction > 202 && signal.direction <= 247) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_south_west.png"];
    } else if (signal.direction > 247 && signal.direction <= 292) {
        return [UIImage imageNamed:@"map_custom_marker_point_arrow_west.png"];
    } else if (signal.direction > 292 && signal.direction <= 337) {
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
    
    NSInteger index = [self.markers indexOfObject:marker];
    KGKSignal *signal = self.signals[index];
    
    self.markerInformationView.lastActionLabel.text = NSLocalizedString(@"Last Action", nil);
    self.markerInformationView.positioningLabel.text = NSLocalizedString(@"Positioning", nil);
    self.markerInformationView.satellitesLabel.text = NSLocalizedString(@"Satellites", nil);
    self.markerInformationView.speedLabel.text = NSLocalizedString(@"Speed", nil);
    self.markerInformationView.directionLabel.text = NSLocalizedString(@"Direction", nil);
    self.markerInformationView.temperatureLabel.text = NSLocalizedString(@"Temrerature", nil);
    self.markerInformationView.voltageLabel.text = NSLocalizedString(@"Voltage", nil);
    self.markerInformationView.chargeLabel.text = NSLocalizedString(@"Charge", nil);
    self.markerInformationView.balanceLabel.text = NSLocalizedString(@"Balance", nil);
    
    self.markerInformationView.lastActionDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:[[LastActionDateStorage getInstance] load]]]];
    self.markerInformationView.lastPositioningDate.text = [NSString stringWithFormat:@"%@", [AppDelegate formatDate:[NSDate dateWithTimeIntervalSince1970:signal.date]]];
    self.markerInformationView.satellites.text = [NSString stringWithFormat:NSLocalizedString(@"%ldst", nil), signal.satellites];
    self.markerInformationView.speed.text = [NSString stringWithFormat:NSLocalizedString(@"%ldkm/h", nil), signal.speed];
    self.markerInformationView.direction.text = [self directionLetterFromAzimut:signal.direction];
    self.markerInformationView.temperature.text = [NSString stringWithFormat:NSLocalizedString(@"%ld°C", nil), signal.temperature];
    self.markerInformationView.voltage.text = [NSString stringWithFormat:NSLocalizedString(@"%.01fV", nil), signal.voltage];
    self.markerInformationView.batteryCharge.text = [NSString stringWithFormat:NSLocalizedString(@"%ld%%", nil), signal.charge];
    self.markerInformationView.balance.text = [NSString stringWithFormat:NSLocalizedString(@"%.01frub", nil), signal.balance];
    
    return self.markerInformationView;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    [self.googleMapView setSelectedMarker:nil];
}

@end
