//
//  NSData+WCS.m
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/26.
//

#import "NSData+WCS.h"
#import "WCSGTMStringEncoding.h"
#import <CommonCrypto/CommonCrypto.h>
#import <zlib.h>

static const UInt32 kWCSBlockSize = 4 * 1024 * 1024;

@implementation NSData (WCS_ETAG)
- (NSString *)wcs_etag{
    if (self == nil || [self length] == 0) {
        return @"Fto5o-5ea0sNMlW_75VgGJCv2AcJ";
    }
    int len = (int)[self length];
    int count = (len + kWCSBlockSize - 1) / kWCSBlockSize;
    
    NSMutableData *retData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH + 1];
    UInt8 *ret = [retData mutableBytes];
    
    NSMutableData *blocksSha1 = nil;
    UInt8 *pblocksSha1 = ret + 1;
    if (count > 1) {
        blocksSha1 = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH * count];
        pblocksSha1 = [blocksSha1 mutableBytes];
    }
    
    for (int i = 0; i < count; i++) {
        int offset = i * kWCSBlockSize;
        int size = (len - offset) > kWCSBlockSize ? kWCSBlockSize : (len - offset);
        NSData *d = [self subdataWithRange:NSMakeRange(offset, (unsigned int)size)];
        CC_SHA1([d bytes], (CC_LONG)size, pblocksSha1 + i * CC_SHA1_DIGEST_LENGTH);
    }
    if (count == 1) {
        ret[0] = 0x16;
    }
    else {
        ret[0] = 0x96;
        CC_SHA1(pblocksSha1, (CC_LONG)CC_SHA1_DIGEST_LENGTH * count, ret + 1);
    }
    return [[WCSGTMStringEncoding rfc4648Base64WebsafeStringEncoding] encode:retData];
}

- (UInt32)commonCrc32{
    uLong crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, [self bytes], (uInt)[self length]);
    return (UInt32)crc;
}

@end
