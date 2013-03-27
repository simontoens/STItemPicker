// @author Simon Toens 03/18/13

#import "TableSectionHandler.h"

@interface TableSectionHandler() 
- (NSString *)getSectionNameForItem:(NSString *)item;
- (void)process;

@property(nonatomic, assign) BOOL alreadySorted;

@property(nonatomic, strong, readwrite) NSArray *items;
@property(nonatomic, strong, readwrite) NSArray *sections;
@property(nonatomic, strong, readwrite) NSDictionary *sectionToNumberOfItems;

@end

@implementation TableSectionHandler

NSString const *kTableSectionHandlerNumberHeader = @"0";
NSString const *kTableSectionHandlerSymbolHeader = @"#";

static NSCharacterSet *letterCharacterSet;
static NSCharacterSet *numberCharacterSet;

@synthesize sectionsEnabled = _sectionsEnabled;
@synthesize alreadySorted = _alreadySorted;
@synthesize items = _items;
@synthesize sections = _sections;
@synthesize sectionToNumberOfItems = _sectionToNumberOfItems;

+ (void)initialize 
{
    NSMutableCharacterSet *cset = [[NSMutableCharacterSet alloc] init];
    NSRange range;
    range.location = (unsigned int)'a';
    range.length = 26;
    [cset addCharactersInRange:range];
    
    range.location = (unsigned int)'A';
    [cset addCharactersInRange:range];    
    letterCharacterSet = cset;

    numberCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
}

- (id)initWithItems:(NSArray *)items alreadySorted:(BOOL)alreadySorted 
{
    if (self = [super init]) 
    {
        _items = items;
        _alreadySorted = alreadySorted;
        _sectionsEnabled = YES;
    }
    return self;
}

- (NSArray *)sections 
{
    if (!_sections) 
    {
        [self process];
    }
    return _sections;
}

- (NSDictionary *)sectionToNumberOfItems 
{
    if (!_sectionToNumberOfItems) 
    {
        [self process];
    }
    return _sectionToNumberOfItems;
}

- (void)process 
{    
    if (!self.alreadySorted) 
    {
        self.items = [self.items sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
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

- (NSString const*)getSectionNameForItem:(NSString *)item 
{
    unichar c = [item characterAtIndex:0];
    if ([letterCharacterSet characterIsMember:c]) 
    {
        return [[item substringToIndex:1] uppercaseString];
    } 
    else if ([numberCharacterSet characterIsMember:c]) 
    {
        return kTableSectionHandlerNumberHeader;
    } 
    else 
    {
        return kTableSectionHandlerSymbolHeader;
    }
}

@end