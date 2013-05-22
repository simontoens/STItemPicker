// @author Simon Toens 03/30/13

#import <Foundation/Foundation.h>

@protocol ItemPickerDataSource;

/**
 * Interesting pieces of information about a single selection.
 * 
 * TODO: Make properties readonly.
 */
@interface ItemPickerContext : NSObject <NSCopying>

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@property(nonatomic, strong, readonly) id<ItemPickerDataSource>dataSource;
@property(nonatomic, assign) NSUInteger selectedIndex;
@property(nonatomic, strong) NSString *selectedItem;
@property(nonatomic, assign) BOOL autoSelected;

@end