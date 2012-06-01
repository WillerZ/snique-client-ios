//
//  SCSCache.h
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSCache : NSURLCache
{
    NSMutableDictionary *etags;
}

-(NSString *)etagForResourceAtLocation:(NSURL *)url;
@end
