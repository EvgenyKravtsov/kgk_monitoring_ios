//
//  KGKInformationScreenViewController.h
//  KGK Monitoring
//
//  Created by Admin on 05/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface KGKInformationScreenViewController : UIViewController<GMSMapViewDelegate>

- (IBAction)goToSettingsMenu:(id)sender;
- (IBAction)goToMap:(id)sender;
- (IBAction)goToHistory:(id)sender;
- (IBAction)query:(id)sender;
- (IBAction)search:(id)sender;

@end
