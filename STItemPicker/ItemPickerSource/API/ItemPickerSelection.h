// @author Simon Toens 03/30/13

#import <Foundation/Foundation.h>

@protocol ItemPickerDataSource;

/**
 * Interesting information about a single selection.
 */
@interface ItemPickerSelection : NSObject <NSCopying>

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
           selectedIndex:(NSUInteger)index 
            selectedItem:(NSString *)item 
            autoSelected:(BOOL)autoSelected;

@property(nonatomic, assign, readonly) BOOL autoSelected;
@property(nonatomic, strong, readonly) id<ItemPickerDataSource>dataSource;
@property(nonatomic, assign, readonly) NSUInteger selectedIndex;
@property(nonatomic, strong, readonly) NSString *selectedItem;

@end