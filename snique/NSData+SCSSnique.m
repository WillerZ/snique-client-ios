//
//  NSData+SCSSnique.m
//  snique
//
//  Created by Philip Willoughby on 07/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "NSData+SCSSnique.h"

@implementation NSData (SCSSnique)

+(NSData *)scsHexDataFromString:(NSString *)string
{
    NSData *hexData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSMutableData *data = [[NSMutableData alloc] initWithLength:1 + hexData.length/2];
    unsigned char *out = data.mutableBytes;
    const unsigned char *in = hexData.bytes;
    NSUInteger hexIndex = 0;
    for (NSUInteger i = 0,j = 0; i < hexData.length; ++i)
    {
        unsigned char half = 0;
        switch (in[i])
        {
            case 'f': case 'F': half = 0xfu; break;
            case 'e': case 'E': half = 0xeu; break;
            case 'd': case 'D': half = 0xdu; break;
            case 'c': case 'C': half = 0xcu; break;
            case 'b': case 'B': half = 0xbu; break;
            case 'a': case 'A': half = 0xau; break;
            case '9': half = 9u; break;
            case '8': half = 8u; break;
            case '7': half = 7u; break;
            case '6': half = 6u; break;
            case '5': half = 5u; break;
            case '4': half = 4u; break;
            case '3': half = 3u; break;
            case '2': half = 2u; break;
            case '1': half = 1u; break;
            case '0': half = 0u; break;
            default:
                continue;
        }
        if (hexIndex & 1)
        {
            out[j] |= half;
            ++j;
        }
        else
        {
            out[j] = half << 4;
        }
        ++hexIndex;
    }
    data.length = hexIndex >>1;
    return [data copy];
}

@end
