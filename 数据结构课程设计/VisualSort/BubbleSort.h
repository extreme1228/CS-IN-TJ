#pragma once
#include "SortObject.h"
#include <QVector>
#include <QEventLoop>
#include <QVariantAnimation>
#include<QtGlobal>

//冒泡排序
class BubbleSort : public SortObject
{
    Q_OBJECT
public:
    explicit BubbleSort(QObject *parent = nullptr);

    //开始排序
    //arr排序数组，interval动画持续时间参考值
    void sort(QVector<int>data_array, int interval) override;
    //结束排序
    void stop() override;
    //绘制
    void draw(QPainter *painter, int width, int height) override;

private:
    void initArr(QVector<int>data_array,int count);

private:
    QEventLoop loop;//事件循环，方便展示动画效果
    QVariantAnimation animation;//实现属性平滑变化，方便更好的显示绘图结果

    QVector<int>arr;
    //for循环下标
    int arrI{0};
    int arrJ{0};
    //标记当前交换状态
    bool swapFlag{false};
};
