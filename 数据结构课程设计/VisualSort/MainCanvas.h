#pragma once
#include <QWidget>
#include "SortObject.h"

//绘制排序的widget，通过切换sortobject来演示各种排序效果
class MainCanvas : public QWidget
{
    Q_OBJECT
public:
    explicit MainCanvas(QWidget *parent = nullptr);

    //不同的SortObejct对应不同排序规则
    int getSortType() const;
    void setSortObject(int type, SortObject *obj);
    //开始排序
    void sort(QVector<int>data_array, int interval);
    //结束排序
    void stop();

protected:
    //重写QWidget中的paintEvent虚函数，当有update信号发出时都会调用该函数重新改变窗口
    void paintEvent(QPaintEvent *event) override;

signals:
    //排序执行状态
    void runFlagChanged(bool running);

private:
    int sortType{-1};
    SortObject *sortObj{nullptr};
};
