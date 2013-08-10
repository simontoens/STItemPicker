// @author Simon Toens 05/16/13 on the way to KIX

#import "DataSourceAccess.h"
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerSection.h"
#import "Preconditions.h"
#import "TableSectionHandler.h"

@interface DataSourceAccess()
@property(nonatomic, assign) BOOL autoSelected;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) NSString *metaCellTitle;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, strong) NSArray *sections;
@property(nonatomic, strong) NSArray *sectionTitles;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@property(nonatomic, assign) NSRange currentRange;
@property(nonatomic, assign) NSUInteger dataSourceTotalItemCount;

- (void)addFixedSections;
- (void)buildDefaultSection;
- (void)buildSections;
- (void)buildSectionTitles;
- (NSUInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath;
- (void)process;

@end

@implementation DataSourceAccess

static NSUInteger kAllItemsRowIndex = NSUIntegerMax;
static NSRange kUnsetRange;

@synthesize autoSelected = _autoSelected;
@synthesize currentRange = _currentRange;
@synthesize itemCache = _itemCache;
@synthesize dataSource = _dataSource;
@synthesize metaCellTitle;
@synthesize processed = _processed;
@synthesize sections = _sections;
@synthesize dataSourceTotalItemCount = _dataSourceTotalItemCount;
@synthesize sectionTitles;
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
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kAllItemsRowIndex)
    {
        return self.dataSource.metaCellTitle;
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
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
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
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
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
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
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
                                                  metaCell:selectedIndex == kAllItemsRowIndex];
}

- (void)process
{
    [Preconditions assert:!self.processed message:@"processed should be false"];
    
    self.processed = YES;
        
    id<ItemPickerDataSource> ds = self.dataSource;
    self.metaCellTitle = ds.metaCellTitle;
    self.dataSourceTotalItemCount = ds.count + (self.metaCellTitle ? 1 : 0);
    
    if (self.dataSource.sectionsEnabled)
    {
        self.sections = self.dataSource.sections;
        if (!self.sections)
        {
            [self buildSections];
        }
        [self addFixedSections];
    }
    else 
    {
        [self buildDefaultSection];
    }
    
    [self buildSectionTitles];
}

- (void)addFixedSections
{
    if (self.metaCellTitle)
    {
        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[self.sections count] + 1];
        [sections addObject:[[ItemPickerSection alloc] initWithTitle:@"" range:NSMakeRange(0, 1)]];
        [sections addObjectsFromArray:self.sections];
        self.sections = sections;
    }
}

- (void)buildSections
{
    NSRange allItemsRange = NSMakeRange(0, self.dataSource.count);
    [self.dataSource initForRange:allItemsRange];
        
    self.tableSectionHandler = [[TableSectionHandler alloc] initWithItems:[self.dataSource getItemsInRange:allItemsRange]]; 
    self.tableSectionHandler.itemDescriptions = [self.dataSource getItemDescriptionsInRange:allItemsRange];
    self.tableSectionHandler.itemImages = [self.dataSource getItemImagesInRange:allItemsRange];
    self.tableSectionHandler.itemAttributes = [self.dataSource getItemAttributesInRange:allItemsRange];
    self.sections = self.tableSectionHandler.sections;
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

- (NSUInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath
{
    NSUInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSRange range = [[self.sections objectAtIndex:i] range];
        row += range.length;
    }
    NSUInteger index = row + indexPath.row;
    
    if (self.metaCellTitle && !self.autoSelected)
    {
        return index == 0 ? kAllItemsRowIndex : index - 1;
    }
        
    return index;
}

@end