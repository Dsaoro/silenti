# SQLite database documentation
## Tables
 ### 1. users
 ### 2. financial_assets
 ### 3. profits
 ### 4. budget_categories
 ### 5. transactions
 ### 6. notifications

## Initialization script
``` sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  mode INTEGER NOT NULL,
  mode_group INTEGER NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL
)

CREATE TABLE financial_assets(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  balance REAL NOT NULL,
  included INTEGER NOT NULL,
  interestRate REAL,
  frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once')) NOT NULL
)

CREATE TABLE profits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  financialAsset INTEGER NOT NULL,
  date TEXT NOT NULL,
  amount REAL NOT NULL,
  FOREIGN KEY (financialAsset) REFERENCES financial_assets(id) 
)

CREATE TABLE budget_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT CHECK(type IN ('income', 'spent') NOT NULL),
  name TEXT NOT NULL,
  amount REAL NOT NULL,
  frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once')) NOT NULL,
  firstTime TEXT NOT NULL
)

CREATE TABLE sub_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category INTEGER NOT NULL,
  name TEXT NOT NULL,
  amount REAL NOT NULL,
  FOREIGN KEY (category) REFERENCES budget_categories(id)
)

CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  financialAsset INTEGER NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  description TEXT,
  category INTEGER NOT NULL,
  type TEXT CHECK(type IN ('income', 'spent')) NOT NULL,
  FOREIGN KEY (financialAsset) REFERENCES financial_assets(id)
  FOREIGN KEY (category) REFERENCES budget_categories(id)
)

CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  message TEXT NOT NULL,
  date TEXT NOT NULL,
  status TEXT CHECK(status IN ('pending', 'send', 'read')) NOT NULL,
  transaction_id INTEGER,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
)


INSERT INTO users (mode, mode_group, name, email, password)
  VALUES (1, 1, 'admin', '','')

INSERT INTO financial_assets (name, balance, included, interestRate, frequency)
  VALUES ('Efectivo', 0, 1, 0, 'once')

INSERT INTO profits (financialAsset, date, amount)
  VALUES (0, '2021-01-01', 0)

INSERT INTO budget_categories (type, name, amount, frequency, firstTime)
  VALUES ('spent','various', 0, 'monthly', '2021-01-01')

INSERT INTO budget_categories (type, name, amount, frequency, firstTime)
  VALUES ('income','Salario', 0, 'semi-monthly', '2021-01-01')

INSERT INTO transactions (financialAsset, amount, date, description, category, type)
  VALUES (0, 0, '2021-01-01', 'Initial balance', 'income', 'income')

INSERT INTO notifications (message, date, status, transaction_id)
  VALUES ('Initial balance', '2021-01-01', 'send', 1);
```