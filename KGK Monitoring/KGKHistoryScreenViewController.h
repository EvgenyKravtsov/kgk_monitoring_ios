//
//  KGKHistoryScreenViewController.h
//  KGK Monitoring
//
//  Created by Admin on 10/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KGKHistoryScreenViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (IBAction)goToPeriod:(id)sender;
- (IBAction)goToTrack:(id)sender;

@end
