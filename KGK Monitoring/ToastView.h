//
//  ToastView.h
//  KGK Monitoring
//
//  Created by Admin on 11/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) NSString *text;

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(float)duration;

@end
