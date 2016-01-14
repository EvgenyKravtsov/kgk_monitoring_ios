//
//  DatabaseManager.m
//  KGK Monitoring
//
//  Created by Admin on 13/11/15.
//  Copyright (c) 2015 KGK. All rights reserved.
//

#import "DatabaseManager.h"
#import "Tolo.h"
#import "Action.h"
#import "ActionCreatorConstants.h"
#import <sqlite3.h>
#import "DatabaseConstants.h"
#import "KGKSignal.h"
#import "KGKDispatcher.h"
#import "ActionCreator.h"
#import "KGKHttpConstants.h"
#import "AppDelegate.h"
#import "SignalsFromDatabaseDelivery.h"

@interface DatabaseManager ()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrayResults;
@property (nonatomic, strong) NSMutableArray *arrayColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;
@property (nonatomic) KGKDispatcher *dispatcher;
@property (nonatomic) ActionCreator *actionCreator;

@end

@implementation DatabaseManager

static DatabaseManager *instance = nil;

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[DatabaseManager alloc] initWithDatabaseFilename:DATABASE_NAME];
    }
    return instance;
}

- (instancetype)initWithDatabaseFilename:(NSString *)databaseFilename {
    self = [super init];
    
    if (self) {
        REGISTER();
        
        self.dispatcher = [KGKDispatcher getInstance];
        self.actionCreator = [ActionCreator getInstance:self.dispatcher];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = databaseFilename;
        // [self copyDatabaseIntoDocumentsDirectory];
    }
    
    return self;
}

- (void)copyDatabaseIntoDocumentsDirectory {
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:destinationPath
                                                 error:&error];
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable {
    sqlite3 *sqlite3Database;
//    NSString *databasePath = [self.documentsDirectory
//                              stringByAppendingPathComponent:self.databaseFilename];
    NSString *databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
    if (self.arrayResults != nil) {
        [self.arrayResults removeAllObjects];
        self.arrayResults = nil;
    }
    self.arrayResults = [[NSMutableArray alloc] init];
    
    if (self.arrayColumnNames != nil) {
        [self.arrayColumnNames removeAllObjects];
        self.arrayColumnNames = nil;
    }
    self.arrayColumnNames = [[NSMutableArray alloc] init];
    
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if (openDatabaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
    
        BOOL preparedStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1,
                                                      &compiledStatement, NULL);
        if (preparedStatementResult == SQLITE_OK) {
            if (!queryExecutable) {
                NSMutableArray *arrayDataRow;
            
                while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    arrayDataRow = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    for (int i = 0; i < totalColumns; i++) {
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        if (dbDataAsChars != NULL) {
                            [arrayDataRow addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        if (self.arrayColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [self.arrayColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    if (arrayDataRow.count > 0) {
                        [self.arrayResults addObject:arrayDataRow];
                    }
                }
            } else {
                BOOL executeQueryResult = sqlite3_step(compiledStatement);
                if (executeQueryResult) {
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                } else {
                    NSLog(@"Database error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
        } else {
           NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3Database);
}

- (NSArray *)loadDataFromDatabase:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return (NSArray *)self.arrayResults;
}

- (void)executeQuery:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

SUBSCRIBE(Action) {
    if ([event.type isEqualToString:GET_LAST_SIGNAL_DATE_FROM_DATABASE]) {
        NSInteger lastSignalDate = [self retrieveLastSignalDateFromDatabase];
        NSInteger now = [[NSDate date] timeIntervalSince1970];
        [self.actionCreator requestLastSignalsFromServer:lastSignalDate
                                            currentDate:now];
    } else if ([event.type isEqualToString:INSERT_SIGNAL_TO_PERSISTANCE_STORAGE]) {
        KGKSignal *signal = [[event data] objectForKey:KEY_SIGNAL];
        if (![self hasDuplicate:signal]) {
            [self insertSignal:signal];
            [self.actionCreator updateLastSignal:signal];
        } else {
            NSLog(@"Duplicate");
        }
    } else if ([event.type isEqualToString:GET_SIGNALS_FROM_DATABASE]) {
        [self retrieveSignalsFromDatabase:[[event.data objectForKey:KEY_NUMBER_OF_SIGNALS] integerValue]];
    } else if ([event.type isEqualToString:GET_SIGNALS_FROM_DATABASE_BY_PERIOD]) {
        NSInteger fromDate = [[event.data objectForKey:KEY_FROM_DATE] integerValue];
        NSInteger toDate = [[event.data objectForKey:KEY_TO_DATE] integerValue];
        [self retrieveSignalsFromDatabaseByPeriod:fromDate toDate:toDate];
    }
}

- (void)insertSignal:(KGKSignal *)signal {
    NSString *insertSignalQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES (%ld,%ld,%f,%f,%ld,%f,%f,%ld,%ld,%ld,%ld,%ld);", TABLE_SIGNAL, COLUMN_DEVICE_ID, COLUMN_MODE, COLUMN_LATITUDE, COLUMN_LONGITUDE, COLUMN_DATE, COLUMN_VOLTAGE, COLUMN_BALANCE, COLUMN_SATELLITES, COLUMN_SPEED, COLUMN_CHARGE, COLUMN_DIRECTION, COLUMN_TEMPERATURE, (long)signal.deviceId, (long)signal.mode, signal.latitude, signal.longitude, (long)signal.date, signal.voltage, signal.balance, (long)signal.satellites, (long)signal.speed, (long)signal.charge, (long)signal.direction, (long)signal.temperature];
    [self executeQuery:insertSignalQuery];
}

- (NSInteger)retrieveLastSignalDateFromDatabase {
    NSInteger lastSignalDate = 0;
    AppDelegate *appDelagate = [[UIApplication sharedApplication] delegate];
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ = %ld ORDER BY %@ ASC", TABLE_SIGNAL, COLUMN_DEVICE_ID, appDelagate.activeDeviceId, COLUMN_DATE];
    NSArray *result = [self loadDataFromDatabase:query];
    
    if ([result count] == 0) {
        lastSignalDate = 1441065600;
        return lastSignalDate;
    } else {
        NSArray *lastRow = result[[result count] - 1];
        NSLog(@"%ld", [lastRow[5] integerValue]);
        return [lastRow[5] integerValue];
    }
}

- (BOOL)hasDuplicate:(KGKSignal *)signal {
    NSInteger deviceId = signal.deviceId;
    NSInteger date = signal.date;
    NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@ = %ld AND %@ = %ld", TABLE_SIGNAL, COLUMN_DEVICE_ID, (long)deviceId, COLUMN_DATE, (long)date];
    NSArray *result = [self loadDataFromDatabase:query];
    return [result count] > 0 ? YES : NO;
}

- (void)retrieveSignalsFromDatabase:(NSInteger)count {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %ld ORDER BY %@ DESC LIMIT %ld", TABLE_SIGNAL, COLUMN_DEVICE_ID, delegate.activeDeviceId, COLUMN_DATE, count];
    NSArray *data = [self loadDataFromDatabase:query];
    NSMutableArray *signals = [self serializeSignalsFromDatabase:data];
    SignalsFromDatabaseDelivery *event = [[SignalsFromDatabaseDelivery alloc] init];
    event.signals = signals;
    event.byPeriod = NO;
    PUBLISH(event);
}

- (void)retrieveSignalsFromDatabaseByPeriod:(NSInteger)fromDate toDate:(NSInteger)toDate {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = %ld AND %@ >= %ld AND %@ <= %ld ORDER BY %@", TABLE_SIGNAL, COLUMN_DEVICE_ID, delegate.activeDeviceId, COLUMN_DATE, fromDate, COLUMN_DATE, toDate, COLUMN_DATE];
    NSArray *data = [self loadDataFromDatabase:query];
    NSMutableArray *signals = [self serializeSignalsFromDatabase:data];
    SignalsFromDatabaseDelivery *event = [[SignalsFromDatabaseDelivery alloc] init];
    event.signals = signals;
    event.byPeriod = YES;
    PUBLISH(event);
}

- (NSMutableArray *)serializeSignalsFromDatabase:(NSArray *)rawData {
    NSMutableArray *signals = [[NSMutableArray alloc] init];
    for (NSArray *entry in rawData) {
        KGKSignal *signal = [[KGKSignal alloc] init];
        signal.deviceId = [entry[1] integerValue];
        signal.mode = [entry[2] integerValue];
        signal.latitude = [entry[3] doubleValue];
        signal.longitude = [entry[4] doubleValue];
        signal.date = [entry[5] integerValue];
        signal.voltage = [entry[6] doubleValue];
        signal.balance = [entry[7] doubleValue];
        signal.satellites = [entry[8] integerValue];
        signal.charge = [entry[9] integerValue];
        signal.speed = [entry[10] integerValue];
        signal.direction = [entry[11] integerValue];
        signal.temperature = [entry[12] integerValue];
        [signals insertObject:signal atIndex:0];
    }
    return signals;
}

@end




































