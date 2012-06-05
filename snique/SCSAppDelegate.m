//
//  SCSAppDelegate.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSAppDelegate.h"
#import "SCSMainViewController.h"

@implementation SCSAppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    unsigned char keyRaw[] =
    {
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff
    };
    NSData *keyData = [NSData dataWithBytesNoCopy:keyRaw length:sizeof(keyRaw) freeWhenDone:NO];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:keyData
                                                                                        forKey:kSecretKeyKey]];
    [NSURLCache setSharedURLCache:[[SCSCache alloc] initWithMemoryCapacity:2048*1024 diskCapacity:0 diskPath:nil]];
    return YES;
}

@end
