#include <iostream>
#include <sqlite3.h>

// 封装打开数据库
sqlite3* open_im_db(const char* db_file)
{
    sqlite3* db = nullptr;
    int rc = sqlite3_open(db_file, &db);
    if (rc != SQLITE_OK)
    {
        std::cerr << "数据库打开失败: " << sqlite3_errmsg(db) << std::endl;
        sqlite3_close(db);
        return nullptr;
    }
    // 每次新建连接必须开启外键
    sqlite3_exec(db, "PRAGMA foreign_keys = ON;", nullptr, nullptr, nullptr);
    std::cout << "✅ 数据库连接成功，外键已开启" << std::endl;
    return db;
}

int main()
{
    sqlite3* db = open_im_db("im.db");
    if (!db)
    {
        return -1;
    }

    // 简单查询：查看t_user表行数，验证表是否存在
    const char* sql = "SELECT COUNT(*) FROM t_user;";
    sqlite3_stmt* stmt = nullptr;
    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr);
    if (rc == SQLITE_OK)
    {
        if (sqlite3_step(stmt) == SQLITE_ROW)
        {
            int count = sqlite3_column_int(stmt, 0);
            std::cout << "t_user表现有记录数：" << count << std::endl;
        }
        sqlite3_finalize(stmt); // 释放预编译语句，防止资源泄漏
    }
    else
    {
        std::cerr << "查询预编译失败：" << sqlite3_errmsg(db) << std::endl;
    }

    // 关闭数据库
    sqlite3_close(db);
    std::cout << "🔌 数据库连接已关闭" << std::endl;
    return 0;
}
