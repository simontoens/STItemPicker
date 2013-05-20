// @author Simon Toens 03/18/13

#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ItemPickerSection.h"
#import "Preconditions.h"
#import "TableSectionHandler.h"
#import "Tuple.h"

@interface TableSectionHandler() 
- (void)buildSections;
- (NSString *)getSectionNameForItem:(NSString *)item;
- (void)process;
- (void)sortItems;

@property(nonatomic, assign) BOOL processed;

@property(nonatomic, strong, readwrite) NSArray *items;
@property(nonatomic, strong, readwrite) NSArray *sections;

@end

@implementation TableSectionHandler

NSString const *kTableSectionHandlerNumberHeader = @"0";
NSString const *kTableSectionHandlerSymbolHeader = @"#";
NSString const *kTableSectionHandlerNonLatinLetterSymbolHeader = @"あ";

const void *kDescriptionAssociationKey = @"desc";
const void *kImageAssociationKey = @"image";

static NSCharacterSet *kEnglishLetterCharacterSet;
static NSCharacterSet *kAllLetterCharacterSet;
static NSCharacterSet *kNumberCharacterSet;
static NSCharacterSet *kPunctuationCharacterSet;
static NSCharacterSet *kACharacterSet;
static NSCharacterSet *kOCharacterSet;
static NSCharacterSet *kUCharacterSet;

@synthesize items = _items;
@synthesize itemDescriptions = _itemDescriptions;
@synthesize itemImages = _itemImages;
@synthesize processed = _processed;
@synthesize sections = _sections;

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
    kPunctuationCharacterSet = [NSCharacterSet punctuationCharacterSet];
    kACharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"äÄ"];
    kOCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"öÖ"];
    kUCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"üÜ"];
}

- (id)initWithItems:(NSArray *)items 
{
    if (self = [super init]) 
    {
        [Preconditions assertNotEmpty:items message:@"items cannot be nil or empty"];
        _items = items;
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

- (NSArray *)itemDescriptions
{
    [self process];
    return _itemDescriptions;
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
    
    if ([kPunctuationCharacterSet characterIsMember:c] && [item length] > 1)
    {
        c = [item characterAtIndex:1];
    }
    
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
    if (self.itemImages || self.itemDescriptions)
    {
        for (int i = 0; i < [self.items count]; i++)
        {
            if (self.itemImages)
            {
                objc_setAssociatedObject([self.items objectAtIndex:i], kImageAssociationKey, 
                                         [self.itemImages objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);
            }
            if (self.itemDescriptions)
            {
                objc_setAssociatedObject([self.items objectAtIndex:i], kDescriptionAssociationKey, 
                                         [self.itemDescriptions objectAtIndex:i], OBJC_ASSOCIATION_ASSIGN);                
            }
        }
    }

    self.items = [self.items sortedArrayUsingComparator:^NSComparisonResult(NSString *first, NSString *second) {

        unichar c = [first characterAtIndex:0];
        if ([kPunctuationCharacterSet characterIsMember:c])
        {
            first = [first substringFromIndex:1];
        }
        c = [second characterAtIndex:0];
        if ([kPunctuationCharacterSet characterIsMember:c])
        {
            second = [second substringFromIndex:1];
        }

        return [first localizedCaseInsensitiveCompare:second];
    }];
    
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
    
    if (self.itemDescriptions)
    {
        NSMutableArray *sortedDescription = [[NSMutableArray alloc] initWithCapacity:[self.itemDescriptions count]];
        for (int i = 0; i < [self.items count]; i++)
        {
            [sortedDescription addObject:objc_getAssociatedObject([self.items objectAtIndex:i], kDescriptionAssociationKey)];
            objc_setAssociatedObject([self.items objectAtIndex:i], kDescriptionAssociationKey, nil, OBJC_ASSOCIATION_ASSIGN);
            
        }
        self.itemDescriptions = sortedDescription;
    }
}

- (void)addSection:(NSString *)title location:(int)location length:(int)length sections:(NSMutableArray *)sections
{
    ItemPickerSection *section = [[ItemPickerSection alloc] initWithTitle:title range:NSMakeRange(location, length)];
    [sections addObject:section];
}

- (void)buildSections
{        
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    int itemsInSectionCount = 0;
    NSString *previousSectionName = nil;
    
    for (int i = 0; i < [_items count]; i++)
    {        
        NSString *item = [_items objectAtIndex:i];
        NSString *sectionNameForCurrentItem = [self getSectionNameForItem:item];
        if (!previousSectionName)
        {
            previousSectionName = sectionNameForCurrentItem;
        }
        
        if (![previousSectionName isEqualToString:sectionNameForCurrentItem])
        {
            [self addSection:previousSectionName location:i - itemsInSectionCount length:itemsInSectionCount sections:sections];
            itemsInSectionCount = 0;
            previousSectionName = sectionNameForCurrentItem;
        }
        
        itemsInSectionCount += 1;        
    }
    
    [self addSection:previousSectionName location:[_items count] - itemsInSectionCount length:itemsInSectionCount sections:sections ];
    self.sections = sections;
}

@end