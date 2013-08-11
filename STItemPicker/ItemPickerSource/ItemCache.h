// @author Simon Toens 07/12/13

#import <Foundation/Foundation.h>
#import "ItemPickerDataSource.h"

/**
 * Responsible for caching a subset of items loaded from the datasource.
 */
@interface ItemCache : NSObject

- (id)initForDataSource:(id<ItemPickerDataSource>)dataSource;

- (NSUInteger)ensureAvailability:(NSUInteger)index;

@property(nonatomic) NSUInteger size;

@property(nonatomic, strong, readonly) NSArray *attributes;
@property(nonatomic, strong, readonly) NSArray *items;
@property(nonatomic, strong, readonly) NSArray *images;
@property(nonatomic, strong, readonly) NSArray *descriptions;

- (void)invalidate;

@end