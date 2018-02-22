import isochroner as iso
import geopandas as gpd
import iso_keys as keys
import os

gdf = gpd.read_file(os.path.join('shapefiles', 'ti_2015_chi_only.shp'))
iso.isochrone_batch(
    gdf,
    key=keys.api_key,
    out_filename=os.path.join('data', 'isochrones.csv'),
    duration=20,
    keep_cols=['GEOID'],
    batch_size=3)

# df = pd.read_csv('isochrones.csv')
# iso.isochrones_to_shp(df, os.path.join('shapefiles', 'isochrones.shp'), crs=4269)


