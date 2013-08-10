// @author Simon Toens 03/18/13

#import <Foundation/Foundation.h>

@interface TableSectionHandler : NSObject

- (id)initWithItems:(NSArray *)items;

@property(nonatomic, strong, readonly) NSArray *items;
@property(nonatomic, strong, readonly) NSArray *sections;

@property(nonatomic, strong, readwrite) NSArray *itemAttributes;
@property(nonatomic, strong, readwrite) NSArray *itemDescriptions;
@property(nonatomic, strong, readwrite) NSArray *itemImages;

extern NSString *kTableSectionHandlerNumberHeader;
extern NSString *kTableSectionHandlerSymbolHeader;
extern NSString *kTableSectionHandlerNonLatinLetterSymbolHeader;

@end