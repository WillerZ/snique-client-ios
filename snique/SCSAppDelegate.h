//
//  SCSAppDelegate.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSCache.h"

@interface SCSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL ignoreNextLocalNotification;

@end
