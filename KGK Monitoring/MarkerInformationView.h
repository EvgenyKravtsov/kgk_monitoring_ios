//
//  MarkerInformationView.h
//  KGK Monitoring
//
//  Created by Admin on 23/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerInformationView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lastActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *positioningLabel;
@property (weak, nonatomic) IBOutlet UILabel *satellitesLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastActionDate;
@property (weak, nonatomic) IBOutlet UILabel *lastPositioningDate;
@property (weak, nonatomic) IBOutlet UILabel *satellites;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *direction;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *voltage;
@property (weak, nonatomic) IBOutlet UILabel *batteryCharge;
@property (weak, nonatomic) IBOutlet UILabel *balance;

@end
