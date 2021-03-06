// @author Simon Toens 12/14/12

#import "ItemPicker.h"
#import "ItemPickerSelection.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "Stack.h"
#import "TableHeaderView.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
@property(nonatomic, strong) Stack *currentSelectionStack;
@property(nonatomic, strong) ItemPickerContext *itemPickerContext;
@property(nonatomic, strong) UIBarButtonItem *doneButton;
@end

@implementation ItemPickerViewController

@synthesize showDoneButton = _showCancelButton;

static NSString* ReloadTableDataNotification = @"STItemPickerReloadTableDataNotification";

#pragma mark - Initializers/dealloc

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource itemPickerContext:(ItemPickerContext *)itemPickerContext
{
    return [self initWithDataSource:dataSource 
                  itemPickerContext:itemPickerContext
              currentSelectionStack:[[Stack alloc] init]];    
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
       itemPickerContext:(ItemPickerContext *)itemPickerContext
   currentSelectionStack:(Stack *)currentSelectionStack
{
    return [self initWithNibName:@"ItemPickerView" 
                      dataSource:dataSource 
               itemPickerContext:itemPickerContext
           currentSelectionStack:currentSelectionStack];
}

- (id)initWithNibName:(NSString *)nibName 
           dataSource:(id<ItemPickerDataSource>)dataSource
   itemPickerContext:(ItemPickerContext *)itemPickerContext
currentSelectionStack:(Stack *)currentSelectionStack
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _currentSelectionStack = currentSelectionStack;
        _itemPickerContext = itemPickerContext;
        _dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:dataSource autoSelected:NO];
        
        _maxSelectableItems = 1;
        _showCancelButton = NO;

        if (self.tabBarItem) 
        {
            self.title = dataSource.title;
            self.tabBarItem.image = dataSource.tabImage;
        }        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self configureHeaderView];
    [self configureNavigationItem];
    [self configureTitle];
    [self registerForNotifications];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        while ([[self.currentSelectionStack pop] autoSelected]);
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // hack to get rid of empty rows in table view (also see heightForFooterInSection)
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == [[self.dataSourceAccess getSectionTitles] count] - 1 ? 1 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    ItemPickerSelection *selection = [self.dataSourceAccess getItemPickerSelection:indexPath];
    [self selectedItemAtIndexPath:indexPath selection:selection dataSource:[self.dataSourceAccess getDataSource]];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.dataSourceAccess getSectionTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] range].length;
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    UIImage *image = [self.dataSourceAccess getItemImage:indexPath];        
    NSString *description = [self.dataSourceAccess getItemDescription:indexPath];
    
    UITableViewCell *cell = [TableViewCellContainer newCellForTableView:tableView 
                                                                   text:[self.dataSourceAccess getItem:indexPath]
                                                                  image:image 
                                                            description:description
                                                         itemAttributes:[self.dataSourceAccess getItemAttributes:indexPath]];
    
    if ([self.dataSourceAccess isLeafAtIndexPath:indexPath])
    {
        if (self.maxSelectableItems > 1) 
        {
            BOOL isCellSelected = [self isCellSelectedAtIndexPath:indexPath]; 
            cell.accessoryType = isCellSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;    
            cell.userInteractionEnabled = cell.userInteractionEnabled && (isCellSelected || [self moreCellsAreSelectable]);
        }
    }
    else 
    {
        if (![self.dataSourceAccess getSectionsEnabled])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [self.dataSourceAccess getSectionTitles];
}

#pragma mark - Private methods

- (void)reloadDataForAllTableViews
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadTableDataNotification object:nil];
}

- (BOOL)moreCellsAreSelectable
{
    return [self.itemPickerContext.selectedItems count] < self.maxSelectableItems;    
}

- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.itemPickerContext.selectedItems count] == 0)
    {
        // if nothing is selected, this cell is not selected for sure
        return NO;
    }
    
    // review how we determine that a cell has been previously selected - 
    // this is creating a lot of ItemPickerContext instances
    ItemPickerSelection *selection = [self.dataSourceAccess getItemPickerSelection:indexPath];
    [self.currentSelectionStack push:selection];
    NSArray *selectionPath = [self.currentSelectionStack allObjects];
    BOOL selected = [self.itemPickerContext.selectedItems containsObject:selectionPath];
    [self.currentSelectionStack pop];
    return selected;
}

- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
                      selection:(ItemPickerSelection *)selection
                     dataSource:(id<ItemPickerDataSource>)dataSource 
{
    if ([self.dataSourceAccess isLeafAtIndexPath:indexPath])
    {
        [self handleLeafSelection:selection atIndexPath:indexPath];
    }
    else
    {
        NSArray *prevSelections = [[self.currentSelectionStack allObjects] copy];
        id<ItemPickerDataSource> nextDataSource = [dataSource getNextDataSourceForSelection:selection previousSelections:prevSelections];
        if (nextDataSource)
        {
            [self.currentSelectionStack push:selection];
            [self pushDataSource:nextDataSource];
        }
        else
        {
            // programmer error - !isLeaf but no nextDataSource?  we'll let it slide
            [self handleLeafSelection:selection atIndexPath:indexPath];
        }
    }
}

- (void)handleLeafSelection:(ItemPickerSelection *)selection atIndexPath:(NSIndexPath *)indexPath
{
    // build copy of current selection path and add final leaf selection
    NSMutableArray *selectionPath = [[NSMutableArray alloc] initWithCapacity:[self.currentSelectionStack count] + 1];
    [selectionPath addObjectsFromArray:[self.currentSelectionStack allObjects]];
    [selectionPath addObject:selection];
    [self handleSelection:selectionPath atIndexPath:indexPath];
}

- (void)handleSelection:(NSArray *)selectionPath atIndexPath:(NSIndexPath *)indexPath
{
    if (self.maxSelectableItems > 1)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];            
        if ([self.itemPickerContext.selectedItems containsObject:selectionPath])
        {
            [self.itemPickerContext.selectedItems removeObject:selectionPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self reloadDataForAllTableViews];
        }
        else
        {
            if ([self moreCellsAreSelectable])
            {
                [self.itemPickerContext.selectedItems addObject:selectionPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;    
            }
            else 
            {
                [self reloadDataForAllTableViews];
            }
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        [self.itemPickerDelegate onItemPickerPickedItems:@[selectionPath]];
    }
}

- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (dataSource.autoSelectSingleItem && dataSource.count == 1)
    {
        DataSourceAccess *access = [[DataSourceAccess alloc] initWithDataSource:dataSource autoSelected:YES];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        ItemPickerSelection *selection = [access getItemPickerSelection:indexPath];
        [self selectedItemAtIndexPath:indexPath selection:selection dataSource:dataSource];
    }
    else
    {    
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] 
                                                initWithDataSource:dataSource
                                                 itemPickerContext:self.itemPickerContext
                                             currentSelectionStack:self.currentSelectionStack];
        
        controller.itemPickerDelegate = self.itemPickerDelegate;
        controller.maxSelectableItems = self.maxSelectableItems;
        controller.showDoneButton = self.showDoneButton;
        controller.dataSourceAccess.itemCacheSize = self.dataSourceAccess.itemCacheSize;
        [self.navigationController pushViewController:controller animated:YES];    
    }
}

- (ItemPickerSelection *)getPreviousContext
{
    NSArray *contexts = [self.currentSelectionStack allObjects];
    return [contexts count] > 0 ? [contexts objectAtIndex:[contexts count] - 1] : nil;
}

- (void)configureHeaderView 
{
    ItemPickerHeader *header = [self.dataSourceAccess getHeader];    
    if (header)
    {
        self.tableView.tableHeaderView = [TableHeaderView initWithHeader:header
                                                          selectionStack:self.currentSelectionStack
                                                        dataSourceAccess:self.dataSourceAccess
                                                       selectAllCallback:^{ [self onSelectAll]; }];
    }
}

- (void)onSelectAll
{
    NSUInteger itemCount = [self.dataSourceAccess getDataSourceItemCount];
    for (NSUInteger i = 0; i < itemCount; i++)
    {
        if (![self moreCellsAreSelectable])
        {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if ([self isCellSelectedAtIndexPath:indexPath])
        {
            continue;
        }
        ItemAttributes *attributes = [self.dataSourceAccess getItemAttributes:indexPath];
        if (attributes && !attributes.userInteractionEnabled)
        {
            continue;
        }        
        ItemPickerSelection *selection = [self.dataSourceAccess getItemPickerSelection:indexPath];
        [self selectedItemAtIndexPath:indexPath selection:selection dataSource:[self.dataSourceAccess getDataSource]];
    }
}

- (void)configureTitle
{
    ItemPickerSelection *prevSelection = [self getPreviousContext];
    self.title = prevSelection ? prevSelection.selectedItem : [self.dataSourceAccess getTitle];
}

- (void)configureNavigationItem
{    
    if (self.showDoneButton || self.maxSelectableItems > 1)
    {
        self.navigationItem.rightBarButtonItem = 
            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain 
                                                          target:self
                                                          action:@selector(onDone)];
    }    
}

- (void)registerForNotifications
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reloadData) name:ReloadTableDataNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(reloadData) name:ItemPickerDataSourceDidChangeNotification object:nil];
}

- (void)reloadData
{
    [self.dataSourceAccess reloadData];
    [self.tableView reloadData];
}

- (void)onDone
{
    NSArray *selections = [self.itemPickerContext.selectedItems copy];
    [self deselectAllItems];
    [self.itemPickerDelegate onItemPickerPickedItems:selections];
}

- (void)deselectAllItems
{
    [self.itemPickerContext.selectedItems removeAllObjects];
    [self reloadDataForAllTableViews];
}

@end
