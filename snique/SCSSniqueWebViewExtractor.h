//
//  SCSSniqueWebViewExtractor.h
//  snique
//
//  Created by Philip Willoughby on 07/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSSniqueDecoder.h"

@interface SCSSniqueWebViewExtractor : NSObject
-(void)extractMessageFromWebView:(UIWebView *)wv withDecoder:(SCSSniqueDecoder *)decoder actionIfFound:(void (^)(NSString *message))actionIfFound;
@end
