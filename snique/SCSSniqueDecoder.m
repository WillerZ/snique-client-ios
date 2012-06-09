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

-(NSString *)decodeData:(NSData *)data withStartIndexes:(NSIndexSet *)indexes
{
    NSUInteger blockSize = keyRaw.length;
    for (NSUInteger currentIndex = 0; currentIndex != NSNotFound; currentIndex = [indexes indexGreaterThanIndex:currentIndex])
    {
        if (data.length < (currentIndex + blockSize + blockSize))
            break;
        NSRange ivRange = { currentIndex, blockSize };
        NSRange dataRange = { currentIndex + blockSize, data.length - blockSize - currentIndex };
        dataRange.length = (dataRange.length / blockSize) * blockSize;
        NSData *ivRaw = [data subdataWithRange:ivRange];
        NSData *flat = [data subdataWithRange:dataRange];
        NSAssert(flat.length, @"Need at least one block of data to decode");
        NSString *decoded = [self decodeWithIV:ivRaw message:flat];
        if (decoded.length)
            return decoded;
    }
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
            CCCryptorFinal(cryptor, decoded.mutableBytes + decodedLength, decoded.length - decodedLength, &finalBlockLength);
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
