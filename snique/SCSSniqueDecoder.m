//
//  SCSSniqueDecoder.m
//  snique
//
//  Created by Philip Willoughby on 04/06/2012.
//  Copyright (c) 2012 StrawberryCat. All rights reserved.
//

#import "SCSSniqueDecoder.h"
#import <CommonCrypto/CommonCryptor.h>

@interface SCSSniqueDecoder ()
@property(readwrite,copy,nonatomic)NSData *keyRaw;
-(NSString *)decodeWithIV:(NSData *)ivRaw message:(NSData *)flat;
@end

@implementation SCSSniqueDecoder
@synthesize keyRaw;

-(id)initWithKey:(NSData *)rawKey
{
    self = [super init];
    if (self)
    {
        self.keyRaw = rawKey;
    }
    return self;
}

-(NSString *)decodeMessage:(NSArray *)coded
{
    NSUInteger blockSize = keyRaw.length;
    NSMutableData *ivRaw = [NSMutableData dataWithLength:blockSize];
    while (coded.count > 0)
    {
        int ivIndex = 0;
        NSArray *remCoded = [coded copy];
        coded = [coded subarrayWithRange:NSMakeRange(1, coded.count - 1)];
        while (ivIndex < blockSize)
        {
            NSData *first = [remCoded objectAtIndex:0];
            remCoded = [remCoded subarrayWithRange:NSMakeRange(1,remCoded.count - 1)];
            if (remCoded.count == 0)
                goto doneOuter;
            unsigned char *ivBytes = ivRaw.mutableBytes;
            const unsigned char *firstBytes = first.bytes;
            for (int i = 0; i < first.length && ivIndex < blockSize; ++i, ++ivIndex)
                ivBytes[ivIndex] = firstBytes[i];
        }
        NSMutableData *flat = [[NSMutableData alloc] init];
        for (NSData *fragment in remCoded)
            [flat appendData:fragment];
        flat.length = ((flat.length / blockSize) * blockSize);
        if (flat.length == 0)
            goto doneOuter;
        NSString *decoded = [self decodeWithIV:ivRaw message:flat];
        if (decoded.length)
            return decoded;
    }
doneOuter:
    return nil;
}

-(NSString *)decodeWithIV:(NSData *)ivRaw message:(NSData *)data
{
    NSMutableData *decoded = [[NSMutableData alloc] initWithLength:data.length + 32];
    size_t decodedLength = 0;
    size_t firstDecodedLength = 0;
    size_t finalBlockLength = 0;
    CCCryptorStatus cs;
    CCCryptorRef cryptor;
    cs = CCCryptorCreate(kCCDecrypt, kCCAlgorithmAES128, 0, keyRaw.bytes, keyRaw.length, ivRaw.bytes, &cryptor);
    NSAssert1(cs == kCCSuccess,@"CCCryptorCreate failed %d",cs);
    cs = CCCryptorUpdate(cryptor, [data bytes], 32, decoded.mutableBytes, decoded.length, &firstDecodedLength);
    if (cs == kCCSuccess)
    {
        struct {uint32_t eyecatcher; uint32_t length;} *hdr = decoded.mutableBytes;
        uint32_t eyecatcher = CFSwapInt32BigToHost(hdr->eyecatcher);
        uint32_t length = CFSwapInt32BigToHost(hdr->length);
        if (eyecatcher == 0xFACEF00DU)
        {
            cs = CCCryptorUpdate(cryptor, [data bytes] + 32, [data length] - 32, decoded.mutableBytes + firstDecodedLength, decoded.length - firstDecodedLength, &decodedLength);
            NSAssert1(cs == kCCSuccess,@"CCCryptorUpdate failed %d",cs);
            decodedLength += firstDecodedLength;
            cs = CCCryptorFinal(cryptor, decoded.mutableBytes + decodedLength, decoded.length - decodedLength, &finalBlockLength);
            decodedLength += finalBlockLength;
            decoded.length = decodedLength;
            NSRange messageRange = { 8, length };
            return [[NSString alloc] initWithData:[decoded subdataWithRange:messageRange]
                                         encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

@end
