//
//  SCSSniqueWebViewExtractor.m
//  snique
//
//  Created by Philip Willoughby on 07/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSSniqueWebViewExtractor.h"
#import "SCSCache.h"
#import "NSData+SCSSnique.h"

@implementation SCSSniqueWebViewExtractor

-(void)extractMessageFromWebView:(UIWebView *)wv withDecoder:(SCSSniqueDecoder *)decoder actionIfFound:(void (^)(NSString *message))actionIfFound
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSString *theHtml = [wv stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;"];
    NSRegularExpression *srcRegex = [[NSRegularExpression alloc] initWithPattern:@"src\\s*=\\s*['\"]([^'\"]*)['\"]"
                                                                         options:0
                                                                           error:nil];
    actionIfFound = [actionIfFound copy];
    [srcRegex enumerateMatchesInString:theHtml
                               options:0
                                 range:NSMakeRange(0, theHtml.length)
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSString *src = [theHtml substringWithRange:[result rangeAtIndex:1]];
         if (src.length)
         {
             NSURL *url = [NSURL URLWithString:src];
             NSString *eTag = [(SCSCache *)[NSURLCache sharedURLCache] etagForResourceAtLocation:url];
             if (eTag)
             {
                 NSData *etagData = [NSData scsHexDataFromString:eTag];
                 if (etagData.length)
                 {
                     [indexes addIndex:data.length];
                     [data appendData:etagData];
                 }
             }
         }
     }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       NSString *decoded = [decoder decodeData:[data copy] withStartIndexes:indexes];
                       if (decoded)
                       {
                           actionIfFound(decoded);
                       }
                   });
}

@end
