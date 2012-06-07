//
//  SCSSniqueDecoder.h
//  snique
//
//  Created by Philip Willoughby on 04/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCSSniqueDecoder : NSObject

-(id)initWithKey:(NSData *)rawKey;

-(NSString *)decodeData:(NSData *)data withStartIndexes:(NSIndexSet *)indexes;

@end
