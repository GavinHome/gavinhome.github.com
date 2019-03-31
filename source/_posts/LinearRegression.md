---
title: 线性回归
tags: 
- 机器学习

category: 
- 机器学习

date: 2017-08-25 15:57:06 +0800
cover: /img/static/2017-08-25/output_32_1.png
author: 
  nick: gavinhome
  link: https://www.github.com/gavinhome
subtitle: 有监督学习中，标记值为离散类型，则为分类问题；如果是连续值，则为回归。样本非线性，参数线性
---

有监督学习中，标记值为离散类型，则为分类问题；如果是连续值，则为回归。样本非线性，参数线性。

## 模型描述

### 模型介绍

$$y=ax+b$$

对于两个变量：

$$h_\theta \left ( x \right ) =\theta _0 + \theta _1 x_1+\theta _2 x_2$$

扩展到N维变量

$$h_\theta \left ( x \right ) =\sum _{i=0}^{n}{\theta _i}x_i=\theta ^T x$$

加上误差项可表示为以下形式：

$${y^\left ( i \right ) }= {\theta ^ T x^\left ( i \right )} + {\varepsilon ^ \left ( i \right )}$$

其中$${\varepsilon ^ \left ( i \right )}$$是独立同分布服务均值为0，误差为某定值$$\sigma ^2$$的高斯分布。

### 求解解析式

目标函数:$$J\left ( \theta  \right )=\frac{1}{2}\sum^m_{i=1}\left ( h_\theta{\left ( x^{\left ( i \right )} \right )} - y^{\left ( i \right )} \right )^2 = \frac{1}{2}\left ( X\theta - y \right )^T\left ( X\theta - y \right )$$

梯度：$$\Delta _\theta J\left ( \theta \right ) = X^T X \theta - X^T y$$

求驻点，得：$$\theta = \left ( {X^T X} \right )^{-1} X^T y$$

若$${X^T X}$$不可逆或防止过拟合，增加扰动，得：$$\theta = \left ( {X^T X + \lambda I} \right )^{-1} X^T y$$

### 线性回归的复杂度惩罚因子

L2-norm: $$J\left ( \vec{\theta}  \right )=\frac{1}{2}\sum^m_{i=1}\left ( h_\theta{\left ( x^{\left ( i \right )} \right )} - y^{\left ( i \right )} \right )^2  + \lambda \sum_{j=1}^{n}\theta_j^2$$, Ridge回归（1970）

L1-norm: 
$$J\left ( \vec{\theta}  \right )=\frac{1}{2}\sum^m_{i=1}\left ( h_\theta{\left ( x^{\left ( i \right )} \right )} - y^{\left ( i \right )} \right )^2  + \lambda \sum_{j=1}^{n}  \left | \theta_j \right |$$, LASSO（Least Absolute Shrinkage and Selection Operator), LARS算法解决LASSO计算

Elastic Net: 
$$J\left ( \vec{\theta}  \right )=\frac{1}{2}\sum^m_{i=1}\left ( h_\theta{\left ( x^{\left ( i \right )} \right )} - y^{\left ( i \right )} \right )^2  +\lambda  \left [  \rho\cdot  \sum_{j=1}^{n}  \left | \theta_j \right |  + \left ( 1-\rho  \right ) \cdot \sum_{j=1}^{n}\theta_j^2 \right ]$$

满足：$$\left\{\begin{matrix}
\lambda &gt;0\\ 
\rho \in \left [ 0,1 \right ]\\ 
\end{matrix}\right.$$

### 梯度下降

SGD:随机梯度，每拿到一个样本就进行梯度下降，一直循环

BGD:批量梯度

mini-batch:若干个样本的平均梯度作为更新方向

## 案例：广告费与销量关系分析

### 实验数据

数据集信息：数据共4列200行，前三列为输入特征，最后一列为输出特征。  

输入特征：

1. TV：在电视上投资的广告费用（以千元为单数，下同）
2. Radio：在广播媒体上投资的广告费用
3. Newspaper： 在报纸媒体上投资的广告费用

输出特征：

  Sales：该商品的销量


### 读取数据


```python
import pandas as pd
import io
import requests
url="https://raw.githubusercontent.com/GavinHome/MLL/master/data/Advertising.csv"
data=pd.read_csv(io.StringIO(requests.get(url).content.decode('utf-8')))  
data.head()
```


<div>
<table class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Unnamed: 0</th>
      <th>TV</th>
      <th>Radio</th>
      <th>Newspaper</th>
      <th>Sales</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>230.1</td>
      <td>37.8</td>
      <td>69.2</td>
      <td>22.1</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>44.5</td>
      <td>39.3</td>
      <td>45.1</td>
      <td>10.4</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>17.2</td>
      <td>45.9</td>
      <td>69.3</td>
      <td>9.3</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>151.5</td>
      <td>41.3</td>
      <td>58.5</td>
      <td>18.5</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>180.8</td>
      <td>10.8</td>
      <td>58.4</td>
      <td>12.9</td>
    </tr>
  </tbody>
</table>
</div>



### 绘制TV/Radio/Newspaper与Sales关系图


```python
import matplotlib as mpl #设置环境变量
import matplotlib.pyplot as plt #绘图专用
import sys
reload(sys)
sys.setdefaultencoding('utf8')
mpl.rcParams['font.sans-serif'] = ['FangSong']
mpl.rcParams['axes.unicode_minus']=False

x = data[['TV', 'Radio', 'Newspaper']]
y = data[['Sales']]

# 绘制输入特征与输出特征的关系图
# plt.plot(data['TV'], y, 'ro', label='TV')
# plt.plot(data['Radio'], y, 'g^', label='Radio')
# plt.plot(data['Newspaper'], y, 'b*', label='Newspaper')
# plt.legend(loc='lower right')
# plt.grid()
# plt.show()

# 绘制：上图将三者关系绘制在一张图上，不能直观显示
# 以下代码将三组关系分别显示在三个子图上
plt.figure("TV/Radio/Newspaper与Sales的关系",figsize=(9,12))
plt.subplot(311)
plt.plot(data['TV'], y, 'ro', label='TV')
plt.title('TV')
plt.grid()

plt.subplot(312)
plt.plot(data['Radio'], y, 'g^', label='Radio')
plt.title('Radio')
plt.grid()

plt.subplot(313)
plt.plot(data['Newspaper'], y, 'b*', label='Newspaper')
plt.title('Newspaper')
plt.grid()

plt.tight_layout()
plt.show()
```

    /home/nbuser/anaconda2_410/lib/python2.7/site-packages/matplotlib/font_manager.py:273: UserWarning: Matplotlib is building the font cache using fc-list. This may take a moment.
      warnings.warn('Matplotlib is building the font cache using fc-list. This may take a moment.')



![png](/img/static/2017-08-25/output_32_1.png)


### 构建特征向量和标签列


```python
#创建包括特征向量名称的列表
feature_cols=['TV', 'Radio', 'Newspaper']
#使用特征向量标签集合选择原始数据的一个子集
#等价于data[['TV', 'Radio', 'Newspaper']]
X = data[feature_cols] 
#打印前5行
X.head()
```




<div>
<table class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>TV</th>
      <th>Radio</th>
      <th>Newspaper</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>230.1</td>
      <td>37.8</td>
      <td>69.2</td>
    </tr>
    <tr>
      <th>1</th>
      <td>44.5</td>
      <td>39.3</td>
      <td>45.1</td>
    </tr>
    <tr>
      <th>2</th>
      <td>17.2</td>
      <td>45.9</td>
      <td>69.3</td>
    </tr>
    <tr>
      <th>3</th>
      <td>151.5</td>
      <td>41.3</td>
      <td>58.5</td>
    </tr>
    <tr>
      <th>4</th>
      <td>180.8</td>
      <td>10.8</td>
      <td>58.4</td>
    </tr>
  </tbody>
</table>
</div>




```python
type(X)
```




    pandas.core.frame.DataFrame




```python
X.shape
```




    (200, 3)




```python
y=data['Sales']
y.head()
```




    0    22.1
    1    10.4
    2     9.3
    3    18.5
    4    12.9
    Name: Sales, dtype: float64



### 构建训练集与测试集


```python
from sklearn.cross_validation import train_test_split
X_train,X_test,y_train,y_test = train_test_split(X,y,random_state=1)
```


```python
X_train.shape
```




    (150, 3)




```python
X_test.shape
```




    (50, 3)




```python
y_train.shape
```




    (150,)




```python
y_test.shape
```




    (50,)



### sklearn的线性回归


```python
from sklearn.linear_model import LinearRegression
linreg = LinearRegression()
model = linreg.fit(X_train,y_train)
```


```python
model
```




    LinearRegression(copy_X=True, fit_intercept=True, n_jobs=1, normalize=False)




```python
linreg.intercept_
```




    2.87696662231793




```python
linreg.coef_
```




    array([ 0.04656457,  0.17915812,  0.00345046])




```python
zip(feature_cols,linreg.coef_)
```




    [('TV', 0.046564567874150281),
     ('Radio', 0.17915812245088839),
     ('Newspaper', 0.0034504647111804412)]



### 预测


```python
y_pred = linreg.predict(X_test)
y_pred
```




    array([ 21.70910292,  16.41055243,   7.60955058,  17.80769552,
            18.6146359 ,  23.83573998,  16.32488681,  13.43225536,
             9.17173403,  17.333853  ,  14.44479482,   9.83511973,
            17.18797614,  16.73086831,  15.05529391,  15.61434433,
            12.42541574,  17.17716376,  11.08827566,  18.00537501,
             9.28438889,  12.98458458,   8.79950614,  10.42382499,
            11.3846456 ,  14.98082512,   9.78853268,  19.39643187,
            18.18099936,  17.12807566,  21.54670213,  14.69809481,
            16.24641438,  12.32114579,  19.92422501,  15.32498602,
            13.88726522,  10.03162255,  20.93105915,   7.44936831,
             3.64695761,   7.22020178,   5.9962782 ,  18.43381853,
             8.39408045,  14.08371047,  15.02195699,  20.35836418,
            20.57036347,  19.60636679])



### 回归问题的评价测度

对于分类问题，评价测度（evaluation metrics）是准确率，但这种方法不适用于回归问题。我们使用针对连续数值的评价测度，有三种常用的针对线性回归的测度。
  1. 平均绝对误差（Mean Absolute Error, MAE)
  2. 均方差误差（Mean Squared Error, MSE)
  3. 均方根误差（Root Mean Squared Error, RMSE)



```python
from sklearn import metrics
import numpy as np
sum_mean = 0
for i in range(len(y_pred)):
    sum_mean += (y_pred[i]-y_test.values[i])**2
"RMSE by hand:",np.sqrt(sum_mean/len(y_pred))
```




    ('RMSE by hand:', 1.4046514230328957)



### 作图


```python
plt.figure()
plt.plot(range(len(y_pred)), y_pred, 'g', label='predict')
plt.plot(range(len(y_pred)), y_test, 'r', label='test')
plt.legend(loc='upper right')
plt.xlabel("the number of sales")
plt.ylabel("value of sales")
plt.show()
```


![png](/img/static/2017-08-25/output_56_0.png)


### 结果分析

根据结果得模型：y=2.8769+0.0465xTV+0.1791xRadio+0.00345xNewspaper),发现Newspaper系数很小，再进一步观察Newspaper与Sales的关系散点图，发现其线性关系并不明显，因此将其去除。再看看线性回归预测的RMSE结果如何。


```python
X = data[['TV', 'Radio']]
X_train,X_test,y_train,y_test = train_test_split(X,y,random_state=1)
linreg = LinearRegression()
model = linreg.fit(X_train,y_train)
y_pred = linreg.predict(X_test)

sum_mean = 0
for i in range(len(y_pred)):
    sum_mean += (y_pred[i]-y_test.values[i])**2
"RMSE by hand:",np.sqrt(sum_mean/len(y_pred))
```




    ('RMSE by hand:', 1.3879034699382888)




```python
plt.figure()
plt.plot(range(len(y_pred)), y_pred, 'b', label='predict')
plt.plot(range(len(y_pred)), y_test, 'r', label='test')
plt.legend(loc='upper right')
plt.xlabel("the number of sales")
plt.ylabel("value of sales")
plt.show()
```


![png](/img/static/2017-08-25/output_60_0.png)


## 注意事项
本模型虽然简单，但它涵盖了机器学习的相当部分内容。如使用75%的训练集和25%的测试机，这往往是机器学习模型的第一步。分析结果的权值和特征数据分布，我们使用了简单的方法：直接删除；单这样做，仍然得到了更好的预测结果。
在机器学习中有“奥卡姆剃刀”原理，即：如果能够用简单模型解决问题，则不适用更为复杂的模型。因为复杂模型往往增加了不确定性，造成过多的人力和屋里成本，且容易过拟合。
