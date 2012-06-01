//
//  SCSAppDelegate.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSAppDelegate.h"

@implementation SCSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSURLCache setSharedURLCache:[[SCSCache alloc] initWithMemoryCapacity:2048*1024 diskCapacity:0 diskPath:nil]];
    return YES;
}

@end
