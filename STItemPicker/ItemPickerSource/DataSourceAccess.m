// @author Simon Toens 05/16/13 on the way to KIX

#import "DataSourceAccess.h"
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerSection.h"
#import "Preconditions.h"
#import "TableSectionHandler.h"

@interface DataSourceAccess()
@property(nonatomic, assign) BOOL autoSelected;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, assign) BOOL showAllItemsRow;
@property(nonatomic, strong) NSArray *sections;
@property(nonatomic, strong) NSArray *sectionTitles;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@property(nonatomic, assign) NSRange currentRange;
@property(nonatomic, assign) NSUInteger dataSourceTotalItemCount;

- (void)buildDefaultSection;
- (void)buildSections;
- (void)buildSectionTitles;
- (NSInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath;
- (void)process;

@end

@implementation DataSourceAccess

static NSInteger kAllItemsRowIndex = -1;
static NSRange kUnsetRange;

@synthesize autoSelected = _autoSelected;
@synthesize currentRange = _currentRange;
@synthesize itemCache = _itemCache;
@synthesize dataSource = _dataSource;
@synthesize processed = _processed;
@synthesize sections = _sections;
@synthesize dataSourceTotalItemCount = _dataSourceTotalItemCount;
@synthesize sectionTitles;
@synthesize showAllItemsRow = _showAllItemsRow;
@synthesize tableSectionHandler = _tableSectionHandler;

+ (void)initialize
{
    kUnsetRange = NSMakeRange(0, 0);
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource autoSelected:(BOOL)autoSelected
{
    if (self = [super init])
    {
        _autoSelected = autoSelected;
        _currentRange = kUnsetRange;
        _dataSource = dataSource;
        _itemCache = [[ItemCache alloc] initForDataSource:dataSource];
        _processed = NO;
    }
    return self;
}

- (id<ItemPickerDataSource>)getDataSource
{
    return self.dataSource;
}

- (BOOL)getSectionsEnabled
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSource.sectionsEnabled;
}

- (NSUInteger)getCount
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSourceTotalItemCount;
}

- (NSString *)getTitle
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSource.title;
}

- (UIImage *)getTabImage
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSource.tabImage;
}

- (ItemPickerHeader *)getHeader
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSource.header;
}

- (BOOL)isLeaf
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSource.isLeaf;
}

- (id)getSection:(NSUInteger)index
{
    if (!_processed) 
    {
        [self process];
    }
    return [self.sections objectAtIndex:index];
}

- (NSArray *)getSectionTitles
{
    if (!_processed) 
    {
        [self process];
    }
    return self.sectionTitles;
}

- (NSString *)getItem:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    NSInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kAllItemsRowIndex)
    {
        return @"All Items ...";
    }
    
    if (_tableSectionHandler)
    {
        return [self.tableSectionHandler.items objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        return [_itemCache.items objectAtIndex:index];
    }
}

- (NSString *)getItemDescription:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    NSInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kAllItemsRowIndex)
    {
        return nil;
    }
    
    if (_tableSectionHandler)
    {
        return [_tableSectionHandler.itemDescriptions objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        return [_itemCache.descriptions objectAtIndex:index];
    }
}

- (UIImage *)getItemImage:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    NSInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kAllItemsRowIndex)
    {
        return nil;
    }
    
    id image = nil;
    if (_tableSectionHandler)
    {
        image = [_tableSectionHandler.itemImages objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        return [_itemCache.images objectAtIndex:index];
    }
    
    return image == [NSNull null] ? nil : image;
}

- (ItemAttributes *)getItemAttributes:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    NSInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kAllItemsRowIndex)
    {
        return nil;
    }
    
    if (_tableSectionHandler)
    {
        return [_tableSectionHandler.itemAttributes objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        return [_itemCache.attributes objectAtIndex:index];
    }
}

- (BOOL)selectedShowAllItems:(ItemPickerSelection *)selection
{
    return self.showAllItemsRow && selection.selectedIndex == kAllItemsRowIndex;
}

- (id<ItemPickerDataSource>)getUnwrappedDataSource
{
    // and so the abstraction begins to break down...
    return [self.dataSource isKindOfClass:[ItemPickerDataSourceDefaults class]] ? 
        ((ItemPickerDataSourceDefaults *)self.dataSource).dataSource : self.dataSource;
}

- (ItemPickerSelection *)getItemPickerSelection:(NSIndexPath *)indexPath
{
    NSUInteger selectedIndex = [self convertIndexPathToArrayIndex:indexPath];
    return [[ItemPickerSelection alloc] initWithDataSource:[self getUnwrappedDataSource]
                                             selectedIndex:selectedIndex
                                              selectedItem:[self getItem:indexPath]
                                              autoSelected:self.autoSelected
                                          selectedAllItems:selectedIndex == kAllItemsRowIndex];
}

- (void)process
{
    [Preconditions assert:!self.processed message:@"processed should be false"];
    
    self.processed = YES;
    
    id<ItemPickerDataSource> ds = self.dataSource;    
    self.showAllItemsRow = !ds.isLeaf && !self.autoSelected && ds.allowDrilldownToAllReachableItems;
    self.dataSourceTotalItemCount = ds.count + (self.showAllItemsRow ? 1 : 0);
    
    if (self.dataSource.sectionsEnabled)
    {
        self.sections = self.dataSource.sections;
        if (!self.sections)
        {
            [self buildSections];
        }
    }
    
    if (!self.sections)
    {
        [self buildDefaultSection];
    }
    
    [self buildSectionTitles];
}

- (NSArray *)getFixedSections
{
    return self.showAllItemsRow ? 
    [NSArray arrayWithObject:[[ItemPickerSection alloc] initWithTitle:@"" range:NSMakeRange(0, 1)]] : [NSArray array];
}

- (void)buildSections
{
    NSRange allItemsRange = NSMakeRange(0, self.dataSource.count);
    [self.dataSource initForRange:allItemsRange];
    
    NSArray *fixedSections = [self getFixedSections];
    
    self.tableSectionHandler = [[TableSectionHandler alloc] initWithItems:[self.dataSource getItemsInRange:allItemsRange] 
                                                            sectionOffset:[fixedSections count]];
    self.tableSectionHandler.itemDescriptions = [self.dataSource getItemDescriptionsInRange:allItemsRange];
    self.tableSectionHandler.itemImages = [self.dataSource getItemImagesInRange:allItemsRange];
    self.tableSectionHandler.itemAttributes = [self.dataSource getItemAttributesInRange:allItemsRange];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[fixedSections count] + [self.tableSectionHandler.sections count]];
    [sections addObjectsFromArray:fixedSections];
    [sections addObjectsFromArray:self.tableSectionHandler.sections];
    self.sections = sections;
}

- (void)buildDefaultSection
{
    ItemPickerSection *defaultSection = [[ItemPickerSection alloc] initWithTitle:@"" range:NSMakeRange(0, self.dataSourceTotalItemCount)];
    self.sections = [NSArray arrayWithObject:defaultSection];
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
    NSInteger index = row + indexPath.row;
    
    if (self.showAllItemsRow)
    {
        return index == 0 ? kAllItemsRowIndex : index - 1;
    }
    
    return index;
}

@end