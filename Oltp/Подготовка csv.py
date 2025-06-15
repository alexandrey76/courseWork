import pandas as pd
import numpy as np
from faker import Faker

# Загрузка исходного датасета
df = pd.read_csv('vgsales.csv')

# Удаление строк с пропущенными критичными значениями
df = df.dropna(subset=['Name', 'Platform', 'Year', 'Genre', 'Publisher'])

# Очистка пробелов
df.columns = df.columns.str.strip()
df['Name'] = df['Name'].str.strip()
df['Genre'] = df['Genre'].str.strip()
df['Publisher'] = df['Publisher'].str.strip()
df['Platform'] = df['Platform'].str.strip()

# publishers.csv
publishers_df = df[['Publisher']].drop_duplicates().rename(columns={'Publisher': 'name'})
publishers_df.to_csv('publishers.csv', index=False)

# genres.csv
genres_df = df[['Genre']].drop_duplicates().rename(columns={'Genre': 'name'})
genres_df.to_csv('genres.csv', index=False)

# platforms.csv
platforms_df = df[['Platform']].drop_duplicates().rename(columns={'Platform': 'name'})
platforms_df.to_csv('platforms.csv', index=False)

# games.csv
games_df = df[['Name', 'Publisher', 'Genre', 'Year']].drop_duplicates()
games_df = games_df.rename(columns={
    'Name': 'title',
    'Publisher': 'publisher_name',
    'Genre': 'genre_name',
    'Year': 'year'
})
games_df['year'] = games_df['year'].astype(int)
games_df.to_csv('games.csv', index=False)

# game_platforms.csv
game_platforms_df = df[['Name', 'Platform']].drop_duplicates()
game_platforms_df = game_platforms_df.rename(columns={
    'Name': 'title',
    'Platform': 'platform_name'
})
game_platforms_df.to_csv('game_platforms.csv', index=False)

# regions.csv (ручной список)
regions_df = pd.DataFrame({
    'region_id': ['NA', 'EU', 'JP', 'OT'],
    'name': ['North America', 'Europe', 'Japan', 'Other']
})
regions_df.to_csv('regions.csv', index=False)

# sales.csv
sales_columns = {
    'NA_Sales': 'NA',
    'EU_Sales': 'EU',
    'JP_Sales': 'JP',
    'Other_Sales': 'OT'
}

sales_data = []
for col, region in sales_columns.items():
    temp = df[['Name', 'Platform', col]].copy()
    temp = temp.rename(columns={
        'Name': 'title',
        'Platform': 'platform_name',
        col: 'amount'
    })
    temp['region_code'] = region
    temp = temp[temp['amount'] > 0]
    sales_data.append(temp)

sales_df = pd.concat(sales_data, ignore_index=True)
sales_df = sales_df[['title', 'platform_name', 'region_code', 'amount']]
sales_df.to_csv('sales.csv', index=False)

# critics.csv — синтетические оценки
fake = Faker()
games = games_df['title'].unique().tolist()

critics_data = []
for game in games:
    critics_data.append({
        'game_title': game,
        'score': round(np.random.uniform(5.0, 10.0), 1),
        'source': fake.company()
    })

critics_df = pd.DataFrame(critics_data)
critics_df.to_csv('critics.csv', index=False)
