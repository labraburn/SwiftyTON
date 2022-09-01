//
//  GTTONConfiguration.h
//  
//
//  Created by Anton Spivak on 31.01.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GTTONConfigurationLogging) {
    GTTONConfigurationLoggingPlain      = -1,
    GTTONConfigurationLoggingFatal      = 0,
    GTTONConfigurationLoggingError      = 1,
    GTTONConfigurationLoggingWarning    = 2,
    GTTONConfigurationLoggingInfo       = 3,
    GTTONConfigurationLoggingDebug      = 4,
    GTTONConfigurationLoggingNever      = 1024,
};

@interface GTTONConfiguration : NSObject

@property (nonatomic, copy, readonly) NSString *networkName;
@property (nonatomic, copy, readonly) NSString *JSONString;
@property (nonatomic, copy, readonly) NSURL *keystoreURL;
@property (nonatomic, assign, readonly) GTTONConfigurationLogging logging;

- (instancetype)initWithNetworkName:(NSString *)networkName
                         JSONString:(NSString *)JSONString
                        keystoreURL:(NSURL *)keystoreURL
                            logging:(GTTONConfigurationLogging)logging;

@end

NS_ASSUME_NONNULL_END
