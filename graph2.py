#!/usr/bin/env python3
import sys
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.dates as mdates

fig = plt.figure()
ax = fig.add_subplot(1,1,1)

# 横軸：日付 periods分の日付を用意します。
x = pd.date_range('2018-08-07 00:00:00', periods=10, freq='d')

# 縦軸：数値
y = [130, 141, 142, 143, 171, 230, 231, 260, 276, 297]

ax.plot(x,y)

# 日付ラベルフォーマットを修正
dayｓ = mdates.DayLocator() 
daysFmt = mdates.DateFormatter('%m-%d')
ax.xaxis.set_major_locator(days)
ax.xaxis.set_major_formatter(daysFmt)

# グラフの表示
plt.show()

# グラフの保存
plt.savefig('figure.png') # -----(2)