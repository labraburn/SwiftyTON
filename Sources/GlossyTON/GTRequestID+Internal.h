//
//  GTRequestID+Internal.h
//  
//
//  Created by Anton Spivak on 01.04.2022.
//

#import "GTRequestID.h"

NS_ASSUME_NONNULL_BEGIN

@interface GTRequestID (Internal)

@property (nonatomic, strong, readonly) NSNumber *number;

- (instancetype)initWithNumber:(NSNumber *)number;

@end

NS_ASSUME_NONNULL_END
