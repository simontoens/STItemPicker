// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

@protocol ItemPickerDataSource <NSObject>

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item;

/**
 * The view's title and the tab's title.
 */
@property(nonatomic, strong, readonly) NSString *title;

/**
 * Used as header image, return nil if no header image.
 */
@property(nonatomic, strong, readonly) UIImage *headerImage;

/**
 * The list of items displayed in the table view.
 */
@property(nonatomic, strong, readonly) NSArray *items;

/**
 * Return YES if items are sorted alphanumerically, NO otherwise.
 */
@property(nonatomic, assign, readonly) BOOL itemsAlreadySorted;

/**
 * Return YES to show section headers and a section index.
 */
@property(nonatomic, assign, readonly) BOOL sectionsEnabled;

/**
 * Return YES to skip intermediary item lists with only a single item.
 */
@property(nonatomic, assign, readonly) BOOL skipIntermediaryLists;

@end