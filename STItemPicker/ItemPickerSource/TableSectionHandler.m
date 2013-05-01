// @author Simon Toens 03/18/13

#import <objc/runtime.h>

#import "Preconditions.h"
#import "TableSectionHandler.h"
#import "Tuple.h"

@interface TableSectionHandler() 
- (NSString *)getSectionNameForItem:(NSString *)item;
- (void)process;

@property(nonatomic, assign) BOOL alreadySorted;
@property(nonatomic, assign) BOOL processed;

@property(nonatomic, strong, readwrite) NSArray *items;
@property(nonatomic, strong, readwrite) NSArray *sections;
@property(nonatomic, strong, readwrite) NSDictionary *sectionToNumberOfItems;

- (void)buildSections;
- (void)sortItems;

@end

@implementation TableSectionHandler

NSString const *kTableSectionHandlerNumberHeader = @"0";
NSString const *kTableSectionHandlerSymbolHeader = @"#";
NSString const *kTableSectionHandlerNonLatinLetterSymbolHeader = @"あ";

const void *kImageAssociationKey = @"image";

static NSCharacterSet *kEnglishLetterCharacterSet;
static NSCharacterSet *kAllLetterCharacterSet;
static NSCharacterSet *kNumberCharacterSet;
static NSCharacterSet *kACharacterSet;
static NSCharacterSet *kOCharacterSet;
static NSCharacterSet *kUCharacterSet;

@synthesize alreadySorted = _alreadySorted;
@synthesize items = _items;
@synthesize itemImages = _itemImages;
@synthesize processed = _processed;
@synthesize sections = _sections;
@synthesize sectionsEnabled = _sectionsEnabled;
@synthesize sectionToNumberOfItems = _sectionToNumberOfItems;


+ (NSCharacterSet *)getEnglishCharacterSet
{
    NSMutableCharacterSet *cset = [[NSMutableCharacterSet alloc] init];
    NSRange range;
    range.location = (unsigned int)'a';
    range.length = 26;
    [cset addCharactersInRange:range];
    
    range.location = (unsigned int)'A';
    [cset addCharactersInRange:range];    
    return cset;
}

+ (void)initialize 
{
    kEnglishLetterCharacterSet = [TableSectionHandler getEnglishCharacterSet];
    kAllLetterCharacterSet = [NSCharacterSet letterCharacterSet];
    kNumberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    kACharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"äÄ"];
    kOCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"öÖ"];
    kUCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"üÜ"];
}

- (id)initWithItems:(NSArray *)items alreadySorted:(BOOL)alreadySorted
{
    if (self = [super init]) 
    {
        [Preconditions assertNotEmpty:items message:@"items cannot be nil or empty"];
        _items = items;
        _alreadySorted = alreadySorted;
        _sectionsEnabled = YES;
        _processed = NO;
    }
    return self;
}

- (void)setItemImages:(NSArray *)itemImages
{
    if (itemImages)
    {
        [Preconditions assert:[_items count] == [itemImages count] 
                      message:@"The number of items must match the number of item images"];
        _itemImages = itemImages;
    }
}

- (NSArray *)items
{
    [self process];
    return _items;
}

- (NSArray *)itemImages
{
    [self process];
    return _itemImages;
}

- (NSArray *)sections 
{
    [self process];
    return _sections;
}

- (NSDictionary *)sectionToNumberOfItems 
{
    [self process];
    return _sectionToNumberOfItems;
}

- (void)process 
{    
    if (self.processed)
    {
        return;
    }
    
    self.processed = YES;
    
    [self sortItems];
    [self buildSections];
}

- (NSString const*)getSectionNameForItem:(NSString *)item 
{
    unichar c = [item characterAtIndex:0];
    
    if ([kACharacterSet characterIsMember:c])
    {
        c = 'a';
    }
    else if ([kOCharacterSet characterIsMember:c])
    {
        c = 'o';
    }
    else if ([kUCharacterSet characterIsMember:c])
    {
        c = 'u';
    }
        
    if ([kEnglishLetterCharacterSet characterIsMember:c]) 
    {
        return [[NSString stringWithCharacters:&c length:1] uppercaseString];
    } 
    else if ([kNumberCharacterSet characterIsMember:c]) 
    {
        return kTableSectionHandlerNumberHeader;
    } 
    else if ([kAllLetterCharacterSet characterIsMember:c])
    {
        return kTableSectionHandlerNonLatinLetterSymbolHeader;
    }
    else
    {
        return kTableSectionHandlerSymbolHeader;
    }
}

- (void)sortItems
{
    if (!self.alreadySorted) 
    {
        if (self.itemImages)
        {
            for (int i = 0; i < [self.items count]; i++)
            {
                objc_setAssociatedObject([self.items objectAtIndex:i], kImageAssociationKey, [self.itemImages objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
            }
        }
        self.items = [self.items sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        if (self.itemImages) 
        {
            NSMutableArray *sortedItemImages = [[NSMutableArray alloc] initWithCapacity:[self.itemImages count]];
            for (int i = 0; i < [self.items count]; i++)
            {
                [sortedItemImages addObject:objc_getAssociatedObject([self.items objectAtIndex:i], kImageAssociationKey)];
                objc_setAssociatedObject([self.items objectAtIndex:i], kImageAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
                
            }
            self.itemImages = sortedItemImages;
        }
        
    }
}

- (void)buildSections
{
    if (!self.sectionsEnabled) 
    {
        self.sections = [NSArray arrayWithObject:@""];
        self.sectionToNumberOfItems = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:[self.items count]] forKey:@""];
        return;
    }
    
    NSMutableArray *theSections = [[NSMutableArray alloc] init];
    NSMutableDictionary *sectionCount = [[NSMutableDictionary alloc] init];
    
    int itemsInSectionCount = 0;
    for (NSString *item in self.items) 
    {
        NSString *sectionNameForCurrentItem = [self getSectionNameForItem:item];
        if ([theSections count] == 0) {
            [theSections addObject:sectionNameForCurrentItem];
        } 
        else 
        {
            NSString *lastSectionName = [theSections lastObject];
            if (![lastSectionName isEqualToString:sectionNameForCurrentItem]) 
            {
                [sectionCount setObject:[NSNumber numberWithInt:itemsInSectionCount] forKey:lastSectionName];
                itemsInSectionCount = 1;
                [theSections addObject:sectionNameForCurrentItem];
                continue;
            }
        }
        itemsInSectionCount += 1;
    }
    NSString *currentSectionName = [theSections lastObject];
    [sectionCount setObject:[NSNumber numberWithInt:itemsInSectionCount] forKey:currentSectionName];
    
    self.sections = theSections;
    self.sectionToNumberOfItems = sectionCount;
}

@end