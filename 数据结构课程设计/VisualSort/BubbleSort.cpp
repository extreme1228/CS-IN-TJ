#include "BubbleSort.h"
#include <algorithm>
#include <cmath>
#include <QtMath>
#include <QTime>
#include <QPainter>
#include <QPaintEvent>
#include <QScopeGuard>
#include <QFontMetrics>
#include <QDebug>

BubbleSort::BubbleSort(QObject *parent)
    : SortObject(parent)
{
    //属性动画控制交换动画效果
    //animation.setDuration(2000);
    //属性从0变到1
    animation.setStartValue(0.0);
    animation.setEndValue(1.0);
    //以四次函数变化使得整体动画效果显得更自然
    animation.setEasingCurve(QEasingCurve::OutQuart);
    //循环一次
    animation.setLoopCount(1);
    //connect连接信号与槽，属性变化完以后推出循环，属性值每发生value的改变，发送update请求
    connect(&animation, &QVariantAnimation::finished, &loop, &QEventLoop::quit);
    connect(&animation, &QVariantAnimation::valueChanged, this, &SortObject::updateRequest);
}


void BubbleSort::sort(QVector<int>data_array, int interval)
{
    //确保在推出函数前进行相关的收尾工作
    auto guard = qScopeGuard([this]{
        setRunFlag(false);
        emit updateRequest();
    });
    Q_UNUSED(guard)

    stop();
    initArr(data_array,interval);
    setRunFlag(true);

    int len = arr.length();
    for (arrI = 0; arrI < len - 1; arrI++)
    {
        for (arrJ = 0; arrJ < len - 1 - arrI; arrJ++)
        {
            if (arr[arrJ] > arr[arrJ + 1]) {
                //需要交换位置
                animation.setDuration(interval * 3);//设置属性变化时间
                animation.start();
                swapFlag = true;
                loop.exec();//循环开始
                if (getRunFlag()) {
                    qSwap(arr[arrJ], arr[arrJ + 1]);
                    swapFlag = false;
                }
            } else {
                animation.setDuration(interval);
                animation.start();
                loop.exec();
            }
            //数组内部完成交换后，需要发出更改信号,之后在canvas类中调用paint函数进而调用draw函数实现UI的重新绘图
            emit updateRequest();
            if (!getRunFlag()) {
                //running = false。表示按下了停止按钮，此时停止一切活动
                return;
            }
        }
        if (!getRunFlag()) {
            return;
        }
    }
}

void BubbleSort::stop()
{
    setRunFlag(false);
    animation.stop();
    loop.quit();
    emit updateRequest();
}

void BubbleSort::draw(QPainter *painter, int width, int height)
{
    painter->setPen(QColor(200, 200, 200));
    const int len = arr.length();
    //边框距离
    const int left_space = 0;
    const int right_space = 0;
    QVector<int>item_height(len,0);//根据数组中数字的大小关系，提前将每个位置对应的高度算出
    const int text_space = 15; //文字和柱子间隔
    const int text_height = painter->fontMetrics().height();
    int pos_height = 0,neg_height = 0;
    for(int i=0;i<len;i++){
        if(arr[i]<0)neg_height = qMin(neg_height,arr[i]);
        if(arr[i]>0)pos_height = qMax(pos_height,arr[i]);
    }
    int tmp = pos_height - neg_height;
    for(int i=0;i<len;i++){
        item_height[i] = (double)abs(arr[i])*(height - text_height - text_space)/tmp;
    }
    int text_y = (double)abs(pos_height)*(height - text_height-text_space)/tmp + text_space/2;
    const int item_space = 10; //柱子横项间隔
    const double item_width = (width + item_space - left_space - right_space) / (double)len - item_space;
    double item_left = 0;
    QColor color;
    for (int i = 0; i < len; i++)
    {
        //色块位置x
        item_left = left_space + i * (item_width + item_space);
        //色块颜色
        color = QColor(200, 200, 200);
        //在执行排序操作的时候标记比较的两个元素
        if (getRunFlag()) {
            if (i == arrJ) {
                color = QColor(255, 170 , 0);
                if (swapFlag) {
                    item_left += animation.currentValue().toDouble() * (item_width + item_space);
                }
            } else if (i == arrJ + 1) {
                color = QColor(0, 170 , 255);
                if (swapFlag) {
                    item_left -= animation.currentValue().toDouble() * (item_width + item_space);
                }
            } else if (i >= len - arrI) {
                //已排序好的
                color = QColor(0, 170, 0);
            }
        }
        //画文字
        painter->drawText(item_left + item_width/2, text_y,
                          QString::number(arr.at(i)));
        //画色块柱子
        if(arr[i]>0){
            painter->fillRect(item_left, text_y - text_space/2 - text_height - item_height[i],
                              item_width, item_height[i],
                              color);
        }
        else{
            painter->fillRect(item_left, text_y + text_space/2 + text_height,
                              item_width, item_height[i],
                              color);
        }
    }
}

void BubbleSort::initArr(QVector<int>data_array,int count)
{
    arr = data_array;
    if (count < 2) {
        return;
    }
    arrI = 0;
    arrJ = 0;
    swapFlag = false;
    emit updateRequest();
}
