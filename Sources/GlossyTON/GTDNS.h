//
//  GTDNS.h
//  
//
//  Created by Anton Spivak on 09.07.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - GTDNSEntry

@protocol GTDNSEntry <NSObject>
@end

#pragma mark - GTDNSEntryText

@interface GTDNSEntryText : NSObject <GTDNSEntry>

@property (nonatomic, strong, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

#pragma mark - GTDNSEntrySMCAddress

@interface GTDNSEntrySMCAddress : NSObject <GTDNSEntry>

@property (nonatomic, strong, readonly) NSString *address;

- (instancetype)initWithAddress:(NSString *)address;

@end

#pragma mark - GTDNSEntryNextResolver

@interface GTDNSEntryNextResolver : NSObject <GTDNSEntry>

@property (nonatomic, strong, readonly) NSString *address;

- (instancetype)initWithAddress:(NSString *)address;

@end

#pragma mark - GTDNS

@interface GTDNS : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray<GTDNSEntry> *entries;

- (instancetype)initWithName:(NSString *)name
                     entries:(NSArray<GTDNSEntry> *)entries;

@end

NS_ASSUME_NONNULL_END
