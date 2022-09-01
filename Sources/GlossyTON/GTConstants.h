//
//  GTConstants.h
//  
//
//  Created by Anton Spivak on 02.04.2022.
//

#import <Foundation/Foundation.h>

// GT_EXPORT
#if !defined(_GT_EXPORT)
#   if defined(__cplusplus)
#       define _GT_EXPORT extern "C" __attribute__((visibility ("default")))
#   else
#       define _GT_EXPORT extern __attribute__((visibility ("default")))
#   endif
#endif
#define GT_EXPORT _GT_EXPORT

// GT_SWIFT_ERROR
#if !defined(_GT_SWIFT_ERROR)
#   if __OBJC__ && __has_attribute(swift_error)
#       define _GT_SWIFT_ERROR __attribute__((swift_error(nonnull_error)));
#   else
#       abort();
#   endif
#endif
#define GT_SWIFT_ERROR _GT_SWIFT_ERROR

// GT_STATIC_INLINE
#define GT_STATIC_INLINE static inline

NS_ASSUME_NONNULL_BEGIN

GT_EXPORT NSErrorDomain const GTTONErrorDomain;
GT_EXPORT NSInteger const GTTONErrorCodeCancelled;

NS_ASSUME_NONNULL_END
