import pandas as pd

df = pd.read_csv("pandas_dataset.csv")

print("First 5 rows:")
print(df.head())

df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")

df = df.dropna(how="all")
df = df.reset_index(drop=True)

print("\nShape before cleaning:", df.shape)

print("\nMissing values:")
print(df.isnull().sum())

df = df.dropna(subset=["sales"])

df["profit"] = df["profit"].fillna(df["profit"].mean())
df["discount"] = df["discount"].fillna(df["discount"].median())

df["customer_name"] = df["customer_name"].fillna("Unknown")

duplicates = df.duplicated(subset=["order_id"])

print("\nNumber of duplicate Order IDs:", duplicates.sum())

df = df.drop_duplicates(subset=["order_id"])
df = df.reset_index(drop=True)

print("\nOrders where unit_price is greater than 20000:")
print(df[df["unit_price"] > 20000])

print("\nCompleted orders with unit_price greater than 10000:")
print(df[(df["unit_price"] > 10000) & (df["status"] == "Completed")]
      [["customer_name", "category", "status"]])

df["total_amount"] = df["quantity"] * df["unit_price"] - df["discount"]

df["customer_type"] = df["quantity"].apply(
    lambda x: "Bulk Buyer" if x >= 3 else "Regular Buyer"
)

print("\nShape after cleaning:", df.shape)

print("\nFirst 10 rows of cleaned dataset:")
print(df.head(10))