//
//  Created by Anton Spivak
//

#import <Foundation/Foundation.h>
#import <tonlib/Client.h>

#import "GTConstants.h"

@class GTTransactionMessage;

#define weakify(value) try {} @finally {} __weak __typeof__(value) value_weak_ = (value);
#define strongify(value) try {} @finally {} __strong __typeof__(value) value = (value_weak_);

GT_EXPORT std::string GTStringWithData(NSData * _Nonnull data);
GT_EXPORT NSData * _Nonnull GTDataWithString(std::string &string);
GT_EXPORT NSString * _Nullable GTReadStringWithString(std::string & string);

GT_EXPORT td::SecureString GTSecureStringWithData(NSData * _Nonnull data);
GT_EXPORT NSData * _Nullable GTReadSecureStringWithString(td::SecureString & string);

GT_EXPORT NSData * _Nullable GTDecryptedDataWithEncryptedData(tonlib::Client & client, NSData * _Nonnull encryptedData, NSData * _Nonnull secret);
GT_EXPORT NSData * _Nonnull GTEncryptedDataWithData(tonlib::Client & client, NSData * _Nonnull data, NSData * _Nonnull secret);

GT_EXPORT GTTransactionMessage * _Nullable GTTransactionMessageCreate(tonlib_api::object_ptr<tonlib_api::raw_message> &message);
