import pandas as pd
import json
from pandas import json_normalize

# 1. CSV 파일 불러오기
df = pd.read_csv('history.csv')

# 2. JSON 데이터 파싱 및 리스트로 변환
def parse_json_column(json_str):
    try:
        json_str = json_str.strip('"').replace('\\', '')
        return json.loads(json_str)
    except json.JSONDecodeError:
        return []

# 특정 칼럼이 'json_column'이라고 가정
df = df.drop(columns='comment')
df['exercises'] = df['exercises'].apply(parse_json_column)

# 3. 리스트를 행으로 추가
# JSON 리스트가 담긴 칼럼을 분리
expanded_df = df.explode('exercises')

expanded_df = expanded_df.reset_index(drop=True)


json_normalized_df = json_normalize(expanded_df['exercises'])
json_normalized_df = json_normalized_df.drop(columns='date')


expanded_df = pd.concat([expanded_df.drop(columns='exercises'), json_normalized_df], axis=1)

expanded_df = expanded_df.reset_index(drop=True)

expanded_df = expanded_df.explode('sets')

expanded_df = expanded_df.reset_index(drop=True)

json_normalized_df = json_normalize(expanded_df['sets'])
expanded_df = pd.concat([expanded_df.drop(columns='sets'), json_normalized_df], axis=1)

# 4. 결과를 새로운 CSV 파일로 저장
expanded_df.to_csv('expanded_file3.csv', index=False,encoding='utf-8-sig')

# 결과 확인
#print(expanded_df)
