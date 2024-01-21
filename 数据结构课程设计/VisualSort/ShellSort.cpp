#include "ShellSort.h"
#include <algorithm>
#include <cmath>
#include <QtMath>
#include <QTime>
#include <QPainter>
#include <QPainterPath>
#include <QPaintEvent>
#include <QScopeGuard>
#include <QFontMetrics>
#include <QDebug>

ShellSort::ShellSort(QObject *parent)
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

void ShellSort::sort(QVector<int>data_array, int interval)
{
    auto guard = qScopeGuard([this]{
        setRunFlag(false);
        emit updateRequest();
    });
    Q_UNUSED(guard)

    stop();
    initArr(data_array,interval);
    setRunFlag(true);

    int len = arr.length();
    //先将待排序的数组元素分成多个序列，然后对每个子序列分别进行直接插入排序
    for (arrGap = len / 2; arrGap > 0; arrGap /= 2)
    {
        for (arrI = arrGap; arrI < len; arrI++)
        {
            arrJ = arrI;
            animation.setDuration(interval);
            animation.start();
            loop.exec();
            emit updateRequest();
            if (!getRunFlag()) {
                return;
            }
            while (arrJ - arrGap >= 0 && arr[arrJ] < arr[arrJ - arrGap])
            {
                animation.setDuration(interval * 3);
                animation.start();
                swapFlag = true;
                loop.exec();
                if (getRunFlag()) {
                    qSwap(arr[arrJ], arr[arrJ - arrGap]);
                    swapFlag = false;
                }
                if (!getRunFlag()) {
                    return;
                }

                arrJ -= arrGap;
                animation.setDuration(interval);
                animation.start();
                loop.exec();
                emit updateRequest();
                if (!getRunFlag()) {
                    return;
                }
            }
            if (!getRunFlag()) {
                return;
            }
        }
        if (!getRunFlag()) {
            return;
        }
    }
}

void ShellSort::stop()
{
    setRunFlag(false);
    animation.stop();
    loop.quit();
    emit updateRequest();
}

void ShellSort::draw(QPainter *painter, int width, int height)
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
            int offset = animation.currentValue().toDouble() * arrGap * (item_width + item_space);
            if (i <= arrI && i % arrGap == arrI % arrGap) {
                color = QColor(0, 170 , 0);
            }
            if (i == arrJ - arrGap && arrJ - arrGap >= 0) {
                color = QColor(0, 170 , 255);
                if (swapFlag) {
                    item_left += offset;
                }
            } else if (i == arrJ) {
                color = QColor(0, 170 , 255);
                if (swapFlag) {
                    item_left -= offset;
                }
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
    //底部画当前的连线
    if (getRunFlag()) {
        painter->setPen(QPen(QColor(255, 170 , 0), 2));
        int y_top = height - 20;
        int y_bottom = height - 8;
        int first_i = arrI % arrGap;
        int last_i = 0;
        for (int i = 0; i < len; i++)
        {
            //色块位置x
            item_left = left_space + i * (item_width + item_space) + item_width / 2;
            if (i % arrGap == arrI % arrGap) {
                last_i = i;
                painter->drawLine(item_left, y_top, item_left, y_bottom);
            }
        }
        int left = left_space + first_i * (item_width + item_space) + item_width / 2;
        int right = left_space + last_i * (item_width + item_space) + item_width / 2;
        painter->drawLine(left, y_bottom, right, y_bottom);

        //标记i位置
        item_left = left_space + arrI * (item_width + item_space);
        const double loop_top = height - 24;
        QPainterPath m_path;
        m_path.moveTo(item_left + item_width / 2.0, loop_top);
        m_path.lineTo(item_left, loop_top + item_width / 2.0);
        m_path.lineTo(item_left + item_width, loop_top + item_width / 2.0);
        m_path.lineTo(item_left + item_width / 2.0, loop_top);
        painter->fillPath(m_path, QColor(0, 255, 0));
    }
}

void ShellSort::initArr(QVector<int>data_array,int count)
{
    arr = data_array;
    if (count < 2) {
        return;
    }
    arrI = 0;
    arrJ = 0;
    arrGap = 0;
    swapFlag = false;
    emit updateRequest();
}
