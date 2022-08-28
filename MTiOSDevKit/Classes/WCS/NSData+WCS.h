//
//  NSData+WCS.h
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (WCS_ETAG)
- (NSString *)wcs_etag;

- (UInt32)commonCrc32;

@end

NS_ASSUME_NONNULL_END






