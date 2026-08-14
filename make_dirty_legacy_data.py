#!/usr/bin/env python3

import csv
import json
import os
import random
from datetime import date, timedelta

# ============================================================
# CONFIGURATION
# ============================================================

RANDOM_SEED = 42
random.seed(RANDOM_SEED)

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
RAW_DIR = os.path.join(BASE_DIR, "data", "raw")

CUSTOMERS_FILE = os.path.join(RAW_DIR, "customers.csv")
ACCOUNTS_FILE = os.path.join(RAW_DIR, "accounts.csv")
TRANSACTIONS_FILE = os.path.join(RAW_DIR, "transactions.csv")

MANIFEST_FILE = os.path.join(RAW_DIR, "data_quality_manifest.json")


# ============================================================
# HELPERS
# ============================================================

def read_csv(path):
    with open(path, "r", newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def write_csv(path, rows, fieldnames):
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=fieldnames,
            extrasaction="ignore"
        )
        writer.writeheader()
        writer.writerows(rows)


def choose_count(total, percentage, minimum, maximum):
    count = max(minimum, int(total * percentage))
    count = min(count, maximum)
    count = min(count, total)
    return count


def random_indices(total, count):
    return random.sample(range(total), count)


# ============================================================
# START
# ============================================================

print()
print("==============================================")
print(" LEGACY BANKING DATA - DATA QUALITY INJECTOR")
print("==============================================")
print()

print("[1/5] Reading CSV files...")

customers = read_csv(CUSTOMERS_FILE)
accounts = read_csv(ACCOUNTS_FILE)
transactions = read_csv(TRANSACTIONS_FILE)

print(f"Customers     : {len(customers):,}")
print(f"Accounts      : {len(accounts):,}")
print(f"Transactions  : {len(transactions):,}")


# ============================================================
# MANIFEST
# ============================================================

manifest = {
    "random_seed": RANDOM_SEED,
    "source_directory": "data/raw",
    "files_modified_in_place": True,
    "issues": {}
}


# ============================================================
# CUSTOMER ISSUES
# ============================================================

print()
print("[2/5] Injecting customer data-quality issues...")

customer_issues = {
    "missing_city": 0,
    "missing_segment": 0,
    "duplicate_customer": 0
}

# Missing city
count = choose_count(
    len(customers),
    0.001,
    20,
    100
)

for idx in random_indices(len(customers), count):
    customers[idx]["city"] = ""

customer_issues["missing_city"] = count


# Missing segment
count = choose_count(
    len(customers),
    0.001,
    20,
    100
)

for idx in random_indices(len(customers), count):
    customers[idx]["segment"] = ""

customer_issues["missing_segment"] = count


# Duplicate customers
count = choose_count(
    len(customers),
    0.0005,
    10,
    50
)

duplicate_customer_rows = []

for idx in random_indices(len(customers), count):

    original = customers[idx].copy()
    duplicate = original.copy()

    duplicate["customer_name"] = (
        original["customer_name"] + " UPDATED"
    )

    duplicate["city"] = (
        original["city"]
        if original["city"]
        else "Unknown"
    )

    duplicate["segment"] = (
        "Premium"
        if original["segment"] != "Premium"
        else "Basic"
    )

    duplicate_customer_rows.append(duplicate)

customers.extend(duplicate_customer_rows)

customer_issues["duplicate_customer"] = count

manifest["issues"]["customers"] = customer_issues


# ============================================================
# ACCOUNT ISSUES
# ============================================================

print("[3/5] Injecting account data-quality issues...")

account_issues = {
    "missing_customer_id": 0,
    "invalid_balance": 0,
    "orphan_customer_reference": 0
}


# Missing customer ID
count = choose_count(
    len(accounts),
    0.001,
    20,
    100
)

for idx in random_indices(len(accounts), count):
    accounts[idx]["customer_id"] = ""

account_issues["missing_customer_id"] = count


# Invalid balances
count = choose_count(
    len(accounts),
    0.0005,
    10,
    50
)

for idx in random_indices(len(accounts), count):
    accounts[idx]["balance"] = random.choice([
        "-5000.00",
        "-100000.00",
        "0",
        "-1.00"
    ])

account_issues["invalid_balance"] = count


# Orphan customer references
count = choose_count(
    len(accounts),
    0.0002,
    5,
    20
)

for idx in random_indices(len(accounts), count):
    accounts[idx]["customer_id"] = "C99999_ORPHAN"

account_issues["orphan_customer_reference"] = count

manifest["issues"]["accounts"] = account_issues


# ============================================================
# TRANSACTION ISSUES
# ============================================================

print("[4/5] Injecting transaction data-quality issues...")

transaction_issues = {
    "duplicate_transaction": 0,
    "invalid_amount": 0,
    "missing_account_id": 0,
    "invalid_transaction_type": 0,
    "future_transaction_date": 0,
    "orphan_account_reference": 0
}


# Duplicate transactions
count = choose_count(
    len(transactions),
    0.001,
    50,
    100
)

duplicate_transaction_rows = []

for idx in random_indices(len(transactions), count):
    duplicate_transaction_rows.append(
        transactions[idx].copy()
    )

transactions.extend(duplicate_transaction_rows)

transaction_issues["duplicate_transaction"] = count


# Invalid amounts
count = choose_count(
    len(transactions),
    0.0005,
    20,
    75
)

for idx in random_indices(len(transactions), count):
    transactions[idx]["amount"] = random.choice([
        "-100.00",
        "-5000.00",
        "0",
        "-1.00"
    ])

transaction_issues["invalid_amount"] = count


# Missing account IDs
count = choose_count(
    len(transactions),
    0.0005,
    20,
    75
)

for idx in random_indices(len(transactions), count):
    transactions[idx]["account_id"] = ""

transaction_issues["missing_account_id"] = count


# Invalid transaction types
count = choose_count(
    len(transactions),
    0.0005,
    20,
    75
)

invalid_types = [
    "UNKNOWN",
    "CashDeposit",
    "INVALID",
    "TransferX"
]

for idx in random_indices(len(transactions), count):
    transactions[idx]["transaction_type"] = random.choice(
        invalid_types
    )

transaction_issues["invalid_transaction_type"] = count


# Future transaction dates
count = choose_count(
    len(transactions),
    0.0003,
    10,
    50
)

future_base = date.today() + timedelta(days=30)

for idx in random_indices(len(transactions), count):

    future_date = future_base + timedelta(
        days=random.randint(1, 365)
    )

    transactions[idx]["transaction_date"] = (
        future_date.isoformat()
    )

transaction_issues["future_transaction_date"] = count


# Orphan account references
count = choose_count(
    len(transactions),
    0.0002,
    10,
    30
)

for idx in random_indices(len(transactions), count):
    transactions[idx]["account_id"] = "A99999_ORPHAN"

transaction_issues["orphan_account_reference"] = count

manifest["issues"]["transactions"] = transaction_issues


# ============================================================
# WRITE DIRECTLY BACK TO data/raw
# ============================================================

print()
print("[5/5] Replacing original CSVs with dirty legacy data...")

customer_fields = [
    "customer_id",
    "customer_name",
    "city",
    "segment"
]

account_fields = [
    "account_id",
    "customer_id",
    "account_type",
    "balance",
    "status"
]

transaction_fields = [
    "transaction_id",
    "account_id",
    "transaction_date",
    "transaction_type",
    "amount"
]

write_csv(
    CUSTOMERS_FILE,
    customers,
    customer_fields
)

write_csv(
    ACCOUNTS_FILE,
    accounts,
    account_fields
)

write_csv(
    TRANSACTIONS_FILE,
    transactions,
    transaction_fields
)


# ============================================================
# MANIFEST
# ============================================================

manifest["output_row_counts"] = {
    "customers": len(customers),
    "accounts": len(accounts),
    "transactions": len(transactions)
}

with open(
    MANIFEST_FILE,
    "w",
    encoding="utf-8"
) as f:
    json.dump(
        manifest,
        f,
        indent=2
    )


# ============================================================
# SUMMARY
# ============================================================

print()
print("==============================================")
print(" COMPLETE")
print("==============================================")

print()
print("Modified files:")

print(f"  {CUSTOMERS_FILE}")
print(f"  {ACCOUNTS_FILE}")
print(f"  {TRANSACTIONS_FILE}")

print()
print("Injected issues:")
print("----------------------------------------------")

for dataset, issues in manifest["issues"].items():

    print()
    print(dataset.upper())

    for issue, count in issues.items():
        print(f"  {issue:<35} {count:>6,}")

print()
print("Final row counts:")
print("----------------------------------------------")
print(f"  Customers     : {len(customers):,}")
print(f"  Accounts      : {len(accounts):,}")
print(f"  Transactions  : {len(transactions):,}")

print()
print("Manifest:")
print(f"  {MANIFEST_FILE}")

print()
print("IMPORTANT:")
print("data/raw now represents the DIRTY LEGACY SOURCE.")
print()
print("Next stage:")
print("  1. Load dirty data into Hive")
print("  2. Profile the data")
print("  3. Detect quality issues")
print("  4. Quarantine bad records")
print("  5. Clean using PySpark")
print("  6. Write clean Parquet")
print()
