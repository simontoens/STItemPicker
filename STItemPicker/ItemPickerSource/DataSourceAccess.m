// @author Simon Toens 05/16/13 on the way to KIX

#import "DataSourceAccess.h"
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerSection.h"
#import "NoItemsDataSource.h"
#import "Preconditions.h"
#import "TableSectionHandler.h"

@interface DataSourceAccess()
@property(nonatomic, assign) BOOL autoSelected;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, strong) NSString *metaCellDescription;
@property(nonatomic, strong) ItemCache *itemCache;
@property(nonatomic, strong) NSString *metaCellTitle;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, strong) NSArray *sections;
@property(nonatomic, strong) NSArray *sectionTitles;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@property(nonatomic, assign) NSUInteger dataSourceItemCount;
@property(nonatomic, assign) NSUInteger dataSourceInternalItemCount;

@end

@implementation DataSourceAccess

static NSUInteger kMetaCellRowIndex = NSUIntegerMax;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource autoSelected:(BOOL)autoSelected
{
    if (self = [super init])
    {
        _autoSelected = autoSelected;
        _dataSource = dataSource;
        _itemCacheSize = [ItemCache defaultSize];
        _processed = NO;
    }
    return self;
}

- (id<ItemPickerDataSource>)getDataSource
{
    if (!_processed) 
    {
        [self process];
    }
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

- (NSUInteger)getDataSourceItemCount
{
    if (!_processed) 
    {
        [self process];
    }
    return self.dataSourceItemCount;
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

- (BOOL)isLeafAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    ItemAttributes *attrs = [self getItemAttributes:indexPath];
    
    return attrs && attrs.isLeafItem ? [attrs.isLeafItem boolValue] : self.dataSource.isLeaf;
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
    
    if (index == kMetaCellRowIndex)
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
    
    if (index == kMetaCellRowIndex)
    {
        return _metaCellDescription;
    }
    
    id desc = nil;
    if (_tableSectionHandler)
    {
        desc = [_tableSectionHandler.itemDescriptions objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        desc = [_itemCache.descriptions objectAtIndex:index];
    }
    return desc == [NSNull null] ? nil : desc;
}

- (UIImage *)getItemImage:(NSIndexPath *)indexPath
{
    if (!_processed) 
    {
        [self process];
    }
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    
    if (index == kMetaCellRowIndex)
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
        image = [_itemCache.images objectAtIndex:index];
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
    
    if (index == kMetaCellRowIndex)
    {
        return nil;
    }
    
    id attrs = nil;
    
    if (_tableSectionHandler)
    {
        attrs = [_tableSectionHandler.itemAttributes objectAtIndex:index];
    }
    else
    {
        index = [_itemCache ensureAvailability:index];
        attrs = [_itemCache.attributes objectAtIndex:index];
    }
    return attrs == [NSNull null] ? nil : attrs;
}

- (id<ItemPickerDataSource>)getUnwrappedDataSource
{
    return [self.dataSource isKindOfClass:[ItemPickerDataSourceDefaults class]] ? 
        ((ItemPickerDataSourceDefaults *)self.dataSource).dataSource : self.dataSource;
}

- (void)reloadData
{
    self.processed = NO;
    [self.itemCache invalidate];
}

- (ItemPickerSelection *)getItemPickerSelection:(NSIndexPath *)indexPath
{
    NSUInteger selectedIndex = [self convertIndexPathToArrayIndex:indexPath];
    return [[ItemPickerSelection alloc] initWithDataSource:[self getUnwrappedDataSource]
                                             selectedIndex:selectedIndex
                                              selectedItem:[self getItem:indexPath]
                                              autoSelected:self.autoSelected
                                                  metaCell:selectedIndex == kMetaCellRowIndex];
}

- (void)initState
{
    id<ItemPickerDataSource> ds = self.dataSource;
    self.metaCellTitle = ds.metaCellTitle;
    self.metaCellDescription = ds.metaCellDescription;
    self.dataSourceItemCount = self.dataSourceInternalItemCount = ds.count;
    
    if (self.metaCellTitle)
    {
        self.dataSourceInternalItemCount += 1;
    }
    else
    {
        // for simplicity, only do this if we don't have a metaCellTitle
        if (self.dataSourceItemCount == 0 && ds.noItemsItemText)
        {
            ds = [[NoItemsDataSource alloc] initWithDataSource:ds];
            self.dataSourceInternalItemCount = 1;
        }
    }
    
    self.dataSource = ds;
    self.itemCache = [[ItemCache alloc] initForDataSource:ds];
    self.itemCache.size = self.itemCacheSize;
}

- (void)initSections
{
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

- (void)process
{
    [Preconditions assert:!self.processed message:@"processed should be false"];
    
    self.processed = YES;
    
    [self initState];
    
    [self initSections];
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
    ItemPickerSection *defaultSection = [[ItemPickerSection alloc] initWithTitle:@"" range:NSMakeRange(0, self.dataSourceInternalItemCount)];
    self.sections = @[defaultSection];
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
        return index == 0 ? kMetaCellRowIndex : index - 1;
    }
        
    return index;
}

@end
