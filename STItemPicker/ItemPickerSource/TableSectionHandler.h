// @author Simon Toens 03/18/13

#import <Foundation/Foundation.h>

@interface TableSectionHandler : NSObject

- (id)initWithItems:(NSArray *)items alreadySorted:(BOOL)alreadySorted;

/**
 * If YES, sorts items (unless already sorted) and creates alphabetical sections based on the first letter of each item.
 * If NO, there's a single section with all items.
 *
 * Defaults to YES.
 */
@property(nonatomic, assign) BOOL sectionsEnabled;

@property(nonatomic, strong, readonly) NSArray *items;
@property(nonatomic, strong, readonly) NSArray *sections;
@property(nonatomic, strong, readonly) NSDictionary *sectionToNumberOfItems;

extern NSString *kTableSectionHandlerNumberHeader;
extern NSString *kTableSectionHandlerSymbolHeader;

@end