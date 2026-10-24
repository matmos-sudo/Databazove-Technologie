import pyarrow.parquet as pq
import pandas as pd

#1.
parquet = pq.ParquetFile("green_tripdata_2024-01.parquet")
metadata = parquet.metadata
print("Number of rows:", metadata.num_rows)
print("Number of columns:", metadata.num_columns)
print("Number of row groups:", metadata.num_row_groups)
print("Created by:", metadata.created_by)
print(parquet.schema_arrow)

#2.
for i in range(metadata.num_row_groups):
    rg = metadata.row_group(i)
    print(
        f"Row group {i}: "
        f"rows={rg.num_rows:,}, "
        f"columns={rg.num_columns}, "
        f"size={rg.total_byte_size / 1024 / 1024:.2f} MB"
    )
#3.
column = metadata.row_group(0).column(8)
stats = column.statistics
print("Column:", column.path_in_schema)
print("Physical type:", column.physical_type)
print("Compression:", column.compression)
print("Number of values:", column.num_values)
print("Compressed size:", column.total_compressed_size)
print("Uncompressed size:", column.total_uncompressed_size)
if stats is not None:
    print("Min:", stats.min_raw)
    print("Max:", stats.max_raw)
    print("Null count:", stats.null_count)
else:
    print("Statistics are not available.")

#4.
df = pd.read_parquet("green_tripdata_2024-01.parquet",columns=["lpep_pickup_datetime",
                                                                "VendorID",
                                                                "trip_distance",
                                                                "extra"])
print(df.head(10))
print(df.info())
print(df.describe())

#5.
table = parquet.read_row_group(0,columns=["lpep_pickup_datetime",
                                            "VendorID",
                                                                "trip_distance",
                                                                "extra"])
print(type(table))
print(table.schema)
df_row_group = table.to_pandas()
print(type(df_row_group))
print(df_row_group.head(5))

#6.
#Aká je priemerná cena jazdy (fare_amount) v závislosti od použitého spôsobu platby (payment_type)?
import pandas as pd

stlpce = ['payment_type', 'fare_amount']
df = pd.read_parquet('green_taxi.parquet', columns=stlpce)
vysledok = df.groupby('payment_type')['fare_amount'].mean().reset_index()
print(vysledok)
#Z výslednej tabuľky môžeme pozorovať, aká je priemerná cena jazdy pre rôzne spôsoby platby. Dáta nám napríklad môžu ukázať, či pasažieri platiaci kreditnou kartou zvyknú cestovať na dlhšie a drahšie vzdialenosti v porovnaní s tými, ktorí platia v hotovosti