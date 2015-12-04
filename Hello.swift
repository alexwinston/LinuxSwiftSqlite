import Foundation
import Glibc
import sqlite3

var r = random() % 10;

var db: COpaquePointer = nil
sqlite3_open("swift.db", &db);

var rc: Int32;

var sql:String = "create table if not exists test (id integer primary key autoincrement, name text)";

if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("error creating table: \(errmsg)")
}

internal let SQLITE_STATIC = unsafeBitCast(0, sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, sqlite3_destructor_type.self)

var statement: COpaquePointer = nil

if sqlite3_prepare_v2(db, "insert into test (name) values (?)", -1, &statement, nil) != SQLITE_OK {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("error preparing insert: \(errmsg)")
}

if sqlite3_bind_text(statement, 1, "foo", -1, SQLITE_TRANSIENT) != SQLITE_OK {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("failure binding foo: \(errmsg)")
}

if sqlite3_step(statement) != SQLITE_DONE {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("failure inserting foo: \(errmsg)")
}

if sqlite3_prepare_v2(db, "select id, name from test", -1, &statement, nil) != SQLITE_OK {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("error preparing select: \(errmsg)")
}

while sqlite3_step(statement) == SQLITE_ROW {
    let id = sqlite3_column_int64(statement, 0)
    print("id = \(id); ", terminator: "")

    let name = sqlite3_column_text(statement, 1)
    if name != nil {
        let nameString = String.fromCString(UnsafePointer<Int8>(name))
        print("name = \(nameString!)")
    } else {
        print("name not found")
    }
}

if sqlite3_finalize(statement) != SQLITE_OK {
    let errmsg = String.fromCString(sqlite3_errmsg(db))
    print("error finalizing prepared statement: \(errmsg)")
}

statement = nil

print("Hello World \(r)")
