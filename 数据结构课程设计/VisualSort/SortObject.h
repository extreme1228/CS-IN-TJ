#pragma once
#include <QObject>
#include <QPainter>

//排序对象父类，提供公共接口给canvas
//SortObject实际上是一个虚类，本身并不实现什么功能，主要起到把各个排序类汇总到一起的功能
class SortObject : public QObject
{
    Q_OBJECT
public:
    explicit SortObject(QObject *parent = nullptr);

    //定义三个虚函数，具体实现过程放在具体的Sort类中
    //开始排序
    //count元素个数，interval动画持续时间参考值
    virtual void sort(QVector<int>data_array, int interval) = 0;
    //结束排序
    virtual void stop() = 0;
    //绘制
    virtual void draw(QPainter *painter, int width, int height) = 0;

    //running排序状态
    bool getRunFlag() const;
    void setRunFlag(bool flag);

//信号函数的实现，实质上是一个函数声明，并不需要实现具体的函数，且返回值为void
signals:
    void runFlagChanged(bool running);//运行状态信号
    void updateRequest();//更新数据信号

private:
    //排序执行状态，=true则正在排序
    bool runFlag{false};
};
