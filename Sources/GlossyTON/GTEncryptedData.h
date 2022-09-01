//
//  GTEncryptedData.h
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTEncryptedData : NSObject

@property (nonatomic, strong, readonly) NSString *sourceAccountAddress;
@property (nonatomic, copy, readonly) NSData *data;

- (instancetype)initWithSourceAccountAddress:(NSString *)sourceAccountAddress
                                        data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
