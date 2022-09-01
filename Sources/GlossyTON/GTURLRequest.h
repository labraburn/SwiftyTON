//
//  GTURLRequest.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GTURLRequestDidFinishBlock)(NSData * _Nullable response, NSError * _Nullable error);

@interface GTURLRequest : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, copy, readonly) GTURLRequestDidFinishBlock didFinishBlock;

- (instancetype)initWithData:(NSData *)data didFinishBlock:(GTURLRequestDidFinishBlock)didFinishBlock;

@end

NS_ASSUME_NONNULL_END
