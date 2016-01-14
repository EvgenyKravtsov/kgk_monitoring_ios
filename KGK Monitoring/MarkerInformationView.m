//
//  MarkerInformationView.m
//  KGK Monitoring
//
//  Created by Admin on 23/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "MarkerInformationView.h"

@implementation MarkerInformationView

- (instancetype)init {
    self = [super init];
    if (self) {
        UIView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"MarkerInformation" owner:self options:nil] objectAtIndex:0];
        [self addSubview:markerView];
        self.frame = markerView.frame;
    }
    return self;
}

@end
