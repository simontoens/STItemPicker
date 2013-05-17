// @author Simon Toens 05/16/13 on the way to KIX

#import "DataSourceAccess.h"
#import "ItemPickerSection.h"
#import "TableSectionHandler.h"

@interface DataSourceAccess()
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *itemImages;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, strong) NSArray *sections;
@property(nonatomic, strong) NSArray *sectionTitles;

- (void)buildDefaultSection;
- (void)buildSections;
- (void)buildSectionTitles;
- (NSInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath;
- (void)process;

@end

@implementation DataSourceAccess

@synthesize dataSource = _dataSource;
@synthesize items = _items;
@synthesize itemImages;
@synthesize sections = _sections;
@synthesize sectionTitles;
@synthesize processed = _processed;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super init])
    {
        _dataSource = dataSource;
        _processed = NO;
    }
    return self;
}

- (id)getSection:(NSUInteger)index
{
    [self process];
    return [self.sections objectAtIndex:index];
}

- (NSString *)getItem:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    if (self.items)
    {
        return [self.items objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        return [[self.dataSource getItemsInRange:range] lastObject];
    }
}

- (NSArray *)getSectionTitles
{
    [self process];
    return self.sectionTitles;
}

- (UIImage *)getItemImage:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    id image = nil;
    if (self.itemImages)
    {
        image = [self.itemImages objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        image = [[self.dataSource getItemImagesInRange:range] lastObject];
    }
    
    return image == [NSNull null] ? nil : image;
}

- (ItemPickerContext *)getItemPickerContext:(NSIndexPath *)indexPath autoSelected:(BOOL)autoSelected
{
    ItemPickerContext *ctx = [[ItemPickerContext alloc] initWithDataSource:self.dataSource];
    ctx.selectedIndex = [self convertIndexPathToArrayIndex:indexPath];
    ctx.selectedItem = [self getItem:indexPath];
    ctx.autoSelected = autoSelected;
    return ctx;
}

- (void)process
{
    if (self.processed)
    {
        return;
    }
    self.processed = YES;
    self.sections = self.dataSource.sections;
    if (!self.sections)
    {
        if (self.dataSource.sectionsEnabled)
        {
            [self buildSections];
        }
        else
        {
            [self buildDefaultSection];
        }
    }

    [self buildSectionTitles];
}

- (void)buildSections
{
    NSRange range = NSMakeRange(0, self.dataSource.count);
    NSArray *allItems = [self.dataSource getItemsInRange:range];
    TableSectionHandler *sectionHandler = [[TableSectionHandler alloc] initWithItems:allItems];
    NSArray *allImages = [self.dataSource getItemImagesInRange:range];
    sectionHandler.itemImages = allImages;
    self.items = sectionHandler.items;
    self.itemImages = sectionHandler.itemImages;
    self.sections = sectionHandler.sections;
}

- (void)buildDefaultSection
{
    self.sections = [NSArray arrayWithObject:[[ItemPickerSection alloc] 
                                              initWithTitle:@"" range:NSMakeRange(0, self.dataSource.count)]];
}

- (void)buildSectionTitles
{
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[self.sections count]];
    for (id section in self.sections)
    {
        [titles addObject:[section title]];
    }
    self.sectionTitles = titles;
}

- (NSInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSRange range = [[self.sections objectAtIndex:i] range];
        row += range.length;
    }
    return row + indexPath.row;
}

@end