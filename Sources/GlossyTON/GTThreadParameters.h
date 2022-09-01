//
//  GTThreadParameters.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>
#import "GlossyTON.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GTThreadParametersReceiveHandler)(tonlib::Client::Response & response);

@interface GTThreadParameters : NSObject

@property (nonatomic, readonly) std::shared_ptr<tonlib::Client> client;
@property (nonatomic, copy, readonly) GTThreadParametersReceiveHandler handler;

- (instancetype)initWithClient:(std::shared_ptr<tonlib::Client>)client
                       handler:(GTThreadParametersReceiveHandler)handler;

@end

NS_ASSUME_NONNULL_END
