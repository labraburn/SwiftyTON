//
//  GTEncryptedData.m
//  
//
//  Created by Anton Spivak on 17.02.2022.
//

#import "GTEncryptedData.h"

@implementation GTEncryptedData

- (instancetype)initWithSourceAccountAddress:(NSString *)sourceAccountAddress
                                        data:(NSData *)data
{
    self = [super init];
    if (self != nil) {
        _sourceAccountAddress = [sourceAccountAddress copy];
        _data = [data copy];
    }
    return self;
}

@end
