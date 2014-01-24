// @author Simon Toens 04/21/13

#import "MultiDictionary.h"
#import "SampleCityDataSource.h"

@interface SampleCityDataSource()
@property(nonatomic, assign) NSUInteger depth;
@property(nonatomic, assign, readwrite) BOOL isLeaf;
@property(nonatomic, strong) NSArray *items;
@end

@implementation SampleCityDataSource

static MultiDictionary* kContinentsToCountries;
static MultiDictionary* kCountriesToRegions;
static MultiDictionary* kRegionsToStates;
static MultiDictionary* kStatesToCities;

static NSArray *kAllDictionaries;

- (id)init
{
    return [self initWithDepth:0 items:[kContinentsToCountries allKeys]];
}

- (id)initWithDepth:(NSUInteger)depth items:(NSArray *)items
{
    if (self = [super init])
    {
        _depth = depth;
        _isLeaf = NO;
        _items = items;
    }
    return self;
}

- (NSUInteger)count
{
    return [self.items count];
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.items subarrayWithRange:range];
}

- (NSString *)title
{
    return @"Continents";
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)context 
                                       previousSelections:(NSArray *)previousSelections
{
    if (self.depth <= [kAllDictionaries count] - 1)
    {
        MultiDictionary *currentDict = [kAllDictionaries objectAtIndex:self.depth];
        SampleCityDataSource *ds = [[SampleCityDataSource alloc] 
            initWithDepth:self.depth+1 items:[[currentDict objectsForKey:context.selectedItem] allObjects]];
        ds.isLeaf = self.depth == [kAllDictionaries count] - 1;
        return ds;
    }
    return nil;
}

+ (void)addContinent:(NSString *)con country:(NSString *)cou region:(NSString *)r state:(NSString *)s cities:(NSArray *)c
{
    [kContinentsToCountries setObject:cou forKey:con];
    [kCountriesToRegions setObject:r forKey:cou];
    [kRegionsToStates setObject:s forKey:r];
    for (NSString *city in c)
    {
        [kStatesToCities setObject:city forKey:s];
    }
}

+ (void)initialize 
{
    kContinentsToCountries = [[MultiDictionary alloc] init];
    kCountriesToRegions = [[MultiDictionary alloc] init];
    kRegionsToStates = [[MultiDictionary alloc] init];
    kStatesToCities = [[MultiDictionary alloc] init];
    
    kAllDictionaries = @[kContinentsToCountries, kCountriesToRegions, kRegionsToStates, kStatesToCities];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Oregon" 
                  cities:@[@"Portland", @"Salem", @"Eugene", @"Bend", @"Ashland"]];
    
    [self addContinent:@"America" 
               country:@"USA" 
                region:@"Pacific Northwest" 
                 state:@"Washington" 
                cities:@[@"Seattle", @"Kirkland", @"Bellevue", @"Olympia"]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Andalusia" 
                 state:@"Cadiz" 
                cities:@[@"Barbate", @"Conil de la Frontera", @"Medina Sidonia"]];
    
    [self addContinent:@"Europe" 
               country:@"Spain" 
                region:@"Catalonia" 
                 state:@"Tarragona" 
                cities:@[@"Reus", @"Salou", @"Tortosa", @"Valls"]];
}

@end
