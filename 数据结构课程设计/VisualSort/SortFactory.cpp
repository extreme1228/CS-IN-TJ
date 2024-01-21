#include "SortFactory.h"
#include "BubbleSort.h"
#include "SelectionSort.h"
#include "InsertionSort.h"
#include "QuickSort.h"
#include "ShellSort.h"
#include"BinaryInsertionSort.h"

SortFactory::SortFactory(QObject *parent)
    : QObject(parent)
{

}

SortFactory *SortFactory::getInstance()
{
    static SortFactory instance;
    return &instance;
}

SortObject *SortFactory::createSortObject(int row, QObject *parent)
{
    //根据排序UI界面的选择，创建对应的Sort类对象，方便canvas类进行后续的绘图
    switch (row) {
    case 0: return new BubbleSort(parent);
    case 1: return new SelectionSort(parent);
    case 2: return new InsertionSort(parent);
    case 3: return new QuickSort(parent);
    case 4: return new ShellSort(parent);
    case 5: return new BinaryInsertionSort(parent);
    default: break;
    }
    return nullptr;
}

QStringList SortFactory::getSortList() const
{
    //初始化UI界面的排序种类
    return QStringList{
        "冒泡排序"
        , "选择排序"
        , "插入排序"
        , "快速排序"
        , "希尔排序"
        , "折半插入排序"
    };
}
