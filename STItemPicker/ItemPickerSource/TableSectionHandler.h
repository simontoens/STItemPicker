// @author Simon Toens 03/18/13

#import <Foundation/Foundation.h>

@interface TableSectionHandler : NSObject

- (id)initWithItems:(NSArray *)items;
- (id)initWithItems:(NSArray *)items sections:(NSArray *)sections;

/**
 * If YES, creates alphabetical sections based on the first letter of each item.
 *
 * Defaults to NO.
 */
@property(nonatomic, assign) BOOL sectionsEnabled;

@property(nonatomic, strong, readonly) NSArray *items;
@property(nonatomic, strong, readonly) NSArray *sections;
@property(nonatomic, strong, readonly) NSArray *sectionTitles;

@property(nonatomic, strong, readwrite) NSArray *itemImages;


extern NSString *kTableSectionHandlerNumberHeader;
extern NSString *kTableSectionHandlerSymbolHeader;
extern NSString *kTableSectionHandlerNonLatinLetterSymbolHeader;

@end