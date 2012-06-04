//
//  SCSCache.m
//  snique
//
//  Created by Philip Willoughby on 01/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSCache.h"

@implementation SCSCache

-(id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path
{
    self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path];
    if (self)
    {
        etags = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request
{
    [super storeCachedResponse:cachedResponse forRequest:request];
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)[cachedResponse response];
    if ([httpResp respondsToSelector:@selector(allHeaderFields)])
    {
        NSDictionary *headers = [httpResp allHeaderFields];
        for (NSString *key in headers)
        {
            if ([key compare:@"etag" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                [etags setObject:[headers objectForKey:key] forKey:request.URL.standardizedURL.absoluteString];
        }
    }
}

-(NSString *)etagForResourceAtLocation:(NSURL *)url
{
    return [etags objectForKey:url.standardizedURL.absoluteString];
}

@end
